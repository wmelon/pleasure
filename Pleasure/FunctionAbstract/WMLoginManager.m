//
//  WMLoginManager.m
//  Pleasure
//
//  Created by Sper on 2017/12/27.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMLoginManager.h"
#import "WMLoginViewController.h"

@interface WMLoginManager()
@property (nonatomic , assign) BOOL isLogin;
@end

@implementation WMLoginManager
+ (instancetype)executeDirectlyOperationAfterLogin:(WMLoginComplete)complete{
    return [[self alloc] initWithLoginComplete:complete isDirectly:YES];
}
+ (instancetype)executeOperationHasLogin:(WMLoginComplete)complete{
    return [[self alloc] initWithLoginComplete:complete isDirectly:NO];
}
- (instancetype)initWithLoginComplete:(WMLoginComplete)complete isDirectly:(BOOL)isDirectly{
    if (self = [super init]){
        _complete = complete;
        
        /// 1.判断是否登录  如果没有登录就打开登录界面
        /// 2.登录界面有多个 (账号密码、手机号验证码、注册、微信、绑定手机号等) ， 这边需要抽象出登录实现方法
        /// 3.登录完成统一处理登录完成回调操作
        
        /// 如果是登录状态 或者 是当前界面就是登录界面 不允许再次弹出登录界面
        if (self.isLogin){
            if (_complete){
                _complete();
            }
        }else {
            if (isDirectly){
                [WMLoginOperation addLoginOperation:self];
            }
            [[SwitchViewController sharedSVC] wm_presentViewControllerClass:[WMLoginViewController new]];
        }
    }
    return self;
}

@end

@interface WMLoginOperation()

@end
static WMLoginManager *operations;

@implementation WMLoginOperation

+ (void)addLoginOperation:(WMLoginManager *)loginManager{
    if (!loginManager) return;
    operations = loginManager;
}

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password complete:(WMLoginComplete)complete{
    NSLog(@"登录成功  %@" , username);
    if (complete){
        complete();
    }
    [[SwitchViewController sharedSVC] wm_dismissTopViewControllerCompletion:^{
        if (operations.complete){
            operations.complete();
        }
        operations = nil;
    }];
}

+ (void)loginWithPhone:(NSString *)phone code:(NSString *)code complete:(WMLoginComplete)complete{
    NSLog(@"登录成功  %@" , phone);
    if (complete){
        complete();
    }
}
@end
