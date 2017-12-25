//
//  WMInteractiveTransition.h
//  Pleasure
//
//  Created by Sper on 2017/8/23.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GestureConifg)(void);

typedef NS_ENUM(NSInteger , WMInteractiveTransitionGestureDirection) {
    WMInteractiveTransitionGestureDirectionLeft = 0,
    WMInteractiveTransitionGestureDirectionRight,
    WMInteractiveTransitionGestureDirectionUp,
    WMInteractiveTransitionGestureDirectionDown
};

typedef NS_ENUM(NSInteger , WMInteractiveTransitionType) {
    WMInteractiveTransitionTypePresent = 0,
    WMInteractiveTransitionTypeDismiss,
    WMInteractiveTransitionTypePush,
    WMInteractiveTransitionTypePop
};

@interface WMInteractiveTransition : UIPercentDrivenInteractiveTransition

/**记录是否开始手势，判断pop操作是手势触发还是返回键触发*/
@property (nonatomic , assign , readonly) BOOL interation;

+ (instancetype)interactiveTransitionWithTransitionType:(WMInteractiveTransitionType)type gestureDirection:(WMInteractiveTransitionGestureDirection)gestureDirection;

/** 给传入的控制器添加手势*/
- (void)addPanGestureForViewController:(UIViewController *)viewController gestureConifg:(GestureConifg)gestureConifg;

@end
