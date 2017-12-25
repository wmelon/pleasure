//
//  WMTransitionProtocol.h
//  Pleasure
//
//  Created by Sper on 2017/12/25.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , WMTransitionAnimatedType) {
    WMTransitionAnimatedType_default, /// 默认转场动画
    WMTransitionAnimatedType_Scale  /// 放大转场动画
};

@protocol WMTransitionProtocol <NSObject>
@optional

/**
 转场动画的目标View 需要转场动画的对象必须实现该方法并返回要做动画的View
 
 @return view
 */
- (UIView *)targetTransitionView;

/**
 转场动画类型
 
 @return 转场动画类型
 */
- (WMTransitionAnimatedType)transitionAnimatedType;

@end
