//
//  WMScrollPageView.h
//  AllDemo
//
//  Created by Sper on 2017/7/28.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMScrollBarItemStyle.h"

@class WMScrollPageView ;

@protocol WMScrollPageViewDataSource <NSObject>

@required
/// 滑动块有多少项  默认是 0
- (NSInteger)numberOfCountInScrollPageView:(WMScrollPageView *)scrollPageView;

/// 每一项显示的标题
- (NSString *)scrollPageView:(WMScrollPageView *)scrollPageView titleForBarItemAtIndex:(NSInteger)index;

/// 头部显示的视图
@optional

/// 滑块下的每一项对应显示的控制器
- (UIViewController *)scrollPageView:(WMScrollPageView *)scrollPageView controllerAtIndex:(NSInteger)index;


- (UIView *)headerViewInScrollPageView:(WMScrollPageView *)scrollPageView;


- (WMScrollBarItemStyle *)scrollBarItemStyleInScrollPageView:(WMScrollPageView *)scrollPageView;

/// 默认选中的标签 默认是 0
- (NSInteger)defaultSelectedIndexAtScrollPageView:(WMScrollPageView *)scrollPageView;

@end


@protocol WMScrollPageViewDelegate <NSObject>

@optional

/// 滚动视图滚动的导航栏的透明度
- (void)scrollPageView:(WMScrollPageView *)scrollPageView navigationBarAlpha:(CGFloat)alpha;

@end



@interface WMScrollPageView : UIView


@property (nonatomic , weak) id<WMScrollPageViewDelegate> delegate;


@property (nonatomic , weak) id<WMScrollPageViewDataSource> dataSource;


- (void)reloadScrollBar;



@end
