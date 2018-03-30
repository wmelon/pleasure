//
//  WMDeviceUsageMonitor.h
//  Pleasure
//
//  Created by Sper on 2018/2/8.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WMDeviceInfo;
@interface WMDeviceInfo : NSObject
@property (nonatomic , assign) CGFloat cpu;
@property (nonatomic , assign) double curMemUsage;
@property (nonatomic , assign) double freeMemory;
@property (nonatomic , assign) NSInteger fps;
+ (instancetype)deviceInfoWithFps:(NSInteger)fps cpu:(CGFloat)cpu curMemUsage:(double)curMemUsage freeMemory:(double)freeMemory;
@end

typedef void(^WMDeviceUsageHandle)(WMDeviceInfo *deviceInfo);
@interface WMDeviceUsageMonitor : NSObject
+ (instancetype)shareDeviceUsage;
- (void)startDeviceUsage:(WMDeviceUsageHandle)deviceHandle;
- (void)stopDeviceUsage;
@end
