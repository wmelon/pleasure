//
//  WMRequestMonitor.m
//  Pleasure
//
//  Created by Sper on 2018/3/6.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMRequestMonitor.h"
#import "NSURLSessionConfiguration+WMURLSessionConfig.h"

static WMRequestMonitor *requestMonitor = nil;
@implementation WMRequestMonitor
+ (instancetype)shareRequestMonitor{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestMonitor = [[WMRequestMonitor alloc] init];
    });
    return requestMonitor;
}
+ (void)startRequestMonitor{
    [NSURLProtocol registerClass:[WMURLProtocol class]];
}
+ (void)stopRequestMonitor{
    if (requestMonitor){
        [NSURLProtocol unregisterClass:[WMURLProtocol class]];
    }
}
@end
