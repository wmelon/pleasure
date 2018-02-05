//
//  WMSegmentView.h
//  WMScrollPageView
//
//  Created by Sper on 2018/1/20.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMSegmentStyle.h"

@class WMSegmentView;
@protocol WMSegmentViewDelegate <NSObject>

/// 一共多少个切换标题
- (NSInteger)numberOfCountAtSegmentView:(WMSegmentView *)segmentView;

/// 标题按钮显示的文案
- (NSString *)segmentView:(WMSegmentView *)segmentView titleForItemAtIndex:(NSInteger)index;

/// 控件样式
- (WMSegmentStyle *)segmentStyleAtSegmentView:(WMSegmentView *)segmentView;

/// 标题按钮点击事件
- (void)segmentView:(WMSegmentView *)segmentView didSelectIndex:(NSInteger)index;

@optional
/// 默认选中标题
- (NSInteger)defaultSelectedIndexAtSegmentView:(WMSegmentView *)segmentView;

/// 右边添加按钮点击事件
- (void)plusButtonClickAtBarItem:(WMSegmentView *)segmentView;

@end

@interface WMSegmentView : UIView
@property (nonatomic , weak) id<WMSegmentViewDelegate> delegate;
/// 分页视图滚动进度
- (void)adjustUIWithProgress:(CGFloat)progress currentIndex:(NSInteger)currentIndex;
/// 滚动视图停止滚动调用
- (void)wm_scrollViewDidEndDecelerating;
- (void)wm_reloadSegmentView;
@end
