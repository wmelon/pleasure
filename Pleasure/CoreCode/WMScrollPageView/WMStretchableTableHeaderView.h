//
//  WMStretchableTableHeaderView.h
//  AllDemo
//
//  Created by Sper on 2017/7/31.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WMStretchableTableHeaderView : NSObject

- (void)stretchHeaderForTableView:(UITableView*)tableView withView:(UIView*)view;
- (void)scrollViewDidScroll:(UIScrollView*)scrollView;
- (void)resizeView;

@end
