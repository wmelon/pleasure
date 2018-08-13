//
//  WMBaseTableCollectionControlController.h
//  Pleasure
//
//  Created by Sper on 2017/7/12.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMBaseViewController.h"

@interface WMBaseTableCollectionControlController : WMBaseViewController

/// 显示的数据源
@property (nonatomic, strong , readonly) NSMutableArray *rows;
/// 是否是下拉刷新
@property (nonatomic, assign , readonly) BOOL isRefresh;
/// 是否显示loading
@property (nonatomic, assign , readonly) BOOL shouldShowLoading;
/// 翻页参数
@property (nonatomic, strong , readonly) NSDictionary *turnPageParams;
/// 初始翻页参数
@property (nonatomic, strong , readonly) NSDictionary *startPageParams;

#pragma mark -- 子类需要重写方法
/// （是否显示上下拉刷新控件）
- (BOOL)shouldShowRefresh;
- (BOOL)shouldShowGetMore;

/// 下拉和上拉加载数据  翻页参数
//- (void)requestDataWithTurnPage:(NSDictionary *)turnPage;

/// 下拉刷新数据
- (void)requestNewData;

/// 翻页加载更多
- (void)requestMoreData;

/// 开始刷新和结束刷新
- (void)beginRefresh;
- (void)finishRequest;

/// 添加上下拉刷新控件
- (void)addRefreshHeadViewAndFootViewWithScrollerView:(UIScrollView *)scrollerView;

@end
