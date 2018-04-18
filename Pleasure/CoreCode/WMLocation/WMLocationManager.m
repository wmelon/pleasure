//
//  WMLocationManager.m
//  Pleasure
//
//  Created by Sper on 2018/4/17.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "CLLocation+WMTransform.h"

@implementation WMLocationInfo
@end

@interface WMLocationSession()
@property (nonatomic, strong) UIAlertView * locationDisableAlertView; // 没有定位提示框
@property (nonatomic, assign) BOOL isShow; /// 是否正在显示 防止调用多次显示
@end

@implementation WMLocationSession
+ (instancetype)shareLocationSession{
    static dispatch_once_t onceToken;
    static WMLocationSession *object;
    dispatch_once(&onceToken, ^{
        object = [[WMLocationSession alloc] init];
    });
    return object;
}
- (void)showNoOpenLocationAlertView{
    /// 整个生命周期只显示一次  其它需要再次显示的地方可以直接更改isShow的值
    if (self.isShow == NO){
        self.isShow = !self.isShow;
        [self.locationDisableAlertView show];
    }
}
- (void)hiddenNoOpenLocationAlertView{
    if (self.locationDisableAlertView){
        [self.locationDisableAlertView dismissWithClickedButtonIndex:[self.locationDisableAlertView cancelButtonIndex] animated:YES];
    }
}
#pragma mark - 应用程序定位不可用
- (UIAlertView *)locationDisableAlertView {
    if (!_locationDisableAlertView) {
        _locationDisableAlertView = [[UIAlertView alloc] initWithTitle:@"定位未开启" message:@"请在“设置->定位服务”中确认“定位”和“南瓜车”是否为开启状态" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
    }
    return _locationDisableAlertView;
}

#pragma mark -- UIAlertViewDelegate代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([alertView isEqual:self.locationDisableAlertView]) {
        if (buttonIndex == 1) {
            if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }
    }
}
@end

@interface WMLocationManager()<CLLocationManagerDelegate,AMapSearchDelegate>
/// 定位管理器
@property (nonatomic, strong) CLLocationManager *locMgr;
/// 当前定位信息
@property (nonatomic, strong) CLLocation *currentLocation;
// 上次写入经纬度的时间
@property (nonatomic, strong) NSDate *lastLocationTime;
/// 上次定位失败时间
@property (nonatomic, strong) NSDate *lastLocationFailTime;
/// 反地理编码检索api
@property (nonatomic, strong) AMapSearchAPI *searchAPI;
/// 反地理编码成功回调
@property (nonatomic, copy  ) NGCSearchResultHandle searchResultHandle;
/// 反地理编码失败回调
@property (nonatomic, copy  ) NGCSearchFailHandle searchFailHandle;
/// 定位成功回调
@property (nonatomic, copy  ) NGCLocationResultHandle locationResultHandle;
/// 定位失败回调
@property (nonatomic, copy  ) NGCLocationFiledHandle locationFailedHandle;
/// 定位同时返回反地理编码
@property (nonatomic, copy  ) NGCMapLocatingCompletionBlock completionBlock;
@end

@implementation WMLocationManager

