//
//  WMFpsMonitor.h
//  Pleasure
//
//  Created by Sper on 2018/3/6.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WMFpsMonitorHandle)(int fpsUsage);
@interface WMFpsMonitor : NSObject
+ (void)startFpsMonitor:(WMFpsMonitorHandle)fpsHanele;
+ (void)stopFpsMonitor;
@end
