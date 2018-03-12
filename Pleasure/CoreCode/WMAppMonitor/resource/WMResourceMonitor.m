//
//  WMResourceMonitor.m
//  Pleasure
//
//  Created by Sper on 2018/3/8.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMResourceMonitor.h"
#import "WMAppCpu.h"
#import "WMAppMemory.h"
#import "WMGlobalTimer.h"

// 定时器监听key
static NSString * wm_resource_monitor_callback_key;

@implementation WMResourceMonitor
+ (void)startResourceMonitor:(WMResourceMonitorHandle)resouceHandle{
    if (wm_resource_monitor_callback_key) return;
    wm_resource_monitor_callback_key = [WMGlobalTimer registerTimerCallback:^{
        double usageCpu = [WMAppCpu usageCpu];
        WMAppMemoryUsage usageMemory = [WMAppMemory usageMemory];
        if (resouceHandle){
            resouceHandle(usageCpu , usageMemory.usage);
        }
    }];
}
+ (void)stopResourceMonitor{
    if (wm_resource_monitor_callback_key == nil) return;
    [WMGlobalTimer resignTimerCallbackWithKey:wm_resource_monitor_callback_key];
    wm_resource_monitor_callback_key = nil;
}
@end
