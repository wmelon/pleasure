//
//  WMCpuMonitor.h
//  Pleasure
//
//  Created by Sper on 2018/3/6.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WMCpuMonitorHandle)(double cpuUsage);
@interface WMCpuMonitor : NSObject
+ (void)startCpuMonitor:(WMCpuMonitorHandle)cpuHandle;
+ (void)stopCpuMonitor;
@end
