//
//  WMInteractiveTransition.m
//  Pleasure
//
//  Created by Sper on 2017/8/23.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMInteractiveTransition.h"

@interface WMInteractiveTransition()
/**手势方向*/
@property (nonatomic, assign) WMInteractiveTransitionGestureDirection direction;
/// 手势类型
@property (nonatomic, assign) WMInteractiveTransitionType type;
/// 手势开始时执行的操作回调
@property (nonatomic , copy) GestureConifg gestureConifg;
/// 添加手势的控制器
@property (nonatomic , weak) UIViewController *viewController;
@end

@implementation WMInteractiveTransition

+ (instancetype)interactiveTransitionWithTransitionType:(WMInteractiveTransitionType)type gestureDirection:(WMInteractiveTransitionGestureDirection)gestureDirection{
    return [[[self class] alloc] initInteractiveTransitionWithTransitionType:type gestureDirection:gestureDirection];
}
- (instancetype)initInteractiveTransitionWithTransitionType:(WMInteractiveTransitionType)type gestureDirection:(WMInteractiveTransitionGestureDirection)gestureDirection{
    if (self = [super init]){
        _direction = gestureDirection;
        _type = type;
    }
    return self;
}

/** 给传入的控制器添加手势*/
- (void)addPanGestureForViewController:(UIViewController *)viewController gestureConifg:(GestureConifg)gestureConifg{
    _gestureConifg = gestureConifg;
    _viewController = viewController;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [viewController.view addGestureRecognizer:pan];
}

- (void)handleGesture:(UIPanGestureRecognizer *)panGesture{
    CGFloat persent = 0.0;
    switch (_direction) {
        case WMInteractiveTransitionGestureDirectionLeft:{
            CGFloat transitionX = -[panGesture translationInView:panGesture.view].x;
            persent = transitionX / panGesture.view.frame.size.width;
        }
            break;
        case WMInteractiveTransitionGestureDirectionRight:{
            CGFloat transitionX = [panGesture translationInView:panGesture.view].x;
            persent = transitionX / panGesture.view.frame.size.width;
        }
            break;
        case WMInteractiveTransitionGestureDirectionUp:{
            CGFloat transitionY = -[panGesture translationInView:panGesture.view].y;
            persent = transitionY / panGesture.view.frame.size.width;
        }
            break;
        case WMInteractiveTransitionGestureDirectionDown:{
            CGFloat transitionY = [panGesture translationInView:panGesture.view].y;
            persent = transitionY / panGesture.view.frame.size.width;
        }
            break;
            
        default:
            break;
    }
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            //手势开始的时候标记手势状态，并开始相应的事件
            _interation = YES;
            [self wm_startGesture];
        }
            break;
        case UIGestureRecognizerStateChanged:{
            //手势过程中，通过updateInteractiveTransition设置pop过程进行的百分比
            [self updateInteractiveTransition:persent];
        }
            break;
        case UIGestureRecognizerStateEnded:{
            //手势完成后结束标记并且判断移动距离是否过半，过则finishInteractiveTransition完成转场操作，否者取消转场操作
            _interation = NO;
            if (persent > 0.5) {
                [self finishInteractiveTransition];
            }else{
                [self cancelInteractiveTransition];
            }
            break;
        }
            
        default:
            break;
    }
}

/// 手势开始时执行操作
- (void)wm_startGesture{
    switch (_type) {
        case WMInteractiveTransitionTypePresent:{
            if (_gestureConifg) {
                _gestureConifg();
            }
        }
            break;
            
        case WMInteractiveTransitionTypeDismiss:{
            if (_gestureConifg){
                _gestureConifg();
            }
        }
            
            break;
        case WMInteractiveTransitionTypePush:{
            if (_gestureConifg) {
                _gestureConifg();
            }
        }
            break;
        case WMInteractiveTransitionTypePop:{
            if (_gestureConifg){
                _gestureConifg();
            }
        }
            break;
    }
}


@end
