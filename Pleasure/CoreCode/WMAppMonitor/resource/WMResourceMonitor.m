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

static WMResourceMonitor *resourceMonitor;
@interface WMResourceMonitor()
@property (nonatomic , copy) WMResourceMonitorHandle resourceHandle;
@end

@implementation WMResourceMonitor
+ (void)startResourceMonitor:(WMResourceMonitorHandle)resouceHandle{
    if (resourceMonitor == nil){
        resourceMonitor = [[WMResourceMonitor alloc] init];
        resourceMonitor.resourceHandle = resouceHandle;
        
//        [WMAppCpu usageCpu];
//        [WMAppMemory usageMemory];
    }else {
        
    }
}
+ (void)stopResourceMonitor{

}
@end
