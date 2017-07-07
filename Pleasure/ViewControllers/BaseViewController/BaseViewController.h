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

- (BOOL)shouldShowBackItem;

- (UIView *)loadNavigationHeaderView;

@end
