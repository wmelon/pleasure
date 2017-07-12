//
//  WMBaseTableCollectionControlController.h
//  Pleasure
//
//  Created by Sper on 2017/7/12.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "BaseViewController.h"

@interface WMBaseTableCollectionControlController : BaseViewController

/// 子类需要重写方法 （是否显示上下拉刷新控件）
- (BOOL)shouldShowRefresh;
- (BOOL)shouldShowGetMore;

/// 开始刷新和结束刷新
- (void)beginRefresh;
- (void)finishRequest;

/// 添加上下拉刷新控件
- (void)addRefreshHeadViewAndFootViewWithScrollerView:(UIScrollView *)scrollerView;

@end
