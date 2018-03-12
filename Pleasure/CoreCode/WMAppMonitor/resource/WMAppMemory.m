//
//  WMAppMemory.m
//  Pleasure
//
//  Created by Sper on 2018/3/8.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMAppMemory.h"
#import <mach/mach.h>
#import <mach/task_info.h>

#ifndef NBYTE_PER_MB
#define NBYTE_PER_MB (1024 * 1024)
#endif

@implementation WMAppMemory
+ (WMAppMemoryUsage)usageMemory{
    struct mach_task_basic_info info;
    mach_msg_type_number_t count = sizeof(info) / sizeof(integer_t);
    if (task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &count) == KERN_SUCCESS) {
        return (WMAppMemoryUsage){
            .usage = info.resident_size / NBYTE_PER_MB,
            .total = [NSProcessInfo processInfo].physicalMemory / NBYTE_PER_MB,
            .ratio = info.virtual_size / [NSProcessInfo processInfo].physicalMemory,
        };
    }
    return (WMAppMemoryUsage){ 0 };
}
@end
