//
//  WMPresentAIAnimator.m
//  Pleasure
//
//  Created by Sper on 2017/12/25.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMPresentAIAnimator.h"

@interface WMPresentAIAnimator()
@end

@implementation WMPresentAIAnimator

- (instancetype)init
{
    self = [super init];
    if (self) {
        _duration       = 1.;
        _presenting     = YES;
        _originFrame    = CGRectZero;
    }
    return self;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView   = [transitionContext containerView];
    
    UIView *toView          = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *herbView        = _presenting ? toView : [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    CGRect initialFrame     = _presenting ? _originFrame : herbView.frame;
    CGRect finalFrame       = _presenting ? herbView.frame : _originFrame;
    
    CGFloat xScaleFactor    = _presenting ?
    initialFrame.size.width / finalFrame.size.width:
    finalFrame.size.width   / initialFrame.size.width;
    
    CGFloat yScaleFactor    = _presenting ?
    initialFrame.size.height    / finalFrame.size.height:
    finalFrame.size.height      /   initialFrame.size.height;
    
    CGAffineTransform scaleTransfrom   = CGAffineTransformMakeScale(xScaleFactor, yScaleFactor);
    if (_presenting) {
        herbView.transform  = scaleTransfrom;
        herbView.center     = CGPointMake(
                                          initialFrame.size.width *.5 + initialFrame.origin.x,
                                          initialFrame.size.height *.5 + initialFrame.origin.y);
        herbView.clipsToBounds          = YES;
    }
    
    [containerView addSubview:toView];
    [containerView bringSubviewToFront:herbView];
    
    [UIView animateWithDuration:_duration delay:0 usingSpringWithDamping:.4 initialSpringVelocity:0. options:(UIViewAnimationOptionCurveLinear) animations:^{
        
        herbView.transform      = self.presenting ? CGAffineTransformIdentity:scaleTransfrom;
        herbView.center         = CGPointMake(
                                              finalFrame.size.width *.5 + finalFrame.origin.x,
                                              finalFrame.size.height *.5 + finalFrame.origin.y);
        //        herbController.containerView.alpha      = self.presenting ? 1. : 0.;
    } completion:^(BOOL finished) {
        if (!self.presenting) {
            if (self.dismissComletion) {
                self.dismissComletion();
            }
        }
        [transitionContext completeTransition:YES];
    }];
    CABasicAnimation    *round                  = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    round.fromValue                             = !_presenting?@0.:@(20.0/xScaleFactor);
    round.toValue                               = @(_presenting ? 0.:20./xScaleFactor);
    round.duration                              = _duration * .5;
    [herbView.layer addAnimation:round forKey:nil];
    herbView.layer.cornerRadius                 = _presenting? 0.:20./xScaleFactor;

}

@end
