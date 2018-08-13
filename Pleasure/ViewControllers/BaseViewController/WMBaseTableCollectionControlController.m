//
//  WMBaseTableCollectionControlController.m
//  Pleasure
//
//  Created by Sper on 2017/7/12.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMBaseTableCollectionControlController.h"
#import "UIScrollView+AppScrollView.h"

@interface WMBaseTableCollectionControlController ()<UIScrollViewDelegate>
@property (nonatomic , strong) UIScrollView * scrollerView;
@property (nonatomic , strong) NSNumber *page;
@end

@implementation WMBaseTableCollectionControlController

- (instancetype)init{
    if (self = [super init]){
        _rows = [NSMutableArray array];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// 添加下拉刷新 // 添加上拉加载更多
- (void)addRefreshHeadViewAndFootViewWithScrollerView:(UIScrollView *)scrollerView {
    _scrollerView = scrollerView;
    _scrollerView.delegate = self;
    __weak typeof(self) weakself = self;
    if ([self shouldShowRefresh]) {
        [scrollerView wm_RefreshHeaderWithBlock:^{
            [weakself requestRefresh];
        }];
    }
    if ([self shouldShowGetMore]) {
        [scrollerView wm_RefreshFooterWithBlock:^{
            [weakself requestGetMore];
        }];
    }
}

- (void)beginRefresh{
    [_scrollerView wm_beginRefreshing];
}

- (void)finishRequest{
    [_scrollerView wm_endRefreshing];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}
- (void)requestRefresh{
    [self configStartTurnPageParams];
    [self requestNewData];
}

- (void)requestGetMore{
    self.page = @([self.page integerValue] + 1);
    [self requestMoreData];
}

#pragma mark - overridable
- (void)requestNewData{
    [self requestDataWithIsRefresh:YES];
}
- (void)requestMoreData{
    [self requestDataWithIsRefresh:NO];
}

- (void)requestDataWithIsRefresh:(BOOL)isRefresh{
    _isRefresh = isRefresh;
    //    [self requestDataWithTurnPage:self.turnPageParams];
}

/// 初始化翻页参数
- (void)configStartTurnPageParams{
    /// 下拉刷新初始化翻页参数
    self.page = @1;
}
- (NSDictionary *)startPageParams{
    [self configStartTurnPageParams];
    return self.turnPageParams;
}
- (NSDictionary *)turnPageParams{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.page forKey:@"page"];
    return dict;
}
//- (void)requestDataWithTurnPage:(NSDictionary *)turnPage{
//    NSLog(@"%s 需要重写",__FUNCTION__);
//    [self finishRequest];
//}

- (BOOL)shouldShowRefresh{
    return YES;
}

- (BOOL)shouldShowGetMore{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
