//
//  WMRequestManager.m
//  Pleasure
//
//  Created by Sper on 2017/11/27.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMRequestManager.h"
#import "AFHTTPSessionManager.h"
#import "WMNetworkCache.h"

@implementation WMRequestManager
static NSMutableDictionary<NSNumber * , id<WMRequestAdapterProtocol>> *_requestRecord;

/**
 所有的HTTP请求共享一个AFHTTPSessionManager

 @return AFHTTPSessionManager
 */
+ (AFHTTPSessionManager *)getManager {
    static AFHTTPSessionManager *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        NSURLSessionConfiguration *configer = [NSURLSessionConfiguration defaultSessionConfiguration];
        configer.timeoutIntervalForRequest = 20.0f;
        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configer];
        _manager.requestSerializer = [self requestSerializer];
        _manager.responseSerializer = [self responseSerializer];
        // AFSSLPinningModeNone 使用证书不验证模式
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        [_manager setSecurityPolicy:securityPolicy];
    });
    return _manager;
}

+ (AFHTTPRequestSerializer *)requestSerializer{
    AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    return requestSerializer;
}
+ (AFHTTPResponseSerializer *)responseSerializer{
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer
                                                    serializerWithReadingOptions:NSJSONReadingAllowFragments];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",nil];
    return responseSerializer;
}

#pragma mark -- 网络请求区域
/**
 带进度的当个网络请求
 
 @param successHandler 请求成功回调
 @param ProgressHandler 请求进度
 @param failureHandler 请求失败回调
 @param request 请求对象
 */
+ (NSURLSessionTask *)requestWithSuccessHandler:(RequestCompletionHandle)successHandler
                  ProgressHandler:(RequestCompletionHandle)ProgressHandler
                   failureHandler:(RequestCompletionHandle)failureHandler
                   requestAdapter:(id<WMRequestAdapterProtocol>)request{
    return [self addRequest:request SuccessHandler:successHandler cacheHandler:nil ProgressHandler:ProgressHandler failureHandler:failureHandler];
}


/**
 不带缓存不带进度的单个网络请求
 
 @param successHandler 请求成功回调
 @param failureHandler 请求失败回调
 @param request 请求对象
 */
+ (NSURLSessionTask *)requestWithSuccessHandler:(RequestCompletionHandle)successHandler
                   failureHandler:(RequestCompletionHandle)failureHandler
                   requestAdapter:(id<WMRequestAdapterProtocol>)request{
    return [self addRequest:request SuccessHandler:successHandler cacheHandler:nil ProgressHandler:nil failureHandler:failureHandler];
}


/**
 带缓存的单个网络请求
 
 @param successHandler 请求成功回调
 @param cacheHandler 缓存数据读取回调
 @param failureHandler 请求失败回调
 @param request 请求对象
 */
+ (NSURLSessionTask *)requestWithSuccessHandler:(RequestCompletionHandle)successHandler
                     cacheHandler:(RequestCompletionHandle)cacheHandler
                   failureHandler:(RequestCompletionHandle)failureHandler
                   requestAdapter:(id<WMRequestAdapterProtocol>)request{
    return [self addRequest:request SuccessHandler:successHandler cacheHandler:cacheHandler ProgressHandler:nil failureHandler:failureHandler];
}

/**
 批量异步网络请求  同步回调
 
 @param successHandler 所有完成请求 并有网络是成功回调
 @param failureHandler 所有请求失败回调
 @param requestAdapters 请求对象数组
 */
+ (NSArray<NSURLSessionTask *> *)requestBatchWithSuccessHandler:(BatchRequestCompletionHandle)successHandler
                        failureHandler:(BatchRequestCompletionHandle)failureHandler
                       requestAdapters:(NSArray<id<WMRequestAdapterProtocol>> *)requestAdapters{
    return [self addBatchRequests:requestAdapters SuccessHandler:successHandler failureHandler:failureHandler];
}
/**
 批量异步网络请求  同步回调
 
 @param successHandler 所有完成请求 并有网络是成功回调
 @param failureHandler 所有请求失败回调
 @param request 请求对象队列
 */
