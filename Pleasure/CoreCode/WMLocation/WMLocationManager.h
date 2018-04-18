//
//  WMLocationManager.h
//  Pleasure
//
//  Created by Sper on 2018/4/17.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface WMLocationInfo : NSObject
@property (nonatomic , assign) double lat;
@property (nonatomic , assign) double lng;
@property (nonatomic , copy  ) NSString *cityName;
@property (nonatomic , copy  ) NSString *cityCode;
@property (nonatomic , copy  ) NSString *zipCode;
@end

@interface WMLocationSession : NSObject
@property (nonatomic , strong) WMLocationInfo *locationInfo;
+ (instancetype)shareLocationSession;
// 没有开启定位提示
- (void)showNoOpenLocationAlertView;
/// 关闭定位提示
- (void)hiddenNoOpenLocationAlertView;
@end

/**
 获取定位经纬度信息

 @param latitude 定位纬度
 @param longtitud 定位经度
 */
typedef void(^NGCLocationResultHandle)(double latitude, double longtitud);

/**
 获取定位信息失败回调

 @param error 定位失败错误信息
 */
typedef void(^NGCLocationFiledHandle)(NSError *error);

/**
 反地理编码回调block

 @param addressCom 反地理编码返回城市信息
 */
typedef void(^NGCSearchResultHandle)(AMapAddressComponent * addressCom);

/**
 反地理编码失败回调
 */
typedef void(^NGCSearchFailHandle)(void);

/**
 *  @brief AMapLocatingCompletionBlock 单次定位返回Block
 *  @param location 定位信息
 *  @param addressCom 逆地理信息
 *  @param error 错误信息，参考 AMapLocationErrorCode
 */
typedef void (^NGCMapLocatingCompletionBlock)(CLLocation *location, AMapAddressComponent *addressCom, NSError *error);


typedef NS_ENUM(NSInteger , WMLocationOpenTipType) {
    WMLocationOpenTipType_systemOnly, /// app生命周期只允许提示一次
    WMLocationOpenTipType_always /// 只要出现没打开定位就提示
};
@interface WMLocationManager : NSObject

/// 每隔多少米定位一次。默认是1000 如果是0就表示是实时定位
@property (nonatomic , assign) double distanceFilter;

/// 没有开启定位打开定位提示
@property (nonatomic , assign) WMLocationOpenTipType openTipType;

/// 开始定位获取经纬度
- (void)startLocationForLocationResult:(NGCLocationResultHandle)locationResultHandle locationFailedHandle:(NGCLocationFiledHandle)locationFailedHandle;

/// 根据经纬度反地理编码获取城市信息
- (void)mapReGeocodeSearchByLatitude:(double)latitude andLongTitude:(double)longtitud searchResultHandle:(NGCSearchResultHandle)searchResultHandle searchFailHandle:(NGCSearchFailHandle)searchFailHandle;

/// 单次定位返回信息
- (void)requestLocationForCompletionBlock:(NGCMapLocatingCompletionBlock)completionBlock;

@end
