//
//  SwitchViewController.h
//  Pleasure
//
//  Created by Sper on 2017/7/3.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SwitchViewController : NSObject
@property (nonatomic , strong , readonly)UINavigationController *rootShowViewController;
@property (nonatomic , strong , readonly)UINavigationController *topNavigationController;

+ (instancetype)sharedSVC;

#pragma mark -- 根据类名进行页面跳转
- (void)pushViewControllerClass:(Class)class_object;
- (void)pushViewControllerClass:(Class)class_object withObjects:(NSDictionary *)intentDic animated:(BOOL)animated;
- (void)pushViewControllerClass:(Class)class_object withObjects:(NSDictionary*)intentDic;
- (void)presentViewControllerClass:(Class)class_object;
- (void)presentViewControllerClass:(Class)class_object withObjects:(NSDictionary*)intentDic;

#pragma mark -- 销毁界面
- (void)dismissTopViewControllerCompletion:(void (^)(void))completion;
- (UIViewController*)popViewController;
- (void)popToViewController:(UIViewController *)vc;
- (void)popToRootViewController;

@end
