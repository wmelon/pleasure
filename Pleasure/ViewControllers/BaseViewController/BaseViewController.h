//
//  BaseViewController.h
//  Pleasure
//
//  Created by Sper on 2017/7/3.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchViewController.h"
#import "AppNavigationBar.h"

@interface BaseViewController : UIViewController{
    SwitchViewController * _svc;
}

@property (nonatomic , strong , readonly)UIImageView * navigationBarBackgroundView;
//- (BOOL)shouldShowBackItem;


- (UIButton *)showRightItem:(NSString *)title image:(UIImage *)image;
- (void)rightAction:(UIButton *)button;

@end
