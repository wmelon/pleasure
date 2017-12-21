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

@interface MKRequestTask()
@property(strong, nonatomic) NSArray *sessionTaskOrOperationArray;
@property(strong, nonatomic) id sessionTaskOrOperation;
@end

@implementation MKRequestTask

- (instancetype)initWithTaskOrOperation:(id)sessionTaskOrOperation{
    if (self = [super init]){
        _sessionTaskOrOperation = sessionTaskOrOperation;
    }
    return self;
}

- (instancetype)initWithTaskOrOperationArray:(NSArray *)sessionTaskOrOperationArray{
    self = [super init];
    if (self) {
        _sessionTaskOrOperationArray = sessionTaskOrOperationArray;
    }
    return self;
}
/// 取消所有当前的网络请求
- (void)cancel{
    if (_sessionTaskOrOperation){
        [self cancelRequestWithObj:_sessionTaskOrOperation];
    }
    [_sessionTaskOrOperationArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self cancelRequestWithObj:obj];
    }];
}
- (void)cancelRequestWithObj:(id)obj{
    if ([obj respondsToSelector:@selector(cancel)]) {
        [obj cancel];
    }
}
@end

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
+ (MKRequestTask *)requestWithSuccessHandler:(RequestCompletionHandle)successHandler
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
+ (MKRequestTask *)requestWithSuccessHandler:(RequestCompletionHandle)successHandler
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
+ (MKRequestTask *)requestWithSuccessHandler:(RequestCompletionHandle)successHandler
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
+ (MKRequestTask *)requestBatchWithSuccessHandler:(BatchRequestCompletionHandle)successHandler
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
+ (MKRequestTask *)requestBatchWithSuccessHandler:(BatchRequestCompletionHandle)successHandler
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

