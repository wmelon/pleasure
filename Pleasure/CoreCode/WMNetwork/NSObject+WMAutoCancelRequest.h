//
//  NSObject+WMAutoCancelRequest.h
//  Pleasure
//
//  Created by Sper on 2017/12/14.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (WMAutoCancelRequest)

/**
 界面销毁之后自动停止当前界面网络请求

 @param request 当前请求
 */
- (void)autoCancelRequestOnDealloc:(NSURLSessionTask *)request;


/**
 界面销毁之后自动停止当前界面多个网络请求

 @param requests 多个请求
 */
- (void)autoCancelMoreRequestOnDealloc:(NSArray<NSURLSessionTask *> *)requests;

@end
