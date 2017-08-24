//
//  WMBaseTransitionAnimator.h
//  Pleasure
//
//  Created by Sper on 2017/8/23.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WMTransitionAnimatorType) {
    WMTransitionAnimatorTypePresent = 0,//管理present动画
    WMTransitionAnimatorTypeDismiss , //管理dismiss动画
    WMTransitionAnimatorTypePush ,   /// 导航栏切换动画
    WMTransitionAnimatorTypePop   /// 导航栏返回动画
};


@interface WMBaseTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic , strong) UIView *srcView;
@property (nonatomic , strong) UIView *destView;
//@property (nonatomic , assign) CGRect srcFrame;
@property (nonatomic , assign) CGRect destFrame;


/// 动画执行时间
@property (nonatomic , assign) CGFloat duration;

/// 动画过度类型
@property (nonatomic, assign , readonly)WMTransitionAnimatorType type;

//根据定义的枚举初始化的两个方法
+ (instancetype)transitionAnimatorWithTransitionType:(WMTransitionAnimatorType)type;


#pragma mark -- 子类重写方法

- (void)wm_presentAnimation:(id <UIViewControllerContextTransitioning>)transitionContext;

- (void)wm_dismissAnimation:(id <UIViewControllerContextTransitioning>)transitionContext;

//实现push动画逻辑代码
- (void)wm_pushAnimation:(id <UIViewControllerContextTransitioning>)transitionContext;

//实现pop动画逻辑代码
- (void)wm_popAnimation:(id <UIViewControllerContextTransitioning>)transitionContext;

@end
