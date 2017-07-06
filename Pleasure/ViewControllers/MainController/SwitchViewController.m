//
//  SwitchViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/3.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "SwitchViewController.h"
#import "RootViewController.h"
#import "AppNavigationBar.h"

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

- (void)popToRootViewController{
    [self.topNavigationController popToRootViewControllerAnimated:YES];
}

- (UINavigationController *)aNavigationControllerWithRootViewController:(UIViewController*)vc {
    UINavigationController* navi = [[UINavigationController alloc] initWithNavigationBarClass:[AppNavigationBar class] toolbarClass:nil];
    [navi pushViewController:vc animated:NO];
    return navi;
}
#pragma mark -- getter and setter
@synthesize rootShowViewController = _rootShowViewController;
- (UINavigationController *)rootShowViewController{
    if (_rootShowViewController == nil){
        RootViewController *vc = [[RootViewController alloc] init];
        _rootShowViewController = [self aNavigationControllerWithRootViewController:vc];
    }
    return _rootShowViewController;
}

@synthesize topNavigationController = _topNavigationController;
- (UINavigationController *)topNavigationController{
    _topNavigationController = self.rootShowViewController;
    if (!_topNavigationController) {
        return nil;
    }
    UINavigationController* vc = (UINavigationController*)_topNavigationController.presentedViewController;
    while (vc) {
        _topNavigationController = vc;
        vc = (UINavigationController*)_topNavigationController.presentedViewController;
    }
    return _topNavigationController;
}

@end
