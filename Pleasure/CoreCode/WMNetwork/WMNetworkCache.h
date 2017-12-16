//
//  WMNetworkCache.h
//  Pleasure
//
//  Created by Sper on 2017/12/13.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMNetworkCache : NSObject

/**
 根据请求获取缓存数据

 @param requestAdapter 满足协议的请求对象
 @return 请求对象
 */
+ (id)httpCacheForRequest:(id<WMRequestAdapterProtocol>)requestAdapter;

/**
 把数据缓存下来

 @param request 请求对象
 */
+ (void)setHttpCacheWithRequest:(WMRequestAdapter *)request;

/// 获取网络缓存的总大小 bytes(字节)
+ (NSInteger)getAllHttpCacheSize;

/// 删除所有网络缓存
+ (void)removeAllHttpCache;

@end
