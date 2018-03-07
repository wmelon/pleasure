//
//  WMCrashMonitor.h
//  Pleasure
//
//  Created by Sper on 2018/3/7.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMCrashMonitor : NSObject
+ (void)startCrashMonitor;
+ (void)stopCrashMonitor;
@end
