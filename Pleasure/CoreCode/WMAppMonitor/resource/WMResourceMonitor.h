//
//  WMResourceMonitor.h
//  Pleasure
//
//  Created by Sper on 2018/3/8.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WMResourceMonitorHandle)(double cpuUsage , double memoryUsage);
@interface WMResourceMonitor : NSObject
+ (void)startResourceMonitor:(WMResourceMonitorHandle)resouceHandle;
+ (void)stopResourceMonitor;
@end
