//
//  WMScrollBarItem.h
//  AllDemo
//
//  Created by Sper on 2017/7/28.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMScrollBarItemStyle.h"

@class WMScrollBarItem;

@protocol WMScrollBarItemDelegate <NSObject>

/// 标题按钮显示的文案
- (NSString *)barItem:(WMScrollBarItem *)barItem titleForItemAtIndex:(NSInteger)index;

/// 标题按钮点击事件
- (void)barItem:(WMScrollBarItem *)barItem didSelectIndex:(NSInteger)index;

@optional
/// 右边添加按钮点击事件
- (void)plusButtonClickAtBarItem:(WMScrollBarItem *)barItem;

@end

@interface WMScrollBarItem : UIView


@property (nonatomic , weak) id<WMScrollBarItemDelegate> delegate;

/// 初始化导航标题视图
- (void)wm_configBarItemsWithCount:(NSInteger)count currentIndex:(NSInteger)currentIndex barItemStyle:(WMScrollBarItemStyle *)barItemStyle;

/// scrollDidScroll 调用方法
- (void)adjustUIWithProgress:(CGFloat)progress currentIndex:(NSInteger)currentIndex;

/// 滚动视图停止滚动调用
- (void)wm_scrollViewDidEndDecelerating;

/// 设置选中
- (void)scrollToIndex:(NSInteger)toIndex currentIndex:(NSInteger)currentIndex animated:(BOOL)animated;

@end


