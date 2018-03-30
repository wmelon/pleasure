//
//  UIWindow+WMMotion.h
//  Pleasure
//
//  Created by Sper on 2018/3/15.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (WMMotion)
/// @override
- (BOOL)canBecomeFirstResponder;
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;
@end
