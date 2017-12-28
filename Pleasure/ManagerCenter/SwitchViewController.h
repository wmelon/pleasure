//
//  SwitchViewController.h
//  Pleasure
//
//  Created by Sper on 2017/7/3.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WMRootViewController.h"

@interface SwitchViewController : NSObject
@property (nonatomic , strong , readonly)UINavigationController *topNavigationController;
@property (nonatomic , strong , readonly)WMRootViewController *rootShowViewController;


+ (instancetype)sharedSVC;

//#pragma mark -- 根据类名进行页面跳转
- (void)wm_pushViewController:(UIViewController *)viewcontroller;
- (void)wm_presentViewControllerClass:(UIViewController *)viewcontroller;

//- (void)pushViewControllerClass:(Class)class_object;
//- (void)pushViewControllerClass:(Class)class_object withObjects:(NSDictionary *)intentDic animated:(BOOL)animated;
//- (void)pushViewControllerClass:(Class)class_object withObjects:(NSDictionary*)intentDic;
//- (void)presentViewControllerClass:(Class)class_object;
//- (void)presentViewControllerClass:(Class)class_object withObjects:(NSDictionary*)intentDic;
//
//#pragma mark -- 销毁界面
- (void)wm_dismissTopViewControllerCompletion:(void (^)(void))completion;
- (UIViewController*)wm_popViewControllerAnimated:(BOOL)animated;
//- (void)popToViewController:(UIViewController *)vc;
- (void)wm_popToRootViewControllerAnimated:(BOOL)animated;

@end
