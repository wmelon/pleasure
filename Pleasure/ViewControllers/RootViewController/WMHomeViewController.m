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
    
    
//    @"要闻",@"政务",@"时报",@"视频",@"直播",@"生活",@"社区",
    
//    self.navigationItem.titleView = self.textField;
//    [UIBarButtonItem cn_addItemPosition:CNNavItemPositionLeft item:[UIBarButtonItem cn_itemWithString:@"CNNews " selectedColor:[UIColor whiteColor] target:nil action:nil] toNavItem:self.navigationItem fixedSpace:-5];
    
    [self.view addSubview:self.pageView];
    
    [self showRightItem:@"刷新" image:nil];
}

- (void)rightAction:(UIButton *)button{
    [_titles removeAllObjects];
    [_titles addObjectsFromArray:@[@"要闻",@"政务",@"时报",@"视频",@"直播"]];
    [self.pageView reloadScrollPageView];
}

/// 滑动块有多少项  默认是 0
- (NSInteger)numberOfCountInScrollPageView:(WMScrollPageView *)scrollPageView{
    return self.titles.count;
}

/// 每一项显示的标题
- (NSString *)scrollPageView:(WMScrollPageView *)scrollPageView titleForBarItemAtIndex:(NSInteger)index{
    return self.titles[index];
}


/// 滑块下的每一项对应显示的控制器
- (UIViewController *)scrollPageView:(WMScrollPageView *)scrollPageView controllerAtIndex:(NSInteger)index{
    WMProductListViewController *vc = WMProductListViewController.new;
    vc.title = self.titles[index];
    return vc;
}

- (void)plusButtonClickAtScrollPageView:(WMScrollPageView *)scrollPageView{
    //// 这里处理点击
    //    [CNJumper pushVcName:kClassName(CNNewsDetailViewController)];
}

- (WMScrollBarItemStyle *)scrollBarItemStyleInScrollPageView:(WMScrollPageView *)scrollPageView{
    WMScrollBarItemStyle *style = [WMScrollBarItemStyle new];
    style.itemSizeStyle = wm_itemSizeStyle_equal_textSize;
    style.scaleTitle = YES;
    style.showExtraButton = YES;
    style.showLine = YES;
    style.selectedTitleColor = [UIColor mainColor];
    style.scrollLineColor = [UIColor mainColor];
    style.scrollLineHeight = 2.0;
    return style;
}

/// 监听横竖屏切换 更新子视图的frame
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    _pageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 49);
}

- (WMScrollPageView *)pageView{
    if (_pageView == nil){
        _pageView = [[WMScrollPageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 49)];
        _pageView.dataSource = self;
        _pageView.delegate = self;
    }
    return _pageView;
}

//- (CNTextField *)textField {
//    if (!_textField) {
//        _textField = [[CNTextField alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 16 * 2 - 81, 27)];
//        _textField.backgroundColor = [UIColor whiteColor];
//        _textField.leftIconName = @"search_small_16x16_";
//        _textField.placeholder = @"搜索您想要的内容...";
//        _textField.font = [UIFont systemFontOfSize:14];
//        [_textField setEnabled:NO];
//        _textField.delegate = self;
//    }
//    return _textField;
//}

@end
