//
//  WMScrollPageView.h
//  WMScrollPageView
//
//  Created by Sper on 2018/1/20.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMSegmentStyle.h"

@class WMScrollPageView ;

@protocol WMScrollPageViewDataSource <NSObject>
@required
/// 滑动块有多少项  默认是 0
- (NSInteger)numberOfCountInScrollPageView:(WMScrollPageView *)scrollPageView;

/// 每一项显示的标题
- (NSString *)scrollPageView:(WMScrollPageView *)scrollPageView titleForSegmentAtIndex:(NSInteger)index;

/// 每一项下面显示的视图控制器
- (UIViewController *)scrollPageView:(WMScrollPageView *)scrollPageView viewControllerAtIndex:(NSInteger)index;

@optional
/// tableView的头部是否
- (UIView *)headerViewInScrollPageView:(WMScrollPageView *)scrollPageView;

/// 默认选中的标签 默认是 0
- (NSInteger)defaultSelectedIndexAtScrollPageView:(WMScrollPageView *)scrollPageView;

@end

@protocol WMScrollPageViewDelegate <NSObject>
@optional
/// 滚动视图滚动的导航栏的透明度
- (void)scrollPageView:(WMScrollPageView *)scrollPageView navigationBarAlpha:(CGFloat)alpha;

/// 右边添加按钮点击事件
- (void)plusButtonClickAtScrollPageView:(WMScrollPageView *)scrollPageView;

@end

@interface WMScrollPageView : UIView
@property (nonatomic , assign) id<WMScrollPageViewDataSource> dataSource;
@property (nonatomic , assign) id<WMScrollPageViewDelegate> delegate;
- (instancetype)initWithSegmentStyle:(WMSegmentStyle *)segmentStyle parentVC:(UIViewController *)parentVC;
- (void)reloadScrollPageView;
@end
