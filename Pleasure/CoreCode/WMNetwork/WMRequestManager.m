//
//  WMRequestManager.m
//  Pleasure
//
//  Created by Sper on 2017/11/27.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMRequestManager.h"
#import "AFHTTPSessionManager.h"


@interface WMRequestManager()

@end

@implementation WMRequestManager

+ (AFHTTPSessionManager *)getManager {
    static AFHTTPSessionManager *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        NSURLSessionConfiguration *configer = [NSURLSessionConfiguration defaultSessionConfiguration];
        configer.timeoutIntervalForRequest = 20.0f;
        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configer];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [AFJSONResponseSerializer
                                       serializerWithReadingOptions:NSJSONReadingAllowFragments];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",nil];
        // AFSSLPinningModeNone 使用证书不验证模式
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        [_manager setSecurityPolicy:securityPolicy];
    });
    return _manager;
}

+ (WMRequestManager *)requestWithSuccessHandler:(RequestCompletionHandle)successHandler progressHandler:(RequestCompletionHandle)progressHandler failureHandler:(RequestCompletionHandle)failureHandler requestAdapter:(id<WMRequestAdapterProtocol>)request {

    return [[self alloc] initWithSuccessHandler:successHandler progressHandler:progressHandler failureHandler:failureHandler requestAdapter:request];
}

+ (WMRequestManager *)requestBatchWithSuccessHandler:(BatchRequestCompletionHandle)successHandler failureHandler:(BatchRequestCompletionHandle)failureHandler requestAdapter:(id<WMRequestAdapterProtocol>)request , ... NS_REQUIRES_NIL_TERMINATION {
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
    return [[self alloc] initWithBatchSuccessHandler:successHandler failureHandler:failureHandler requestAarray:requestArray];
}
- (instancetype)initWithBatchSuccessHandler:(BatchRequestCompletionHandle)successHandler failureHandler:(BatchRequestCompletionHandle)failureHandler requestAarray:(NSArray<id<WMRequestAdapterProtocol>> *)requestArray{
    if (self = [super init]){
        /// 是否有请求时失败的  只要有一个请求时失败就反正这次批量处理失败
        __block BOOL isFilure = NO;
        dispatch_group_t group = dispatch_group_create();
        NSMutableArray<WMRequestAdapter *> *requests = [NSMutableArray arrayWithCapacity:requestArray.count];
        [requestArray enumerateObjectsUsingBlock:^(id<WMRequestAdapterProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_group_enter(group);
            [self sessionTaskForRequest:obj SuccessHandler:^(WMRequestAdapter *request) {
                
            } progressHandler:nil failureHandler:^(WMRequestAdapter *request) {
                isFilure = YES;
                dispatch_group_leave(group);
                [requests addObject:request];
            }];
        }];
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            NSLog(@"完成了所有网络请求，不管网络请求失败了还是成功了。");
            if (isFilure){
                if (failureHandler){
                    failureHandler(requests);
                }
            }else {
                if (successHandler){
                    successHandler(requests);
                }
            }
        });
    }
    return self;
}

- (instancetype)initWithSuccessHandler:(RequestCompletionHandle)successHandler progressHandler:(RequestCompletionHandle)progressHandler failureHandler:(RequestCompletionHandle)failureHandler requestAdapter:(id<WMRequestAdapterProtocol>)request{
    if (self = [super init]){
        if (request){
            [self sessionTaskForRequest:request SuccessHandler:^(WMRequestAdapter *request) {
                if (successHandler){
                    successHandler(request);
                }
            } progressHandler:^(WMRequestAdapter *request) {
                if (progressHandler){
                    progressHandler(request);
                }
            } failureHandler:^(WMRequestAdapter *request) {
                if (failureHandler){
                    failureHandler(request);
                }
            }];
        }
    }
    return self;
}
- (AFHTTPRequestSerializer *)requestSerializerForRequest:(WMRequestAdapter *)request {
    AFHTTPRequestSerializer *requestSerializer = nil;
    //    if (request.requestSerializerType == YTKRequestSerializerTypeHTTP) {
    //        requestSerializer = [AFHTTPRequestSerializer serializer];
    //    } else if (request.requestSerializerType == YTKRequestSerializerTypeJSON) {
    //        requestSerializer = [AFJSONRequestSerializer serializer];
    //    }
    //
    //    requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    //    requestSerializer.allowsCellularAccess = [request allowsCellularAccess];
    //
    //    // If api needs server username and password
    //    NSArray<NSString *> *authorizationHeaderFieldArray = [request requestAuthorizationHeaderFieldArray];
    //    if (authorizationHeaderFieldArray != nil) {
    //        [requestSerializer setAuthorizationHeaderFieldWithUsername:authorizationHeaderFieldArray.firstObject
    //                                                          password:authorizationHeaderFieldArray.lastObject];
    //    }
    //
    //    // If api needs to add custom value to HTTPHeaderField
    //    NSDictionary<NSString *, NSString *> *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    //    if (headerFieldValueDictionary != nil) {
    //        for (NSString *httpHeaderField in headerFieldValueDictionary.allKeys) {
    //            NSString *value = headerFieldValueDictionary[httpHeaderField];
    //            [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
    //        }
    //    }
    return requestSerializer;
}

