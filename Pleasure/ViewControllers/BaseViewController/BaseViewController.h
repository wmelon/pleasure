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

/// 为每一个控制器自定制导航栏
@property (nonatomic, strong , readonly)AppNavigationBar * appNavigationBar;

/// 为每一个控制器自定制导航栏 同时必须隐藏自带的导航栏
- (AppNavigationBar *)showCustomNavigationBar;

- (BOOL)shouldShowBackItem;
@end
