//
//  WMBaseTableCollectionControlController.m
//  Pleasure
//
//  Created by Sper on 2017/7/12.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMBaseTableCollectionControlController.h"
#import "UIScrollView+AppScrollView.h"

@interface WMBaseTableCollectionControlController ()
@property (nonatomic , strong)UIScrollView * scrollerView;
@end

@implementation WMBaseTableCollectionControlController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// 添加下拉刷新 // 添加上拉加载更多
- (void)addRefreshHeadViewAndFootViewWithScrollerView:(UIScrollView *)scrollerView {
    _scrollerView = scrollerView;
    
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
    return YES;
}

-(BOOL)shouldShowGetMore{
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