+ (MKRequestTask *)addBatchRequests:(NSArray<id<WMRequestAdapterProtocol>> *)requestArray SuccessHandler:(BatchRequestCompletionHandle)successHandler failureHandler:(BatchRequestCompletionHandle)failureHandler{
    /// 存储当前发送出来的请求任务
    NSMutableArray<MKRequestTask *> *requestTasks = [NSMutableArray arrayWithCapacity:requestArray.count];
    
    /// 是否有请求成功的  (只要有一个请求时成功的就是成功)
    __block BOOL isSuccess = NO;
    dispatch_group_t group = dispatch_group_create();
    for (id<WMRequestAdapterProtocol> obj in requestArray) {
        
        /// 有多少个请求完成标识就得有多少个请求等待
        dispatch_group_enter(group);
        MKRequestTask *task = [self addRequest:obj SuccessHandler:^(WMRequestAdapter *request) {   /// 批量异步下载  同步更新不需要只要请求进度
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
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^(){
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
    
    return [[MKRequestTask alloc] initWithTaskOrOperationArray:requestTasks];
}
/// 添加请求到请求队列
+ (MKRequestTask *)addRequest:(id<WMRequestAdapterProtocol>)requestAdapter SuccessHandler:(RequestCompletionHandle)successHandler cacheHandler:(RequestCompletionHandle)cacheHandler ProgressHandler:(RequestCompletionHandle)ProgressHandler failureHandler:(RequestCompletionHandle)failureHandler{
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
    
    return [[MKRequestTask alloc] initWithTaskOrOperation:task];
}

/// 开始请求
+ (NSURLSessionTask *)sessionTaskForRequest:(id<WMRequestAdapterProtocol>)requestAdapter
                             SuccessHandler:(RequestCompletionHandle)successHandler
                            ProgressHandler:(RequestCompletionHandle)ProgressHandler
                             failureHandler:(RequestCompletionHandle)failureHandler{
    WMRequestMethod method = WMRequestMethodGET;
    if ([requestAdapter respondsToSelector:@selector(getRequestMethod)]){
        method = [requestAdapter getRequestMethod];
    }
    NSString *requestPath = @"";
    if ([requestAdapter respondsToSelector:@selector(getRequestUrlIsPublicParams:)]){
        requestPath = [requestAdapter getRequestUrlIsPublicParams:YES];
    }
    NSDictionary *paramer;
    if ([requestAdapter respondsToSelector:@selector(getRequestParameter)]){
        paramer = [requestAdapter getRequestParameter];
    }

    AFHTTPRequestSerializer *requestSerializer = [self requestSerializer];
    
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
        case WMRequestMethodDownload:
            NSLog(@">>>> %@ > %@ -> parameters %@",requestPath, @"download" ,paramer);
            return [self downloadTaskWithDownloadPath:requestPath requestSerializer:requestSerializer URLString:requestPath parameters:paramer Request:requestAdapter SuccessHandler:successHandler ProgressHandler:ProgressHandler failureHandler:failureHandler];
            break;
    }
    NSLog(@">>>> %@ > %@ -> parameters %@",requestPath, requestMethod ,paramer);

    return [self dataTaskWithHTTPMethod:requestMethod Request:requestAdapter requestSerializer:requestSerializer URLString:requestPath parameters:paramer SuccessHandler:successHandler ProgressHandler:ProgressHandler failureHandler:failureHandler];
}

/// 下载请求
+ (NSURLSessionDownloadTask *)downloadTaskWithDownloadPath:(NSString *)downloadPath
                                         requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                                 URLString:(NSString *)requestPath
                                                parameters:(id)paramer
                                                   Request:(id<WMRequestAdapterProtocol>)requestAdapter
                                            SuccessHandler:(RequestCompletionHandle)successHandler
                                           ProgressHandler:(RequestCompletionHandle)ProgressHandler
                                            failureHandler:(RequestCompletionHandle)failureHandler{
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"GET" URLString:requestPath parameters:paramer error:nil];
    __block NSURLSessionDownloadTask *downloadTask = nil;
    /// 这里处理断点续传 和 本地视频存储
    
    downloadTask = [[WMRequestManager getManager] downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        [self handleRequestProgress:downloadProgress ProgressHandler:ProgressHandler Request:requestAdapter];
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return nil;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [self handleRequestResult:downloadTask responseObject:filePath error:error Request:requestAdapter SuccessHandler:successHandler failureHandler:failureHandler];
    }];
    
    return downloadTask;
}
/*! 发送请求 */
+ (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)requestMethod
                                         Request:(id<WMRequestAdapterProtocol>)requestAdapter
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)requestPath
                                      parameters:(id)paramer
                                  SuccessHandler:(RequestCompletionHandle)successHandler
                                 ProgressHandler:(RequestCompletionHandle)ProgressHandler
                                  failureHandler:(RequestCompletionHandle)failureHandler{
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:requestMethod URLString:requestPath parameters:paramer error:nil];
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [[WMRequestManager getManager] dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        [self handleRequestProgress:uploadProgress ProgressHandler:ProgressHandler Request:requestAdapter];
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        [self handleRequestProgress:downloadProgress ProgressHandler:ProgressHandler Request:requestAdapter];
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [self handleRequestResult:dataTask responseObject:responseObject error:error Request:requestAdapter SuccessHandler:successHandler failureHandler:failureHandler];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeRequestFromRecord:requestAdapter];
        });
    }];
    return dataTask;
}
+ (void)handleRequestProgress:(NSProgress *)progress ProgressHandler:(RequestCompletionHandle)ProgressHandler Request:(id<WMRequestAdapterProtocol>)requestAdapter{
    WMRequestAdapter *resultRequest;
    if ([requestAdapter respondsToSelector:@selector(responseAdapterWithProgress:)]){
        resultRequest = [requestAdapter responseAdapterWithProgress:progress];
    }
    if (ProgressHandler){
        ProgressHandler(resultRequest);
    }
}
+ (void)handleRequestResult:(NSURLSessionTask *)task
             responseObject:(id)responseObject
                      error:(NSError *)error
                    Request:(id<WMRequestAdapterProtocol>)requestAdapter
             SuccessHandler:(RequestCompletionHandle)successHandler
             failureHandler:(RequestCompletionHandle)failureHandler{
    /// 解析请求结果数据
    WMRequestAdapter *resultRequest;
    if ([requestAdapter respondsToSelector:@selector(responseAdapterWithResult:responseObject:error:)]){
        resultRequest = [requestAdapter responseAdapterWithResult:task responseObject:responseObject error:error];
    }
    if (resultRequest.isRequestFail){
        if (failureHandler){
            failureHandler(resultRequest);
        }
    }else {
        if (successHandler){
            successHandler(resultRequest);
        }
    }
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
