//
//  WMMonitor.m
//  Pleasure
//
//  Created by Sper on 2018/2/6.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMMonitor.h"
#import "NSURLSessionConfiguration+WMURLSessionConfig.h"
#import "WMMonitorView.h"

@interface WMMonitor()
@property (nonatomic , weak  ) id<WMMonitorDelegate> delegate;
@end

@implementation WMMonitor

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static WMMonitor *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[WMMonitor alloc] init];
    });
    return instance;
}
- (instancetype)init{
    if (self = [super init]){
        
    }
    return self;
}
+ (void)startMonitor{
    [NSURLProtocol registerClass:[WMURLProtocol class]];
    [WMMonitorView showMonitorView];
}

+ (void)startMonitorWithDelegate:(id<WMMonitorDelegate>)delegate{
    [WMMonitor startMonitor];
    [[WMMonitor shareInstance] setDelegate:delegate];
}
+ (void)stopMonitoring{
    [NSURLProtocol unregisterClass:[WMURLProtocol class]];
    [WMMonitorView hiddenMonitorView];
}
@end
