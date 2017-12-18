//
//  WMRequestAdapter.m
//  Pleasure
//
//  Created by Sper on 2017/11/27.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMRequestAdapter.h"

@interface NSError (Extension)
+ (NSError *)getError:(NSError *)error resp:(NSHTTPURLResponse *)resp;
@end

@implementation NSError (Extension)

#pragma mark - 处理请求失败信息
+ (NSError *)getError:(NSError *)error resp:(NSHTTPURLResponse *)resp {
    
    NSDictionary *dict;
    if (error.userInfo[@"NSUnderlyingError"]) {
        NSError *errors = error.userInfo[@"NSUnderlyingError"];
        dict = errors.userInfo;
    }else {
        dict = error.userInfo;
    }
    NSString *errorInfo = [[NSString alloc] initWithData:dict[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
    return [[NSError alloc]initWithDomain:[self erroInfo:errorInfo statusCode:resp.statusCode] code:resp.statusCode userInfo:nil];
}

+ (NSString *)erroInfo:(NSString *)erroInfo statusCode:(NSInteger)statusCode{
    if(statusCode == 401 || [erroInfo rangeOfString:@"HTTP Status 401"].length){
        erroInfo = @"请重新登录";
    }
    if ([erroInfo rangeOfString:@"<html>"].location != NSNotFound){
        erroInfo = @"服务器异常，请稍后再试";
    }
    if (!statusCode){
        erroInfo = @"亲,你的网络好像有问题哦~";
    }
    return erroInfo;
}

@end

@interface WMRequestAdapter()
@property (nonatomic , assign) WMRequestMethod requestMethod;
@end

@implementation WMRequestAdapter

@synthesize parameterDict = _parameterDict;

+ (instancetype)requestWithUrl:(NSString *)requestUrl requestMethod:(WMRequestMethod)requestMethod{
    return [[self alloc] initWithRequestUrl:requestUrl requestMethod:requestMethod];
}

- (instancetype)initWithRequestUrl:(NSString *)requestUrl requestMethod:(WMRequestMethod)requestMethod{
    if (self = [super init]){
        _requestUrl = requestUrl;
        _requestMethod = requestMethod;
    }
    return self;
}

- (NSString *)msgWithDict:(NSDictionary *)dict{
    NSString * msg;
    if ([[dict objectForKey:@"msg"] isKindOfClass:[NSString class]]){
        msg = [dict objectForKey:@"msg"];
    }
    return msg;
}

#pragma mark -- private methods

- (void)requestSuccessResObj:(NSDictionary *)resObj task:(NSURLSessionTask *)task {
    if (task){
        NSLog(@"😄😄😄 %@ 请求成功 %@ ===> responseObject %@",self ,task.currentRequest.URL.absoluteString, resObj);
    }
}

- (void)requestFailureTask:(NSURLSessionTask *)task error:(NSError *)error{
    if (task){
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)task.response;
        NSLog(@"😂😂😂 %@ 请求失败 %@ ===> statusCode: %zd",self ,task.currentRequest.URL.absoluteString,resp.statusCode);
    }
}

/// 解析请求错误提示文案
- (NSString *)showErrorMessageWithError:(NSError *)error withCode:(NSInteger)code{
    NSString * showStr = [self dictWithString:error.domain][@"msg"];
    if (showStr){
        return showStr;
    }else {
        return error.domain;
    }
}
//字符串转字典
- (NSDictionary *)dictWithString:(NSString *)string{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers) error:nil];
}

#pragma mark -- 请求参数相关
///**需要翻页的接口必须采用这种方式创建请求对象*/
- (void)requestTurnPageParameter:(NSDictionary *)params{
    /// 添加翻页需要参数
    [self.parameterDict setValuesForKeysWithDictionary:params];
}
- (void)requestParameters:(NSDictionary *)params{
    [self.parameterDict setValuesForKeysWithDictionary:params];
}
- (void)requestParameterSetValue:(id)value forKey:(NSString *)key{
    [self.parameterDict setValue:value forKey:key];
}

#pragma mark -- WMRequestAdapterProtocol方法
- (NSDictionary *)getRequestParameter{
    return self.parameterDict;
}

- (NSString *)getRequestUrl{
    return self.requestUrl;
}
- (WMRequestMethod)getRequestMethod{
    return self.requestMethod;
}

- (WMRequestAdapter *)responseAdapterWithProgress:(NSProgress *)progress{
    _progress = progress;
    return self;
}
- (NSURLSessionTask *)getRequestTask{
    return _requestTask;
}
- (void)setRequestTask:(NSURLSessionTask *)task{
    _requestTask = task;
}
/// 请求完成之后方法
- (WMRequestAdapter *)responseAdapterWithResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error{
    /// 请求完成之后更新请求队列
    _requestTask = task;

    NSError * __autoreleasing serializationError = nil;

    NSError *requestError = nil;
    _responseObject = responseObject;

    if ([_responseObject isKindOfClass:[NSData class]]) {
        _responseData = responseObject;
    }else if ([_responseObject isKindOfClass:[NSDictionary class]]){
        _responseDictionary = _responseObject;
    }
    if (error) {  /// 请求数据错误
        _requestFail = YES;
        requestError = error;
    } else if (serializationError) {  /// 解析数据错误
        _requestFail = YES;
        requestError = serializationError;
    } else {
        _requestFail = NO;
    }
    
    if (requestError){
        [self parsingErrorWithTask:task error:requestError];
    }else {
        /// 成功提示信息
        _msg = [self msgWithDict:_responseDictionary];
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)task.response;
        _statusCode = resp.statusCode;
        [self requestSuccessResObj:responseObject task:task];
    }

    return self;
}
/// 解析请求错误
- (void)parsingErrorWithTask:(NSURLSessionTask *)task error:(NSError *)error{
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)task.response;
    _error = [NSError getError:error resp:resp];
    _statusCode = resp.statusCode;

    /// 错误提示信息
    _msg = [self showErrorMessageWithError:_error withCode:resp.statusCode];
    [self requestFailureTask:task error:error];
}


- (BOOL)isCancelled {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateCanceling;
}

- (BOOL)isExecuting {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateRunning;
}

#pragma mark -- getter
- (NSMutableDictionary *)parameterDict{
    if (_parameterDict == nil){
        _parameterDict = [NSMutableDictionary dictionary];
    }
    return _parameterDict;
}
- (void)dealloc{
    if ([self.requestTask isKindOfClass:[NSURLSessionTask class]]){
        [self.requestTask cancel];
    }
}
@end
