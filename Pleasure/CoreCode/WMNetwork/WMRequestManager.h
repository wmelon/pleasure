//
//  WMRequestManager.h
//  Pleasure
//
//  Created by Sper on 2017/11/27.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMRequestAdapter.h"

typedef void(^RequestCompletionHandle)(WMRequestAdapter *request);
typedef void(^BatchRequestCompletionHandle)(NSArray<WMRequestAdapter *> *requests);

@interface WMRequestManager : NSObject

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
                                 requestAdapter:(id<WMRequestAdapterProtocol>)request;


/**
 不带缓存不带进度的单个网络请求

 @param successHandler 请求成功回调
 @param failureHandler 请求失败回调
 @param request 请求对象
 */
+ (NSURLSessionTask *)requestWithSuccessHandler:(RequestCompletionHandle)successHandler
                                 failureHandler:(RequestCompletionHandle)failureHandler
                                 requestAdapter:(id<WMRequestAdapterProtocol>)request;


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
                                 requestAdapter:(id<WMRequestAdapterProtocol>)request;


/**
 批量异步网络请求  同步回调

 @param successHandler 所有完成请求 并有网络是成功回调
 @param failureHandler 所有请求失败回调
 @param request 请求对象队列
 */
+ (NSArray<NSURLSessionTask *> *)requestBatchWithSuccessHandler:(BatchRequestCompletionHandle)successHandler
                                      failureHandler:(BatchRequestCompletionHandle)failureHandler
                                      requestAdapter:(id<WMRequestAdapterProtocol>)request , ... NS_REQUIRES_NIL_TERMINATION ;


/**
 批量异步网络请求  同步回调
 
 @param successHandler 所有完成请求 并有网络是成功回调
 @param failureHandler 所有请求失败回调
 @param requestAdapters 请求对象数组
 */
+ (NSArray<NSURLSessionTask *> *)requestBatchWithSuccessHandler:(BatchRequestCompletionHandle)successHandler
                        failureHandler:(BatchRequestCompletionHandle)failureHandler
                        requestAdapters:(NSArray<id<WMRequestAdapterProtocol>> *)requestAdapters;

/// 取消网络请求
+ (void)cancelRequest:(WMRequestAdapter *)request;

/// 取消所有网络请求
+ (void)cancelAllRequests;

@end
