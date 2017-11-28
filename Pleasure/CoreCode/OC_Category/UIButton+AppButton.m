//
//  UIButton+AppButton.m
//  Pleasure
//
//  Created by Sper on 2017/7/5.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "UIButton+AppButton.h"

@implementation UIButton (AppButton)
+ (UIButton*)buttonWithImage:(UIImage*)image title:(NSString*)title target:(id)target action:(SEL)action {
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (title) {
        [btn setBackgroundImage:image forState:UIControlStateNormal];
        [btn setTitle:title forState:UIControlStateNormal];
    } else {
        [btn setImage:image forState:UIControlStateNormal];
    }
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    return btn;
}
@end
