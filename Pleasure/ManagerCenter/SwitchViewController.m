//
//  SwitchViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/3.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "SwitchViewController.h"
#import "WMAppNavigationBar.h"

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
- (WMRootViewController *)rootShowViewController{
    if (_rootShowViewController == nil){
        _rootShowViewController = [[WMRootViewController alloc] init];
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

/// 创建带导航控制器的控制器
- (UINavigationController *)createNavigationController:(UIViewController *)viewcontroller{
    UINavigationController* navi = [[WMBaseNavigationController alloc] initWithNavigationBarClass:[WMAppNavigationBar class] toolbarClass:nil];
    [navi pushViewController:viewcontroller animated:NO];
    _topNavigationController = navi;
    return navi;
}

#pragma mark -- 界面跳转
- (void)wm_pushViewController:(UIViewController *)viewcontroller{
    [self.topNavigationController pushViewController:viewcontroller animated:YES];
}
- (void)wm_presentViewControllerClass:(UIViewController *)viewcontroller{
    UINavigationController* navi = [self createNavigationController:viewcontroller];
    [self.topNavigationController presentViewController:navi animated:YES completion:NULL];
}

- (UIViewController*)wm_popViewControllerAnimated:(BOOL)animated{
    return [self.topNavigationController popViewControllerAnimated:animated];
}
- (void)wm_popToRootViewControllerAnimated:(BOOL)animated{
    [self.topNavigationController popToRootViewControllerAnimated:animated];
}

- (void)wm_dismissTopViewControllerCompletion:(void (^)(void))completion{
    UINavigationController* navi = (UINavigationController*)self.topNavigationController.presentingViewController;
    [self.topNavigationController dismissViewControllerAnimated:YES completion:^{
        _topNavigationController = navi;
        if (completion) {
            completion();
        }
    }];
}

@end
