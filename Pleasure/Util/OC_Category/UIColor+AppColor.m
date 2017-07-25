//
//  UIColor+AppColor.m
//  Pleasure
//
//  Created by Sper on 2017/7/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "UIColor+AppColor.h"

@implementation UIColor (AppColor)
+ (UIColor *)lineColor {
    return UIColorFromRGB(0xe1e1e1);
}
+ (UIColor *)pageBackgroundColor{
    return UIColorFromRGB(0xeeeeee);
}

+ (UIColor *)mainColor{
    return [UIColor colorWithRed:29 / 255 green:29 / 255 blue:29 / 255 alpha:0.8];
}
+ (UIColor *)textColor{
    return UIColorFromRGB(0x333333);
}
+ (UIColor *)detailTextColor{
    return UIColorFromRGB(0x9b9b9b);
}

@end
