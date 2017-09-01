//
//  WMScrollContentView.h
//  AllDemo
//
//  Created by Sper on 2017/7/28.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMScrollBarItem.h"

@class WMScrollContentView;

@protocol WMScrollContentViewDelegate <NSObject>

/// 控制器的滚动视图滚动
- (void)scrollContentView:(WMScrollContentView *)scrollContentView controlScroll:(UIScrollView *)scrollView canScroll:(BOOL)canScroll;

/// 分页控制器的滚动视图滚动
- (void)scrollContentView:(WMScrollContentView *)scrollContentView pageControlScroll:(UIScrollView *)scrollView;

/// 分页控制器滚动进度监听
- (void)scrollContentView:(WMScrollContentView *)scrollContentView adjustUIWithProgress:(CGFloat)progress currentIndex:(NSInteger)currentIndex;

/// 停止滚动
- (void)scrollContentView:(WMScrollContentView *)scrollContentView scrollAnimating:(BOOL)scrollAnimating;

@end


@interface WMScrollContentView : UITableViewCell

/// 是否允许滚动
@property (nonatomic , assign)BOOL canScroll;

/// 选中了索引
@property (nonatomic , assign , getter=currentSelectedIndex)NSInteger selectIndex;

@property (nonatomic , weak) id<WMScrollContentViewDelegate> delegate;

/// 初始化
+ (instancetype)cellForTableView:(UITableView *)tableView showViewControllers:(NSArray *)showViewControllers;

@end