- (NSURLSessionTask *)sessionTaskForRequest:(WMRequestAdapter *)requestAdapter SuccessHandler:(RequestCompletionHandle)successHandler progressHandler:(RequestCompletionHandle)progressHandler failureHandler:(RequestCompletionHandle)failureHandler{
    
    WMRequestMethod method = [requestAdapter requestMethod];
    NSString *requestPath = [requestAdapter getRequestUrl];
    NSDictionary *paramer = [requestAdapter getRequestParameter];
    
    NSString *requestMethod;
    switch (method) {
        case WMRequestMethodGET:
            requestMethod = @"GET";
        case WMRequestMethodPOST:
            requestMethod = @"POST";
        case WMRequestMethodHEAD:
            requestMethod = @"HEAD";
        case WMRequestMethodPUT:
            requestMethod = @"PUT";
        case WMRequestMethodDELETE:
            requestMethod = @"DELETE";
        case WMRequestMethodPATCH:
            requestMethod = @"PATCH";
    }
    NSLog(@">>>>%@>%@->parameters%@",requestPath, requestMethod ,paramer);
    
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializerForRequest:requestAdapter];
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:requestMethod URLString:requestPath parameters:paramer error:nil];
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [[WMRequestManager getManager] dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        [requestAdapter responseAdapterWithProgress:uploadProgress];
        if (progressHandler){
            progressHandler(requestAdapter);
        }
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        [requestAdapter responseAdapterWithProgress:downloadProgress];
        if (progressHandler){
            progressHandler(requestAdapter);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [self handleRequestResult:dataTask responseObject:responseObject error:error];
//        [requestAdapter responseAdapterWithResponseObject:<#(id)#> task:<#(NSURLSessionDataTask *)#>];
    }];
    
    return dataTask;
}

- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
    
    // When the request is cancelled and removed from records, the underlying
    // AFNetworking failure callback will still kicks in, resulting in a nil `request`.
    //
    // Here we choose to completely ignore cancelled tasks. Neither success or failure
    // callback will be called.
    //    if (!request) {
    //        return;
    //    }
    //
    //    YTKLog(@"Finished Request: %@", NSStringFromClass([request class]));
    //
    //    NSError * __autoreleasing serializationError = nil;
    //    NSError * __autoreleasing validationError = nil;
    //
    //    NSError *requestError = nil;
    //    BOOL succeed = NO;
    //
    //    request.responseObject = responseObject;
    //    if ([request.responseObject isKindOfClass:[NSData class]]) {
    //        request.responseData = responseObject;
    //        request.responseString = [[NSString alloc] initWithData:responseObject encoding:[YTKNetworkUtils stringEncodingWithRequest:request]];
    //
    //        switch (request.responseSerializerType) {
    //            case YTKResponseSerializerTypeHTTP:
    //                // Default serializer. Do nothing.
    //                break;
    //            case YTKResponseSerializerTypeJSON:
    //                request.responseObject = [self.jsonResponseSerializer responseObjectForResponse:task.response data:request.responseData error:&serializationError];
    //                request.responseJSONObject = request.responseObject;
    //                break;
    //            case YTKResponseSerializerTypeXMLParser:
    //                request.responseObject = [self.xmlParserResponseSerialzier responseObjectForResponse:task.response data:request.responseData error:&serializationError];
    //                break;
    //        }
    //    }
    //    if (error) {
    //        succeed = NO;
    //        requestError = error;
    //    } else if (serializationError) {
    //        succeed = NO;
    //        requestError = serializationError;
    //    } else {
    //        succeed = [self validateResult:request error:&validationError];
    //        requestError = validationError;
    //    }
    //
    //    if (succeed) {
    //        [self requestDidSucceedWithRequest:request];
    //    } else {
    //        [self requestDidFailWithRequest:request error:requestError];
    //    }
    //
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self removeRequestFromRecord:request];
    //        [request clearCompletionBlock];
    //    });
}
- (void)cancelRequest:(WMRequestAdapter *)request{
    
}

- (void)cancelAllRequests{
    
}
@end
