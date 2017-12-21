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
- (void)autoCancelRequestOnDealloc:(MKRequestTask *)request;

@end
