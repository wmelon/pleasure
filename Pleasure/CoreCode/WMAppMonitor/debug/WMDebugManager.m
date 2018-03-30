//
//  WMDebugManager.m
//  Pleasure
//
//  Created by Sper on 2018/3/13.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMDebugManager.h"
#import "WMDebugViewController.h"
#import "WMMonitorNavigationController.h"

#define kAnimatedDuration 0.25
static WMDebugManager *debugManager;
@interface WMDebugManager()
@property (nonatomic, strong) UIWindow *debugVcWindow;
@end
@implementation WMDebugManager

+ (void)showDebugController{
    if (debugManager == nil){
        debugManager = [[WMDebugManager alloc] init];
        /// 展开更多监控信息
        WMDebugViewController *debugVc = [[WMDebugViewController alloc] init];
        WMMonitorNavigationController *rootNavi = [[WMMonitorNavigationController alloc] initWithRootViewController:debugVc];
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - statusBarHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - statusBarHeight)];
        window.windowLevel = UIWindowLevelStatusBar + 2;
        //绘制圆角 要设置的圆角 使用“|”来组合
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:window.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        //设置大小
        maskLayer.frame = window.bounds;
        //设置图形样子
        maskLayer.path = maskPath.CGPath;
        window.layer.mask = maskLayer;
        [window setClipsToBounds:YES];
        window.backgroundColor = [UIColor clearColor];
        [window makeKeyAndVisible];
        window.rootViewController = rootNavi;
        rootNavi.view.frame = window.bounds;
        debugManager.debugVcWindow = window;
        /// 显示动画
        [self showWindowAnimated];
    }
}
+ (void)hiddenDebugController{
    if (debugManager){
        [self hiddenWindowAnimated];
    }
}
+ (void)showWindowAnimated{
    [UIView animateWithDuration:kAnimatedDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        debugManager.debugVcWindow.frame = CGRectMake(0, statusBarHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - statusBarHeight);
    } completion:^(BOOL finished) {
    }];
}
+ (void)hiddenWindowAnimated{
    [UIView animateWithDuration:kAnimatedDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        debugManager.debugVcWindow.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - statusBarHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - statusBarHeight);
    } completion:^(BOOL finished) {
        debugManager.debugVcWindow.hidden = YES;
        debugManager.debugVcWindow.rootViewController = nil;
        debugManager = nil;
    }];
}
@end
