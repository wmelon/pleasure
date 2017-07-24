//
//  WMBaseTableCollectionControlController.m
//  Pleasure
//
//  Created by Sper on 2017/7/12.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMBaseTableCollectionControlController.h"
#import "UIScrollView+AppScrollView.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "UIScrollView+EmptyDataSet.h"

@interface WMBaseTableCollectionControlController ()<DZNEmptyDataSetSource , DZNEmptyDataSetDelegate>
@property (nonatomic , strong)UIScrollView * scrollerView;
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
    _scrollerView.emptyDataSetSource = self;
    _scrollerView.emptyDataSetDelegate = self;
    
    
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

#pragma mark -- DZNEmptyDataSetSource and DZNEmptyDataSetDelegate
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSAttributedString * title = [[NSAttributedString alloc] initWithString:@"数据为空"];
    return title;
}
//- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView{
//    return [UIColor yellowColor];
//}
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView{
    return YES;
}



#pragma mark - overridable
-(void)requestRefresh{
    NSLog(@"%s 需要重写",__FUNCTION__);
    [self finishRequest];
}

-(void)requestGetMore{
    NSLog(@"%s 需要重写",__FUNCTION__);
    [self finishRequest];
}

-(BOOL)shouldShowRefresh{
    return NO;
}

-(BOOL)shouldShowGetMore{
    return NO;
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