+ (NSArray<NSURLSessionTask *> *)requestBatchWithSuccessHandler:(BatchRequestCompletionHandle)successHandler
                        failureHandler:(BatchRequestCompletionHandle)failureHandler
                        requestAdapter:(id<WMRequestAdapterProtocol>)request , ... NS_REQUIRES_NIL_TERMINATION {
    /// 获取所有的请求
    id eachObject;
    va_list argumentList;
    NSMutableArray<id<WMRequestAdapterProtocol>> *requestArray;
    if (request){
        requestArray = [NSMutableArray arrayWithObjects:request, nil];
        va_start(argumentList, request);
        while ((eachObject = va_arg(argumentList, id))) {
            [requestArray addObject:eachObject];
        }
        va_end(argumentList);
    }
    return [self addBatchRequests:requestArray SuccessHandler:successHandler failureHandler:failureHandler];
}
+ (NSArray<NSURLSessionTask *> *)addBatchRequests:(NSArray<id<WMRequestAdapterProtocol>> *)requestArray SuccessHandler:(BatchRequestCompletionHandle)successHandler failureHandler:(BatchRequestCompletionHandle)failureHandler{
    /// 存储当前发送出来的请求任务
    NSMutableArray<NSURLSessionTask *> *requestTasks = [NSMutableArray arrayWithCapacity:requestArray.count];
    
    /// 是否有请求成功的  (只要有一个请求时成功的就是成功)
    __block BOOL isSuccess = NO;
    dispatch_group_t group = dispatch_group_create();
    [requestArray enumerateObjectsUsingBlock:^(id<WMRequestAdapterProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURLSessionTask *task = [self addRequest:obj SuccessHandler:^(WMRequestAdapter *request) {   /// 批量异步下载  同步更新不需要只要请求进度
            dispatch_group_leave(group);
            isSuccess = YES;
        } cacheHandler:nil ProgressHandler:nil failureHandler:^(WMRequestAdapter *request) {
            dispatch_group_leave(group);
        }];
        
        if (task){
            @synchronized(self) {
                [requestTasks addObject:task];
            }
        }
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        /// 有多少个请求完成标识就得有多少个请求等待
        for (int i = 0 ; i < requestArray.count ; i++){
            dispatch_group_enter(group);
        }
        
        /// 所有请求完成之后的回调 请求对象就是返回对象
        if (isSuccess){
            if (successHandler){
                successHandler(requestArray);
            }
        }else {
            if (failureHandler){
                failureHandler(requestArray);
            }
        }
    });
    
    return requestTasks;
}
/// 添加请求到请求队列
+ (NSURLSessionTask *)addRequest:(id<WMRequestAdapterProtocol>)requestAdapter SuccessHandler:(RequestCompletionHandle)successHandler cacheHandler:(RequestCompletionHandle)cacheHandler ProgressHandler:(RequestCompletionHandle)ProgressHandler failureHandler:(RequestCompletionHandle)failureHandler{
    NSParameterAssert(requestAdapter != nil);

    /// 获取缓存数据缓存
    if (cacheHandler){
        id cacheData = [WMNetworkCache httpCacheForRequest:requestAdapter];
        WMRequestAdapter *resultRequest = [requestAdapter responseAdapterWithResult:[requestAdapter getRequestTask] responseObject:cacheData error:nil];
        if ([resultRequest isKindOfClass:[WMRequestAdapter class]]){
            cacheHandler(resultRequest);
        }
    }
    
    NSURLSessionTask * task = [self sessionTaskForRequest:requestAdapter SuccessHandler:^(WMRequestAdapter *request) {
        if (successHandler){
            successHandler(request);
        }
        /// 存储数据到缓存
        if (cacheHandler && [request isKindOfClass:[WMRequestAdapter class]]){
            [WMNetworkCache setHttpCacheWithRequest:request];
        }
    } ProgressHandler:^(WMRequestAdapter *request) {
        if (ProgressHandler){
            ProgressHandler(request);
        }
    } failureHandler:^(WMRequestAdapter *request) {
        if (failureHandler){
            failureHandler(request);
        }
    }];
    
    [requestAdapter setRequestTask:task];
    NSAssert([requestAdapter getRequestTask] != nil, @"requestTask should not be nil");

    /// 添加请求到请求队列中
    [self addRequestToRecord:requestAdapter];
    /// 开始请求
    [task resume];
    
    return task;
}