- (void)startLocationForLocationResult:(NGCLocationResultHandle)locationResultHandle locationFailedHandle:(NGCLocationFiledHandle)locationFailedHandle{
    _locationResultHandle = locationResultHandle;
    _locationFailedHandle = locationFailedHandle;
    [self startLocation];
}
/// 开启定位同时返回反地理编码信息
- (void)requestLocationForCompletionBlock:(NGCMapLocatingCompletionBlock)completionBlock{
    _completionBlock = completionBlock;
    [self startLocation];
}
- (void)startLocation{
    if (self.distanceFilter == 0){
        self.distanceFilter = 1000;
    }
    self.locMgr.distanceFilter = self.distanceFilter;
    if([CLLocationManager locationServicesEnabled]) {
        BOOL allowUpdating = [self reportAllowStartUpdatingLocationWithStatus:[CLLocationManager authorizationStatus]];
        [self switchAuthorizationStatus:allowUpdating];
    }else {
        [self stopUpdateUserLocation];
    }
}
/// 可以定位开启定位关闭提示
- (void)startUpdateUserLocation{
    [self.locMgr startUpdatingLocation];
    [[WMLocationSession shareLocationSession] hiddenNoOpenLocationAlertView];
}
/// 不可以定位提示
- (void)stopUpdateUserLocation{
    [self.locMgr stopUpdatingLocation];
    if (self.openTipType == WMLocationOpenTipType_always){
        [WMLocationSession shareLocationSession].isShow = NO;
    }
    [[WMLocationSession shareLocationSession] showNoOpenLocationAlertView];
}
- (void)switchAuthorizationStatus:(BOOL)allowUpdating{
    if (allowUpdating){
        [self startUpdateUserLocation];
    }else {
        [self stopUpdateUserLocation];
    }
}
#pragma mark - 状态改变时调用
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    BOOL allowUpdating = [self reportAllowStartUpdatingLocationWithStatus:status];
    [self switchAuthorizationStatus:allowUpdating];
}
- (BOOL)reportAllowStartUpdatingLocationWithStatus:(CLAuthorizationStatus)status{
    BOOL allowUpdating = NO;
    /// 定位授权状态监听
    if(status == kCLAuthorizationStatusNotDetermined || status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways){
        //未决定，继续请求授权
        allowUpdating = YES;
    }
    return allowUpdating;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *newLocation = locations.lastObject;
    /// 转换为火星坐标
    newLocation = [newLocation transformMarsLocations];
    /// 已经定位失败了
    if (newLocation.horizontalAccuracy < 0) return;
    
    double distance = [_currentLocation distanceFromLocation:newLocation];
    /// 如果距离上次定位超过五分钟 或者 距离移动超过设定距离可以更新定位信息
    if ([self checkAllowLocationAgainWithDate:_lastLocationTime] || distance >= self.distanceFilter || ![WMLocationSession shareLocationSession].locationInfo){
        _lastLocationTime = [NSDate date];
        _currentLocation = newLocation;
        
        /// 存储定位信息到单例中
        WMLocationInfo *locationInfo = [[WMLocationInfo alloc] init];
        locationInfo.lat = newLocation.coordinate.latitude;
        locationInfo.lng = newLocation.coordinate.longitude;
        [WMLocationSession shareLocationSession].locationInfo = locationInfo;
        
        if (_locationResultHandle){
            _locationResultHandle(locationInfo.lat , locationInfo.lng);
        }
        /// 开始执行反地理编码
        [self startReGeocode:newLocation error:nil];
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [WMLocationSession shareLocationSession].locationInfo = nil;
    if ([self checkAllowLocationAgainWithDate:_lastLocationFailTime]){
        _lastLocationFailTime = [NSDate date];
        
        if (_locationFailedHandle){
            _locationFailedHandle(error);
        }
        /// 开始执行反地理编码
        [self startReGeocode:nil error:error];
    }
}
- (void)startReGeocode:(CLLocation *)location error:(NSError *)error{
    if (location){
        __weak typeof(self) weakself = self;
        double lat = location.coordinate.latitude;
        double lng = location.coordinate.longitude;
        [self mapReGeocodeSearchByLatitude:lat andLongTitude:lng searchResultHandle:^(AMapAddressComponent *addressCom) {
            if (weakself.completionBlock){
                weakself.completionBlock(location, addressCom, nil);
            }
        } searchFailHandle:^{
            NSError *error = [[NSError alloc] initWithDomain:@"反地理编码失败" code:2000 userInfo:nil];
            if (weakself.completionBlock){
                weakself.completionBlock(nil, nil, error);
            }
        }];
    }else {
        if (error == nil){
            error = [[NSError alloc] initWithDomain:@"定位失败" code:3000 userInfo:nil];
        }
        if (self.completionBlock){
            self.completionBlock(nil, nil, error);
        }
    }
}
/// 检测一定时间之内只允许执行一次  防止定位多次调用
- (BOOL)checkAllowLocationAgainWithDate:(NSDate *)date{
    return (date == nil || [[NSDate date] timeIntervalSinceDate:date] > 60 * 5);
}
#pragma mark -- 逆向地理编码 (根据经纬度获取城市信息)
- (void)mapReGeocodeSearchByLatitude:(CLLocationDegrees)latitude andLongTitude:(CLLocationDegrees)longtitud searchResultHandle:(NGCSearchResultHandle)searchResultHandle searchFailHandle:(NGCSearchFailHandle)searchFailHandle{
    _searchFailHandle = searchFailHandle;
    _searchResultHandle = searchResultHandle;
    /// 搜索api
    AMapSearchAPI *searchAPI = [[AMapSearchAPI alloc] init];
    searchAPI.delegate = self;
    AMapReGeocodeSearchRequest * regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
    regeoRequest.location  = [AMapGeoPoint locationWithLatitude:latitude longitude:longtitud];
    regeoRequest.radius = 2000;
    regeoRequest.requireExtension = YES;
    [searchAPI AMapReGoecodeSearch:regeoRequest];  // 发起检索
    self.searchAPI = searchAPI;
}
#pragma mark ---  AMapSearchDelegate
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    if (response.regeocode && response.regeocode != (id)kCFNull) {
        AMapReGeocode *regeocode = response.regeocode;
        AMapAddressComponent *addressCom =  regeocode.addressComponent;
        if (_searchResultHandle){
            _searchResultHandle(addressCom);
        }
        /// 更新定位信息
        [self updateLocationInfoWithAddressCom:addressCom];
    }else {
        if (_searchFailHandle){
            _searchFailHandle();
        }
    }
}

/// 更新定位信息
- (void)updateLocationInfoWithAddressCom:(AMapAddressComponent *)addressCom{
    WMLocationInfo *locationInfo = [WMLocationSession shareLocationSession].locationInfo;
    if (locationInfo == nil){
        locationInfo = [[WMLocationInfo alloc] init];
    }
    locationInfo.cityCode = addressCom.citycode;
    locationInfo.zipCode = addressCom.adcode;
    locationInfo.cityName = addressCom.city;
    [WMLocationSession shareLocationSession].locationInfo = locationInfo;
}
- (CLLocationManager *)locMgr{
    if (_locMgr == nil){
        _locMgr = [[CLLocationManager alloc] init];
        //每隔多少米定位一次
        _locMgr.distanceFilter = self.distanceFilter;
        //设置定位的精准度，一般精准度越高，越耗电(将周围一定值的范围看作一个地点)
        _locMgr.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locMgr.delegate = self;
        if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)) {
            [_locMgr requestWhenInUseAuthorization];
        }
    }
    return _locMgr;
}

@end
