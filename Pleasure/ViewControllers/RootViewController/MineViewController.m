//
//  MineViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "MineViewController.h"
#import "WMUserHeaderView.h"
#import "WMScrollPageView.h"
#import "WMProductListViewController.h"

#define kUserHeaderViewHeight kScreenWidth  / 1.5
#define kTableViewHeight (kScreenHeight - 49)

@interface MineViewController ()<WMScrollPageViewDelegate , WMScrollPageViewDataSource , WMProductListViewControllerDelegate>

@property (nonatomic , strong) WMScrollPageView * scrollPageView;

/// 头部视图
@property (nonatomic , strong) WMUserHeaderView * userHeaderView;

/// 分段标题数组
@property (nonatomic , strong) NSMutableArray * segmentArray;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    [self configView];
}

- (void)configView{
    self.title = @"我的";
    self.navigationBarBackgroundView.alpha = 0.0;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.scrollPageView];
    
    [self showRightItem:@"设置" image:nil];
}

- (void)rightAction:(UIButton *)button{
    WMSettingViewController * vc = [WMSettingViewController new];
    [_svc wm_pushViewController:vc];
}

#pragma mark -- WMScrollBarControlDataSource
- (NSInteger)numberOfCountInScrollPageView:(WMScrollPageView *)scrollPageView{
    return self.segmentArray.count;
}

- (NSString *)scrollPageView:(WMScrollPageView *)scrollPageView titleForBarItemAtIndex:(NSInteger)index{
    return self.segmentArray[index];
}

/// 滑块下的每一项对应显示的控制器
- (UIViewController *)scrollPageView:(WMScrollPageView *)scrollPageView controllerAtIndex:(NSInteger)index{
    WMProductListViewController * vc = [WMProductListViewController new];
    vc.delegate = self;
    [vc setTitleString:self.segmentArray[index]];
    return vc;
}

- (UIView *)headerViewInScrollPageView:(WMScrollPageView *)scrollPageView{
    return self.userHeaderView;
}

- (void)scrollPageView:(WMScrollPageView *)scrollPageView navigationBarAlpha:(CGFloat)alpha{
    self.navigationBarBackgroundView.alpha = alpha;
}


- (void)productListViewController:(WMProductListViewController *)productListViewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WMSettingViewController * vc = [WMSettingViewController new];
    [self presentViewController:vc animated:YES completion:nil];
}

- (WMScrollBarItemStyle *)scrollBarItemStyleInScrollPageView:(WMScrollPageView *)scrollPageView{
    WMScrollBarItemStyle * style = [WMScrollBarItemStyle new];
    style.scrollContentViewTableViewHeight = kTableViewHeight;
    style.itemSizeStyle = wm_itemSizeStyle_equal_textSize;
//    style.scrollLineWidth = 30;
    style.allowStretchableHeader = NO;
    style.scaleTitle = YES;
    return style;
}

- (WMUserHeaderView *)userHeaderView{
    if (_userHeaderView == nil){

        _userHeaderView = [WMUserHeaderView userHeaderView];
        _userHeaderView.frame = CGRectMake(0, 0, kScreenWidth,  kUserHeaderViewHeight);
    }
    
    return _userHeaderView;
}
- (NSMutableArray *)segmentArray{
    if (_segmentArray == nil){
        NSArray * array;
        array = @[@"我的作品",@"阅读历史",@"我的收藏",@"1111111111111111111",@"222" , @"3333333" , @"444444" , @"55" , @"666666666"];
        _segmentArray = [NSMutableArray arrayWithArray:array];
    }
    return _segmentArray;
}

- (WMScrollPageView *)scrollPageView{

    if (_scrollPageView == nil){
    
        _scrollPageView = [[WMScrollPageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kTableViewHeight)];
        _scrollPageView.dataSource = self;
        _scrollPageView.delegate = self;
        
    }
    
    return _scrollPageView;
}

- (BOOL)shouldShowGetMore{
    return NO;
}

- (BOOL)shouldShowBackItem{
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
