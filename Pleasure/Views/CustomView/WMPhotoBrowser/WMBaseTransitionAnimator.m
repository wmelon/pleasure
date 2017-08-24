//
//  WMBaseTransitionAnimator.m
//  Pleasure
//
//  Created by Sper on 2017/8/23.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMBaseTransitionAnimator.h"

@interface WMBaseTransitionAnimator()
@property (nonatomic , strong) UIImageView *srcImageView;
@property (nonatomic , strong) UIImageView *destImageView;

@end
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

//拿到当前点击的cell的imageView
- (UIImageView *)getSrcImageView{
    if (_srcImageView) return _srcImageView;
    
    if ([self.delegate respondsToSelector:@selector(srcImageViewForTransitionAnimator:)]){
        _srcImageView = [self.delegate srcImageViewForTransitionAnimator:self];
    }
    return _srcImageView;
}
- (UIImageView *)getDestImageView{
    if (_destImageView) return _destImageView;
    
    if ([self.delegate respondsToSelector:@selector(destImageViewForTransitionAnimator:)]){
        _destImageView = [self.delegate destImageViewForTransitionAnimator:self];
    }
    return _destImageView;
}

- (CGRect)getDestImageViewFrameWithMainView:(UIView *)view{
    UIImage *image = [self getSrcImageView].image;
    CGRect frame = CGRectZero;
    if (image && image.size.width > 0){
        CGFloat width = view.frame.size.width;
        CGFloat height = width * image.size.height / image.size.width;
        frame = CGRectMake(0, (view.frame.size.height - height) / 2, width, height);
    }
    return frame;
}

#pragma mark -- 子类重写方法

- (void)wm_presentAnimation:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    /// 创建一个视图作为动画过度视图
    UIImageView *tempView = [UIImageView new];
    tempView.image = [self getSrcImageView].image;
    tempView.contentMode = [self getSrcImageView].contentMode;
    tempView.clipsToBounds = [self getSrcImageView].clipsToBounds;
    tempView.frame = [[self getSrcImageView] convertRect:[self getSrcImageView].bounds toView: containerView];
    
    //设置动画前的各个控件的状态
    [self getSrcImageView].hidden = YES;
    toVC.view.alpha = 0;
    [self getDestImageView].hidden = YES;
    //tempView 添加到containerView中，要保证在最前方，所以后添加
    [containerView addSubview:toVC.view];
    [containerView addSubview:tempView];
    //开始做动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        tempView.frame = [self getDestImageViewFrameWithMainView:containerView];
        toVC.view.alpha = 1;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(animationFinishedAtTransitionAnimator:)]){
            [self.delegate animationFinishedAtTransitionAnimator:self];
        }
        tempView.hidden = YES;   /// 这里不能移除tempview 因为在dismiss的时候需要这个视图显示过渡效果
        [self getDestImageView].hidden = NO;
        [self getSrcImageView].hidden = NO;
        [tempView removeFromSuperview];
        //如果动画过渡取消了就标记不完成，否则才完成，这里可以直接写YES，如果有手势过渡才需要判断，必须标记，否则系统不会中动画完成的部署，会出现无法交互之类的bug
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)wm_dismissAnimation:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    //这里的lastView就是push时候初始化的那个tempView
//    UIView *tempView = containerView.subviews.lastObject;
    UIImageView *tempView = [UIImageView new];
    tempView.image = [self getDestImageView].image;
    tempView.contentMode = [self getDestImageView].contentMode;
    tempView.clipsToBounds = [self getDestImageView].clipsToBounds;
    tempView.frame = [[self getDestImageView] convertRect:[self getDestImageView].bounds toView: containerView];
    
    //设置初始状态
    [self getSrcImageView].hidden = YES;
    [self getDestImageView].hidden = YES;
    tempView.hidden = NO;
    [containerView insertSubview:toVC.view atIndex:0];
    [containerView addSubview:tempView];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        tempView.frame = [[self getSrcImageView] convertRect:[self getSrcImageView].bounds toView:containerView];
        fromVC.view.alpha = 0;
    } completion:^(BOOL finished) {
        //由于加入了手势必须判断
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        if ([transitionContext transitionWasCancelled]) {//手势取消了，原来隐藏的imageView要显示出来
            //失败了隐藏tempView，显示fromVC.imageView
            [self getDestImageView].hidden = NO;
            [self getSrcImageView].hidden = NO;
        }else{//手势成功，cell的imageView也要显示出来
            //成功了移除tempView，下一次pop的时候又要创建，然后显示cell的imageView
            [self getSrcImageView].hidden = NO;
        }
        [tempView removeFromSuperview];
    }];
    
//    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.55 initialSpringVelocity:1 / 0.55 options:0 animations:^{
//        tempView.frame = [_srcView convertRect:_srcView.bounds toView:containerView];
//        fromVC.view.alpha = 0;
//    } completion:^(BOOL finished) {
//        //由于加入了手势必须判断
//        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//        if ([transitionContext transitionWasCancelled]) {//手势取消了，原来隐藏的imageView要显示出来
//            //失败了隐藏tempView，显示fromVC.imageView
//            tempView.hidden = YES;
//            _destView.hidden = NO;
//        }else{//手势成功，cell的imageView也要显示出来
//            //成功了移除tempView，下一次pop的时候又要创建，然后显示cell的imageView
//            _srcView.hidden = NO;
//            [tempView removeFromSuperview];
//        }
//    }];
}

//实现push动画逻辑代码
- (void)wm_pushAnimation:(id <UIViewControllerContextTransitioning>)transitionContext{

}

//实现pop动画逻辑代码
- (void)wm_popAnimation:(id <UIViewControllerContextTransitioning>)transitionContext{

}

@end
