//
//  WMTransitionAnimator.h
//  Pleasure
//
//  Created by Sper on 2017/12/25.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WMTransitionProtocol.h"

typedef NS_ENUM(NSUInteger, WMControllerOperation) {
    WMControllerOperation_Push ,   /// 导航栏切换动画
    WMControllerOperation_Pop   /// 导航栏返回动画
};
@interface WMTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>
/// 控制器切换方式
@property (nonatomic , assign) WMControllerOperation operation;
@property (nonatomic , assign) NSTimeInterval animationDuration;//动画时长

+ (instancetype)transitionWithAnimatedType:(WMTransitionAnimatedType)animatedType;
+ (instancetype)transitionAnimatorWithController:(UIViewController<WMTransitionProtocol> *)viewController;

#pragma mark -- 子类实现动画
- (void)wm_pushAnimation:(id <UIViewControllerContextTransitioning>)transitionContext;
- (void)wm_popAnimation:(id <UIViewControllerContextTransitioning>)transitionContext;

@end
