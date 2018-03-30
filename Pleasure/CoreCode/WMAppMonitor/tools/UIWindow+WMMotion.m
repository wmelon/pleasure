//
//  UIWindow+WMMotion.m
//  Pleasure
//
//  Created by Sper on 2018/3/15.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "UIWindow+WMMotion.h"
#import "WMMonitor.h"
#import <AudioToolbox/AudioToolbox.h>

static BOOL isStart = YES;
@implementation UIWindow (WMMotion)

- (BOOL)canBecomeFirstResponder{//默认是NO，所以得重写此方法，设成YES
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    /// 这里处理开始摇动
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (event.subtype == UIEventSubtypeMotionShake) { // 判断是否是摇动结束
        if (isStart){
            [WMMonitor stopMonitoring];
        }else {
            [WMMonitor startMonitorAtTest:YES];
        }
        isStart = !isStart;
        [self shakeshake];
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    /// 这里处理取消摇动
}
//  摇动结束后执行震动
- (void)shakeshake {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
@end
