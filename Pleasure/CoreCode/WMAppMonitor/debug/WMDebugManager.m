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
        UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20)];
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
    }
}
+ (void)hiddenDebugController{
    if (debugManager){
        debugManager.debugVcWindow.hidden = YES;
        debugManager.debugVcWindow.rootViewController = nil;
        debugManager = nil;
    }
}
@end
