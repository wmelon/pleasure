//
//  SwitchViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/3.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "SwitchViewController.h"
#import "RootViewController.h"

@implementation SwitchViewController
+ (instancetype)sharedSVC{
    static dispatch_once_t onceToken;
    static SwitchViewController * svc;
    dispatch_once(&onceToken, ^{
        svc = [SwitchViewController new];
    });
    return svc;
}
- (UIViewController *)rootNaviController{
    return [RootViewController new];
}
@end
