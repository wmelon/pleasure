//
//  SwitchViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/3.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "SwitchViewController.h"

@interface SwitchViewController()
@end

@implementation SwitchViewController
+ (instancetype)sharedSVC{
    static dispatch_once_t onceToken;
    static SwitchViewController * svc;
    dispatch_once(&onceToken, ^{
        svc = [SwitchViewController new];
    });
    return svc;
}

#pragma mark -- getter and setter
@synthesize rootShowViewController = _rootShowViewController;
- (RootViewController *)rootShowViewController{
    if (_rootShowViewController == nil){
        _rootShowViewController = [[RootViewController alloc] init];
    }
    return _rootShowViewController;
}

@synthesize topNavigationController = _topNavigationController;
- (UINavigationController *)topNavigationController{
    UINavigationController * navi = [self.rootShowViewController currentSelectedNavigationController];
    if (navi == nil){
        return nil;
    }
    return navi;
}

- (UIViewController*)wm_popViewControllerAnimated:(BOOL)animated{
    return [self.topNavigationController popViewControllerAnimated:animated];
}
- (void)wm_popToRootViewControllerAnimated:(BOOL)animated{
    [self.topNavigationController popToRootViewControllerAnimated:animated];
}

@end
