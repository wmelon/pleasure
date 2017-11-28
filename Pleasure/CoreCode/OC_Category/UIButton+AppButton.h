//
//  UIButton+AppButton.h
//  Pleasure
//
//  Created by Sper on 2017/7/5.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (AppButton)
+ (UIButton*)buttonWithImage:(UIImage*)image title:(NSString*)title target:(id)target action:(SEL)action;
@end