/// 开始请求
+ (NSURLSessionTask *)sessionTaskForRequest:(id<WMRequestAdapterProtocol>)requestAdapter SuccessHandler:(RequestCompletionHandle)successHandler ProgressHandler:(RequestCompletionHandle)ProgressHandler failureHandler:(RequestCompletionHandle)failureHandler{
    WMRequestMethod method = [requestAdapter getRequestMethod];
    NSString *requestPath = [requestAdapter getRequestUrl];
    NSDictionary *paramer = [requestAdapter getRequestParameter];

    NSString *requestMethod;
    switch (method) {
        case WMRequestMethodGET:
            requestMethod = @"GET";
            break;
        case WMRequestMethodPOST:
            requestMethod = @"POST";
            break;
        case WMRequestMethodHEAD:
            requestMethod = @"HEAD";
            break;
        case WMRequestMethodPUT:
            requestMethod = @"PUT";
            break;
        case WMRequestMethodDELETE:
            requestMethod = @"DELETE";
            break;
        case WMRequestMethodPATCH:
            requestMethod = @"PATCH";
            break;
    }
    NSLog(@">>>>%@>%@->parameters%@",requestPath, requestMethod ,paramer);

    /*! 发送请求 */
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializer];
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:requestMethod URLString:requestPath parameters:paramer error:nil];

    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [[WMRequestManager getManager] dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        WMRequestAdapter *resultRequest = [requestAdapter responseAdapterWithProgress:uploadProgress];
        if (ProgressHandler){
            ProgressHandler(resultRequest);
        }
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        WMRequestAdapter *resultRequest = [requestAdapter responseAdapterWithProgress:downloadProgress];
        if (ProgressHandler){
            ProgressHandler(resultRequest);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        /// 解析请求结果数据
        WMRequestAdapter *resultRequest = [requestAdapter responseAdapterWithResult:dataTask responseObject:responseObject error:error];
        if (resultRequest.isRequestFail){
            if (failureHandler){
                failureHandler(resultRequest);
            }
        }else {
            if (successHandler){
                successHandler(resultRequest);
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeRequestFromRecord:requestAdapter];
        });
    }];
    return dataTask;
}

/// 请求开始时添加请求到队列中
+ (void)addRequestToRecord:(id<WMRequestAdapterProtocol>)request{
    @synchronized(self) {  /// 保证临界区内的代码线程安全
        self.requestRecord[@([request getRequestTask].taskIdentifier)] = request;
    }
}
/// 请求完成后移除队列中请求
+ (void)removeRequestFromRecord:(id<WMRequestAdapterProtocol>)request{
    @synchronized(self) {
        [self.requestRecord removeObjectForKey:@([request getRequestTask].taskIdentifier)];
    }
}
/// 取消当前请求
+ (void)cancelRequest:(id<WMRequestAdapterProtocol>)request{
    NSParameterAssert(request != nil);
    NSURLSessionTask *task = [request getRequestTask];
    [self removeRequestFromRecord:request];
    [task cancel];
}
/// 取消当前所有请求
+ (void)cancelAllRequests{
    NSArray *allKeys;
    @synchronized(self) {
        allKeys = [self.requestRecord allKeys];
    }
    if (allKeys && allKeys.count > 0) {
        NSArray *copiedKeys = [allKeys copy];
        for (NSNumber *key in copiedKeys) {
            id<WMRequestAdapterProtocol> request;
            @synchronized(self) {
                request = self.requestRecord[key];
            }
            [self cancelRequest:request];
        }
    }
}
/// 存储请求对象
+ (NSMutableDictionary<NSNumber *,id<WMRequestAdapterProtocol>> *)requestRecord{
    if (_requestRecord == nil){
        _requestRecord = [NSMutableDictionary dictionary];
    }
    return _requestRecord;
}

@end
