//
//  UIImage+AppImage.h
//  Pleasure
//
//  Created by Sper on 2017/7/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (AppImage)
+ (nullable UIImage *)imageWithColor:(UIColor *_Nullable)color;
/// 根据传入值裁剪图片 （图片最大宽度或者是高度）
+ (UIImage *)scaleAndRotateImage:(UIImage *)image resolution:(int)kMaxResolution;
@end
