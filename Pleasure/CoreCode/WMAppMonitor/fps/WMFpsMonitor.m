//
//  WMFpsMonitor.m
//  Pleasure
//
//  Created by Sper on 2018/3/6.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMFpsMonitor.h"
#import "WMWeakProxy.h"

static WMFpsMonitor *fpsMonitor;

@interface WMFpsMonitor ()
@property (nonatomic , strong) CADisplayLink *displayLink;
@property (nonatomic , assign) NSTimeInterval lastTime;
@property (nonatomic , assign) NSUInteger count;
@property (nonatomic , copy  ) WMFpsMonitorHandle fpsHandle;
@end

@implementation WMFpsMonitor

- (instancetype)init{
    if (self = [super init]){
        self.displayLink = [CADisplayLink displayLinkWithTarget:[WMWeakProxy proxyWithTarget:self] selector:@selector(monitorFps:)];
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [self.displayLink addToRunLoop:runloop forMode:NSRunLoopCommonModes];
        self.lastTime = self.displayLink.timestamp;
        if ([self.displayLink respondsToSelector:@selector(setPreferredFramesPerSecond:)]){
            if (@available(iOS 10.0, *)){
                self.displayLink.preferredFramesPerSecond = 60;
            }
        }else {
            /// 标识间隔多少帧调用一次selector 方法，默认值是1，即每帧都调用一次
            self.displayLink.frameInterval = 1;
        }
        if (![[NSThread currentThread] isMainThread]){
            /// 在主线程里面不能直接执行run方法，不然会卡死界面  但是除了主线程外其他线程的RunLoop默认是不会运行的，必须手动调用
            [runloop run];
        }
    }
    return self;
}
+ (void)startFpsMonitor:(WMFpsMonitorHandle)fpsHandle{
    if (fpsMonitor == nil){
        fpsMonitor = [[WMFpsMonitor alloc] init];
        fpsMonitor.fpsHandle = fpsHandle;
    }
    if (fpsMonitor.displayLink){
        [fpsMonitor.displayLink setPaused:NO];
    }
}
+ (void)stopFpsMonitor{
    if (fpsMonitor.displayLink){
        [fpsMonitor.displayLink setPaused:YES];
        [fpsMonitor.displayLink invalidate];
        fpsMonitor.displayLink = nil;
    }
    fpsMonitor = nil;
}
- (void)monitorFps: (CADisplayLink *)link{
    _count++;
    NSTimeInterval interval = link.timestamp - self.lastTime;
    if (interval < 1) return;
    self.lastTime = link.timestamp;
    double fps = _count / interval;
    _count = 0;
    if (self.fpsHandle){
        self.fpsHandle((int)round(fps));
    }
}
@end
