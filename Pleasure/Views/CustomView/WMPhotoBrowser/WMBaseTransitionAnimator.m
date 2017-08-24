//
//  WMBaseTransitionAnimator.m
//  Pleasure
//
//  Created by Sper on 2017/8/23.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMBaseTransitionAnimator.h"

@implementation WMBaseTransitionAnimator

+ (instancetype)transitionAnimatorWithTransitionType:(WMTransitionAnimatorType)type{
    return [[[self class] alloc] initWithTransitionAnimatorWithTransitionType:type];
}

- (instancetype)initWithTransitionAnimatorWithTransitionType:(WMTransitionAnimatorType)type{
    if (self = [super init]){
        _type = type;
        _duration = 0.25;
    }
    return self;
}

// This is used for percent driven interactive transitions, as well as for
// container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return _duration;
}

// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    switch (_type) {
        case WMTransitionAnimatorTypePresent:
            [self wm_presentAnimation:transitionContext];
            break;
        case WMTransitionAnimatorTypeDismiss:
            [self wm_dismissAnimation:transitionContext];
            break;
        case WMTransitionAnimatorTypePush:
            [self wm_pushAnimation:transitionContext];
            break;
        case WMTransitionAnimatorTypePop:
            [self wm_popAnimation:transitionContext];
            break;
        default:
            break;
    }

}

#pragma mark -- 子类重写方法

- (void)wm_presentAnimation:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    //拿到当前点击的cell的imageView
    
    UIView *containerView = [transitionContext containerView];
    //snapshotViewAfterScreenUpdates 对cell的imageView截图保存成另一个视图用于过渡，并将视图转换到当前控制器的坐标
    UIView *tempView = [_srcView snapshotViewAfterScreenUpdates:NO];
    tempView.frame = [_srcView convertRect:_srcView.bounds toView: containerView];
    //设置动画前的各个控件的状态
    _srcView.hidden = YES;
    toVC.view.alpha = 0;
    _destView.hidden = YES;
    //tempView 添加到containerView中，要保证在最前方，所以后添加
    [containerView addSubview:toVC.view];
    [containerView addSubview:tempView];
    //开始做动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.55 initialSpringVelocity:1 / 0.55 options:0 animations:^{
        tempView.frame = [_destView convertRect:_destView.bounds toView:containerView];
//        tempView.frame = _destFrame;
        toVC.view.alpha = 1;
    } completion:^(BOOL finished) {
        tempView.hidden = YES;
        _destView.hidden = NO;
        //如果动画过渡取消了就标记不完成，否则才完成，这里可以直接写YES，如果有手势过渡才需要判断，必须标记，否则系统不会中动画完成的部署，会出现无法交互之类的bug
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)wm_dismissAnimation:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    //这里的lastView就是push时候初始化的那个tempView
    UIView *tempView = containerView.subviews.lastObject;
    //设置初始状态
    _srcView.hidden = YES;
    _destView.hidden = YES;
    tempView.hidden = NO;
    [containerView insertSubview:toVC.view atIndex:0];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.55 initialSpringVelocity:1 / 0.55 options:0 animations:^{
        tempView.frame = [_srcView convertRect:_srcView.bounds toView:containerView];
        fromVC.view.alpha = 0;
    } completion:^(BOOL finished) {
        //由于加入了手势必须判断
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        if ([transitionContext transitionWasCancelled]) {//手势取消了，原来隐藏的imageView要显示出来
            //失败了隐藏tempView，显示fromVC.imageView
            tempView.hidden = YES;
            _destView.hidden = NO;
        }else{//手势成功，cell的imageView也要显示出来
            //成功了移除tempView，下一次pop的时候又要创建，然后显示cell的imageView
            _srcView.hidden = NO;
            [tempView removeFromSuperview];
        }
    }];
}

//实现push动画逻辑代码
- (void)wm_pushAnimation:(id <UIViewControllerContextTransitioning>)transitionContext{

}

//实现pop动画逻辑代码
- (void)wm_popAnimation:(id <UIViewControllerContextTransitioning>)transitionContext{

}

@end
