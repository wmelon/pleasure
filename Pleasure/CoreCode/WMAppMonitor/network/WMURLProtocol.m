//
//  WMURLProtocol.m
//  Pleasure
//
//  Created by Sper on 2018/3/14.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMURLProtocol.h"
#import "WMHttpDatasource.h"

/// 设置标志防止循环请求
static NSString * const hasInitKey = @"WMMarkerProtocolKey";

@interface WMURLProtocol()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
@property (nonatomic , strong) NSURLConnection *connection;
@property (nonatomic , strong) NSURLResponse *response;
// 请求开始时间
@property (nonatomic , assign) NSTimeInterval startTime;
@property (nonatomic , assign) NSTimeInterval endTime;
/// 请求返回的数据
@property (nonatomic , strong) NSMutableData *responseData;
@end

@implementation WMURLProtocol

#pragma mark - Override
// 定义拦截请求的URL规则
+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    return ![NSURLProtocol propertyForKey:hasInitKey inRequest:request];
}
+ (BOOL)canInitWithTask:(NSURLSessionTask *)task{
    if (![task.currentRequest.URL.scheme isEqualToString:@"http"] &&
        ![task.currentRequest.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    return ![NSURLProtocol propertyForKey:hasInitKey inRequest:task.currentRequest];
}
// 自定义网络请求 .对于需要修改请求头的请求在该方法中修改
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request{
    NSMutableURLRequest * canonicalRequest = request.mutableCopy;
    return canonicalRequest;
}
// 对于拦截的请求，系统创建一个NSURLProtocol对象执行startLoading方法开始加载请求
- (void)startLoading{
    NSMutableURLRequest *request = self.request.mutableCopy;
    [NSURLProtocol setProperty:@YES forKey:hasInitKey inRequest:request];
    self.connection = [NSURLConnection connectionWithRequest: request delegate: self];
    self.startTime = [[NSDate date] timeIntervalSince1970];
    self.responseData = [NSMutableData data];
}
// 对于拦截的请求，NSURLProtocol对象在停止加载时调用该方法
- (void)stopLoading{
    [self.connection cancel];
    [NSURLProtocol removePropertyForKey:hasInitKey inRequest:self.connection.currentRequest.mutableCopy];
    self.endTime = [[NSDate date] timeIntervalSince1970];
    
    NSURLRequest *httpRequest = self.request;
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)self.response;
    WMAPMHttpModel *httpModel = [WMAPMHttpModel httpModelWithURLRequest:httpRequest urlResponse:httpResponse responseData:self.responseData];
    [httpModel dealWithStartTime:self.startTime endTime:self.endTime];
    [[WMHttpDatasource shareInstance] addHttpRequest:httpModel];
}

#pragma mark -- NSURLConnectionDelegate
//  这个方法里可以做计时的开始
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response{
    return request;
}
//  错误的收集
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self.client URLProtocol: self didFailWithError: error];
}
//  这里可以得到返回包的总大小
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    // 解析 response，流量统计等
    NSLog(@"%@   %f KB" ,response.URL ,(CGFloat)response.expectedContentLength / 1024);
    self.response = response;
    [self.client URLProtocol: self didReceiveResponse: response cacheStoragePolicy: NSURLCacheStorageAllowedInMemoryOnly];
}
//  这里将每次的data累加起来，可以做加载进度圆环之类的
- (void)connection: (NSURLConnection *)connection didReceiveData: (NSData *)data {
//    这个总数据是实际返回内容的数据量  。其实还需要包括请求头数据  和 返回头数据  请求数据
    [self.responseData appendData:data];
    [self.client URLProtocol: self didLoadData: data];
}
//  这里作为结束的时间
- (void)connectionDidFinishLoading: (NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading: self];
}

@end

