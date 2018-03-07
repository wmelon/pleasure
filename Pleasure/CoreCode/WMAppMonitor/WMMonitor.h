//
//  WMMonitor.h
//  Pleasure
//
//  Created by Sper on 2018/2/6.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMMonitor : NSObject

/**
 开启app监控

 @param isTest 是否是测试环境，在测试环境下才显示debug视图
 */
+ (void)startMonitorAtTest:(BOOL)isTest;

/// 停止监听
+ (void)stopMonitoring;

@end
