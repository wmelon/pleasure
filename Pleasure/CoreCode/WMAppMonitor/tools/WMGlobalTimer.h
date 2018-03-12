//
//  WMGlobalTimer.h
//  Pleasure
//
//  Created by Sper on 2018/3/8.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMGlobalTimer : NSObject

/**
 注册定时器监听回调

 @param callback 回调函数
 @return 注册唯一key值
 */
+ (NSString *)registerTimerCallback:(dispatch_block_t)callback;


/**
 注册定时器监听回调

 @param callback 回调函数
 @param key 注册唯一key值
 */
+ (void)registerTimerCallback: (dispatch_block_t)callback key:(NSString *)key;

/**
 撤销定时器监听回调

 @param key 注册时的key值
 */
+ (void)resignTimerCallbackWithKey:(NSString *)key;
@end
