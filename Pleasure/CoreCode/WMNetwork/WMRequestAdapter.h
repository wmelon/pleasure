//
//  WMRequestAdapter.h
//  Pleasure
//
//  Created by Sper on 2017/11/27.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

///  HTTP Request method.
typedef NS_ENUM(NSInteger, WMRequestMethod) {
    WMRequestMethodGET = 0,
    WMRequestMethodPOST,
    WMRequestMethodHEAD,
    WMRequestMethodPUT,
    WMRequestMethodDELETE,
    WMRequestMethodPATCH,
};


@protocol WMRequestAdapterProtocol <NSObject>

/**获取请求参数*/
- (NSDictionary *)getRequestParameter;

/**获取请求地址*/
- (NSString *)getRequestUrl;

/// 请求方式
- (WMRequestMethod)requestMethod;

/**请求成功初始化方法*/
- (void)responseAdapterWithResponseObject:(id)responseObject task:(NSURLSessionDataTask *)task;

/**请求进度初始化方法*/
- (void)responseAdapterWithProgress:(NSProgress *)progress;

/**请求失败初始化方法*/
- (void)responseAdapterWithError:(NSError *)error task:(NSURLSessionDataTask *)task;

@end


@interface WMRequestAdapter : NSObject<WMRequestAdapterProtocol>

/// 请求完成之后的提示信息
@property (nonatomic , copy , readonly)NSString * msg;

/// 请求成功返回数据
@property (nonatomic , strong , readonly)id responseObject;

/// 请求成功返回字典结构数据
@property (nonatomic , strong , readonly)NSDictionary *responseDictionary;

/// 请求返回状态码
@property (nonatomic , assign , readonly)NSInteger statusCode;
/// 请求失败
@property (nonatomic , strong , readonly)NSError * error;
/// 请求进度
@property (nonatomic , strong , readonly)NSProgress *progress;
/// 封装请求数据对象
@property (nonatomic , strong , readonly)WMRequestAdapter * requestAdapter;

/// 初始化请求对象
+ (instancetype)requestWithUrl:(NSString *)requestUrl requestMethod:(WMRequestMethod)requestMethod;

/// 请求参数  这个适用于确定字典不为空的情况
- (void)requestParameters:(NSDictionary *)params;

/// 请求参数
- (void)requestParameterSetValue:(id)value forKey:(NSString *)key;

/// 翻页参数设置
- (void)requestTurnPageParameter:(NSDictionary *)params;


@end
