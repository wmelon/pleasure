//
//  WMMemoryMonitor.h
//  Pleasure
//
//  Created by Sper on 2018/3/6.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WMMemoryMonitorHandle)(double memoryUsage);
@interface WMMemoryMonitor : NSObject
+ (void)startMemoryMonitor:(WMMemoryMonitorHandle)memoryHandle;
+ (void)stopMemoryMonitor;
@end
