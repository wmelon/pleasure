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
@property (nonatomic , copy) NSString *requestUrl;
@property (nonatomic , assign) WMRequestMethod requestMethod;
@property (nonatomic , strong) NSMutableDictionary * parameterDict;
@end

@implementation WMRequestAdapter

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

/**请求成功初始化方法*/
- (void)responseAdapterWithResponseObject:(id)responseObject task:(NSURLSessionDataTask *)task{
    [self responseAdapterWithTask:task responseObject:responseObject error:nil progress:nil];
}

/**请求进度初始化方法*/
- (void)responseAdapterWithProgress:(NSProgress *)progress{
    [self responseAdapterWithTask:nil responseObject:nil error:nil progress:progress];
}

/**请求失败初始化方法*/
- (void)responseAdapterWithError:(NSError *)error task:(NSURLSessionDataTask *)task{
    [self responseAdapterWithTask:task responseObject:nil error:error progress:nil];
}
- (void)responseAdapterWithTask:(NSURLSessionDataTask *)task responseObject:(id)responseObject error:(NSError *)error progress:(NSProgress *)progress{
    _progress = progress;
    if (responseObject){
        _responseObject = responseObject;
        if ([responseObject isKindOfClass:[NSDictionary class]]){
            ///  请求返回的数据是字典格式
            _responseDictionary = responseObject;
            /// 成功提示信息
            _msg = [self msgWithDict:_responseDictionary];
            _statusCode = [self bizCodeWithDict:_responseDictionary];
        }
        [self requestSuccessResObj:responseObject task:task];
    }
    if (error){
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)task.response;
        _error = [NSError getError:error resp:resp];
        _statusCode = resp.statusCode;
        /// 错误提示信息
        _msg = [self showErrorMessageWithError:_error withCode:resp.statusCode];
        [self requestFailureTask:task error:error];
    }
}

- (NSString *)msgWithDict:(NSDictionary *)dict{
    NSString * msg;
    if ([[dict objectForKey:@"msg"] isKindOfClass:[NSString class]]){
        msg = [dict objectForKey:@"msg"];
    }
    return msg;
}
- (NSInteger)bizCodeWithDict:(NSDictionary *)dict {
    return [[dict objectForKey:@"bizCode"] integerValue];
}

#pragma mark -- private methods

- (void)requestSuccessResObj:(NSDictionary *)resObj task:(NSURLSessionDataTask *)task {
    NSLog(@"😄😄😄请求成功%@===>responseObject%@",task.currentRequest.URL.absoluteString, resObj);
    [self requestSuccessOrFailureWithTask:task];
}

- (void)requestFailureTask:(NSURLSessionDataTask *)task error:(NSError *)error{
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)task.response;
    NSLog(@"😂😂😂请求失败%@===>statusCode:%zd",task.currentRequest.URL.absoluteString,resp.statusCode);
    [self requestSuccessOrFailureWithTask:task];
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


#pragma mark - 请求成功或失败后的操作
- (void)requestSuccessOrFailureWithTask:(NSURLSessionDataTask *)task{
    /*! 存储服务器当前的时间 */
    [self saveServerDateWithTask:task];
}

#pragma mark - 存储当前服务器的日期
- (void)saveServerDateWithTask:(NSURLSessionDataTask *)task {
    //    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)task.response;
    //    NSString *lastUpdate = resp.allHeaderFields[@"Date"];
    //    NSDate *date = [NSDate dateFromRFC822String:lastUpdate];
    //    NSInteger tmp = [date timeIntervalSinceDate:[NSDate date]];
    //    [NGCAppDataManager defaultManager].timeInterval = tmp;
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
    return @"";
}
- (WMRequestMethod)requestMethod{
    return self.requestMethod;
}

#pragma mark -- getter
- (NSMutableDictionary *)parameterDict{
    if (_parameterDict == nil){
        _parameterDict = [NSMutableDictionary dictionary];
    }
    return _parameterDict;
}
@end
