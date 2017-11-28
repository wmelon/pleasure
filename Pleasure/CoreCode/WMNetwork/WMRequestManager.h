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

/** 网络请求接口*/
+ (WMRequestManager *)requestWithSuccessHandler:(RequestCompletionHandle)successHandler progressHandler:(RequestCompletionHandle)progressHandler failureHandler:(RequestCompletionHandle)failureHandler requestAdapter:(id<WMRequestAdapterProtocol>)request;

///  批量网络请求
+ (WMRequestManager *)requestBatchWithSuccessHandler:(BatchRequestCompletionHandle)successHandler failureHandler:(BatchRequestCompletionHandle)failureHandler requestAdapter:(id<WMRequestAdapterProtocol>)request , ... NS_REQUIRES_NIL_TERMINATION ;

/// 取消网络请求
- (void)cancelRequest:(WMRequestAdapter *)request;

/// 取消所有网络请求
- (void)cancelAllRequests;

@end
