//
//  WMBaseContentController.h
//  AllDemo
//
//  Created by Sper on 2017/7/26.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSNotificationName const WMCenterPageViewScroll;
UIKIT_EXTERN NSNotificationName const WMMainScrollerViewScroll;

@interface WMBaseContentController : UITableViewController
@property (assign, nonatomic) BOOL canScroll;
@end
