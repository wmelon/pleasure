//
//  WMPresentAIAnimator.h
//  Pleasure
//
//  Created by Sper on 2017/12/25.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMTransitionAnimator.h"

@interface WMPresentAIAnimator : WMTransitionAnimator<UIViewControllerAnimatedTransitioning>
/** 消失的时候调用*/
@property(nonatomic, copy)void(^dismissComletion)(void);
@property(nonatomic, assign)CGRect originFrame;
/** 持续时间*/
@property(nonatomic, assign)CGFloat duration;
/** 是否呈现*/
@property(nonatomic, assign)BOOL presenting;
@end
