//
//  WMNetworkCache.m
//  Pleasure
//
//  Created by Sper on 2017/12/13.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMNetworkCache.h"
#import <YYCache.h>

static NSString *const kPPNetworkResponseCache = @"kWaterMelonNetworkResponseCache";

@implementation WMNetworkCache
static YYCache *_dataCache;

+ (void)initialize {
    _dataCache = [YYCache cacheWithName:kPPNetworkResponseCache];
}

+ (id)httpCacheForRequest:(id<WMRequestAdapterProtocol>)requestAdapter{
    NSString *URL;
    if ([requestAdapter respondsToSelector:@selector(getRequestUrlIsPublicParams:)]){
        URL = [requestAdapter getRequestUrlIsPublicParams:NO];
    }
    NSDictionary *parameters;
    if ([requestAdapter respondsToSelector:@selector(getRequestParameter)]){
        parameters = [requestAdapter getRequestParameter];
    }
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    return [_dataCache objectForKey:cacheKey];
}

+ (void)setHttpCacheWithRequest:(WMRequestAdapter *)request{
    if (request){
        NSString *URL = request.requestUrl;
        NSDictionary *parameters = request.parameterDict;
        NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
        //异步缓存,不会阻塞主线程
        [_dataCache setObject:request.responseObject forKey:cacheKey withBlock:nil];
    }
    return;
}
+ (NSString *)cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters {
    if(!parameters || parameters.count == 0){return URL;};
    // 将参数字典转换成字符串
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *paraString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    NSString *cacheKey = [NSString stringWithFormat:@"%@%@",URL,paraString];
    
    return [NSString stringWithFormat:@"%ld",cacheKey.hash];
}

+ (NSInteger)getAllHttpCacheSize {
    return [_dataCache.diskCache totalCost];
}

+ (void)removeAllHttpCache {
    [_dataCache.diskCache removeAllObjects];
}

@end
