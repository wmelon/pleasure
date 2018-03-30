//
//  WMMonitor.m
//  Pleasure
//
//  Created by Sper on 2018/2/6.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMMonitor.h"
#import "WMDebugView.h"
#import "WMRequestMonitor.h"
#import "WMCrashMonitor.h"

@interface WMMonitor()
@property (nonatomic , assign) BOOL isTest;
@end

@implementation WMMonitor

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static WMMonitor *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[WMMonitor alloc] init];
    });
    return instance;
}
+ (void)startMonitorAtTest:(BOOL)isTest{
    [WMMonitor shareInstance].isTest = isTest;
    if (isTest){
        /// 显示debug界面
        [WMDebugView showDebugView];
    }
    [WMRequestMonitor startRequestMonitor];
    [WMCrashMonitor startCrashMonitor];
}
+ (void)stopMonitoring{
    if ([WMMonitor shareInstance].isTest){
        [WMDebugView hiddenDebugView];
    }
    [WMRequestMonitor stopRequestMonitor];
    [WMCrashMonitor stopCrashMonitor];
}

@end
