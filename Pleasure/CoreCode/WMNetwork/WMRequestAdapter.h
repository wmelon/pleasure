//
//  WMRequestAdapter.h
//  Pleasure
//
//  Created by Sper on 2017/11/27.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

///  HTTP 请求方法
typedef NS_ENUM(NSInteger, WMRequestMethod) {
    WMRequestMethodGET = 0,
    WMRequestMethodPOST,
    WMRequestMethodHEAD,
    WMRequestMethodPUT,
    WMRequestMethodDELETE,
    WMRequestMethodPATCH,
    WMRequestMethodDownload
};

@class WMRequestAdapter;

@protocol WMRequestAdapterProtocol <NSObject>

/**获取请求参数*/
- (NSDictionary *)getRequestParameter;

/**获取请求地址   请求时需要加入公共参数  缓存数据不需要添加公共参数*/
- (NSString *)getRequestUrlIsPublicParams:(BOOL)isPublicParams;

/// 请求方式
- (WMRequestMethod)getRequestMethod;

///**请求进度初*/
- (WMRequestAdapter *)responseAdapterWithProgress:(NSProgress *)progress;

/// 请求完成之后方法
- (WMRequestAdapter *)responseAdapterWithResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error;

/// 获取请求队列
- (NSURLSessionTask *)getRequestTask;
/// 设置请求队列
- (void)setRequestTask:(NSURLSessionTask *)task;

@end


@interface WMRequestAdapter : NSObject<WMRequestAdapterProtocol>
/// 当前请求是否失败
@property (nonatomic , assign , readonly , getter=isRequestFail) BOOL requestFail;

/// 请求完成之后的提示信息
@property (nonatomic , copy   , readonly) NSString * msg;

/// 请求成功返回数据
@property (nonatomic , strong , readonly) id responseObject;

/// 请求成功返回字典结构数据
@property (nonatomic , strong , readonly) NSDictionary *responseDictionary;

/// 请求成功返回二进制数据
@property (nonatomic , strong , readonly) NSData *responseData;

/// 请求返回状态码
@property (nonatomic , assign , readonly) NSInteger statusCode;

/// 请求失败
@property (nonatomic , strong , readonly) NSError * error;

/// 请求进度
@property (nonatomic , strong , readonly) NSProgress *progress;

/// 网络请求队列
@property (nonatomic , strong , readonly) NSURLSessionTask *requestTask;

/// 网络请求地址
@property (nonatomic , copy   , readonly) NSString *requestUrl;

/// 网络请求参数
@property (nonatomic , strong , readonly) NSMutableDictionary * parameterDict;

/// 初始化请求对象
+ (instancetype)requestWithUrl:(NSString *)requestUrl requestMethod:(WMRequestMethod)requestMethod;

/// 请求参数  这个适用于确定字典不为空的情况
- (void)requestParameters:(NSDictionary *)params;

/// 请求参数
- (void)requestParameterSetValue:(id)value forKey:(NSString *)key;

/// 是否已经取消请求
- (BOOL)isCancelled;

/// 是否正在请求
- (BOOL)isExecuting;


@end
