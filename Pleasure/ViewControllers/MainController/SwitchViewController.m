//
//  SwitchViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/3.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "SwitchViewController.h"

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



//- (UINavigationController *)aNavigationControllerWithRootViewController:(UIViewController*)vc {
//    UINavigationController* navi = [[UINavigationController alloc] initWithNavigationBarClass:[AppNavigationBar class] toolbarClass:nil];
//    [navi pushViewController:vc animated:NO];
//    return navi;
//}
#pragma mark -- getter and setter
@synthesize rootShowViewController = _rootShowViewController;
- (RootViewController *)rootShowViewController{
    if (_rootShowViewController == nil){
//        RootViewController *vc = [[RootViewController alloc] init];
//        _rootShowViewController = [self aNavigationControllerWithRootViewController:vc];
        _rootShowViewController = [[RootViewController alloc] init];
    }
    return _rootShowViewController;
}

//@synthesize topNavigationController = _topNavigationController;
//- (UINavigationController *)topNavigationController{
//    _topNavigationController = self.rootShowViewController;
//    if (!_topNavigationController) {
//        return nil;
//    }
//    UINavigationController* vc = (UINavigationController*)_topNavigationController.presentedViewController;
//    while (vc) {
//        _topNavigationController = vc;
//        vc = (UINavigationController*)_topNavigationController.presentedViewController;
//    }
//    return _topNavigationController;
//}

//- (UINavigationController *)topNavigationController{
//    UINavigationController * navi = [self.rootShowViewController currentSelectedNavigationController];
//    if (navi == nil){
//        return nil;
//    }
//    return navi;
//}
//- (UIViewController*)wm_popViewControllerAnimated:(BOOL)animated{
//    return [self.topNavigationController popViewControllerAnimated:animated];
//}
//- (void)wm_popToRootViewControllerAnimated:(BOOL)animated{
//    [self.topNavigationController popToRootViewControllerAnimated:animated];
//}


@end
