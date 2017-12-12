//
//  WMBaseViewController.h
//  Pleasure
//
//  Created by Sper on 2017/8/30.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchViewController.h"

@interface WMBaseViewController : UIViewController{
    SwitchViewController * _svc;
}

- (void)wm_setElementsAlpha:(CGFloat)alpha;
/// 重置导航栏背景颜色
- (UIColor *)naviBarBackgroundColor;

- (UIButton *)showRightItem:(NSString *)title image:(UIImage *)image;
- (void)rightAction:(UIButton *)button;

@end
