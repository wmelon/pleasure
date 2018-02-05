//
//  WMHomeViewController.m
//  Pleasure
//
//  Created by Sper on 2017/8/30.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMHomeViewController.h"
#import "WMScrollPageView.h"

@interface WMHomeViewController ()<WMScrollPageViewDataSource,WMScrollPageViewDelegate>
@property (nonatomic, strong) WMScrollPageView *pageView;
@property (nonatomic, strong) NSMutableArray *titles;
@end

@implementation WMHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _titles = [NSMutableArray array];
    [_titles addObjectsFromArray:@[@"商圈",@"园区",@"图片",@"美丽长宁",@"专题",@"投稿"]];
//    ,@"要闻",@"政务",@"时报",@"视频",@"直播",@"生活",@"社区"
    [self.view addSubview:self.pageView];
    [self showRightItem:@"刷新" image:nil];
}

- (void)rightAction:(UIButton *)button{
    [_titles removeAllObjects];
    [_titles addObjectsFromArray:@[@"要闻",@"政务",@"时报",@"视频",@"直播"]];
    [self.pageView reloadScrollPageView];
}

- (NSInteger)numberOfCountInScrollPageView:(WMScrollPageView *)scrollPageView{
    return self.titles.count;
}
/// 每一项显示的标题
- (NSString *)scrollPageView:(WMScrollPageView *)scrollPageView titleForSegmentAtIndex:(NSInteger)index{
    return self.titles[index];
}

/// 每一项下面显示的视图控制器
- (UIViewController *)scrollPageView:(WMScrollPageView *)scrollPageView viewControllerAtIndex:(NSInteger)index{
    WMProductListViewController *vc = WMProductListViewController.new;
    vc.title = self.titles[index];
    return vc;
}

- (void)plusButtonClickAtScrollPageView:(WMScrollPageView *)scrollPageView{
    //// 这里处理点击
    [_svc wm_pushViewController:[WMHomeViewController new]];
}

/// 监听横竖屏切换 更新子视图的frame
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    _pageView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kTabBarHeight - kNavBarHeight);
}

- (WMScrollPageView *)pageView{
    if (_pageView == nil){
        WMSegmentStyle *style = [WMSegmentStyle new];
        style.itemSizeStyle = wm_itemSizeStyle_equal_textSize;
        style.scaleTitle = YES;
        style.showExtraButton = YES;
        style.showMoveLine = YES;
        style.selectedTitleColor = [UIColor mainColor];
        style.scrollLineColor = [UIColor mainColor];
        style.scrollLineHeight = 2.0;

        _pageView = [[WMScrollPageView alloc] initWithSegmentStyle:style parentVC:self];
        _pageView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight - kTabBarHeight - kNavBarHeight);
        _pageView.dataSource = self;
        _pageView.delegate = self;
    }
    return _pageView;
}

@end
