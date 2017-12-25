//
//  WMTransitionAnimator.m
//  Pleasure
//
//  Created by Sper on 2017/12/25.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMTransitionAnimator.h"
#import "WMTransitionPushPopScale.h"
#import "WMPresentAIAnimator.h"

@implementation WMTransitionAnimator

- (instancetype)init{
    if (self = [super init]){
        _animationDuration = 0.3;
    }
    return self;
}

+ (instancetype)transitionWithAnimatedType:(WMTransitionAnimatedType)animatedType{
    switch (animatedType) {
        case WMTransitionAnimatedType_Scale:
            return [[WMTransitionPushPopScale alloc] init];
            break;
        default:
            return nil;
            break;
    }
}

#pragma mark -- UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return self.animationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    switch (self.operation) {
        case WMControllerOperation_Push:
            [self wm_pushAnimation:transitionContext];
            break;
        case WMControllerOperation_Pop:
            [self wm_popAnimation:transitionContext];
            break;
        default:
            break;
    }
}

//实现push动画逻辑代码
- (void)wm_pushAnimation:(id <UIViewControllerContextTransitioning>)transitionContext{
    
}

//实现pop动画逻辑代码
- (void)wm_popAnimation:(id <UIViewControllerContextTransitioning>)transitionContext{
    
}

@end
