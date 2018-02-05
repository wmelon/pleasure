//
//  WMMineViewController.m
//  Pleasure
//
//  Created by Sper on 2017/8/30.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMMineViewController.h"
#import "WMUserHeaderView.h"
#import "WMScrollPageView.h"

#define kUserHeaderViewHeight kScreenWidth  / 1.5
#define kTableViewHeight (kScreenHeight - 49)

@interface WMMineViewController ()<WMScrollPageViewDelegate , WMScrollPageViewDataSource , WMProductListViewControllerDelegate>

@property (nonatomic , strong) WMScrollPageView * scrollPageView;

/// 头部视图
@property (nonatomic , strong) WMUserHeaderView * userHeaderView;

/// 分段标题数组
@property (nonatomic , strong) NSMutableArray * segmentArray;


@end

@implementation WMMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    [self configView];
}

- (void)configView{
    self.title = @"我的";
    [self wm_setElementsAlpha:0.0];
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
/// 每一项显示的标题
- (NSString *)scrollPageView:(WMScrollPageView *)scrollPageView titleForSegmentAtIndex:(NSInteger)index{
    return self.segmentArray[index];
}

/// 每一项下面显示的视图控制器
- (UIViewController *)scrollPageView:(WMScrollPageView *)scrollPageView viewControllerAtIndex:(NSInteger)index{
    WMProductListViewController * vc = [WMProductListViewController new];
    vc.delegate = self;
    [vc setTitle:self.segmentArray[index]];
    return vc;
}

- (UIView *)headerViewInScrollPageView:(WMScrollPageView *)scrollPageView{
    return self.userHeaderView;
}

- (void)scrollPageView:(WMScrollPageView *)scrollPageView navigationBarAlpha:(CGFloat)alpha{
    [self wm_setElementsAlpha:alpha];
}

- (void)productListViewController:(WMProductListViewController *)productListViewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WMSettingViewController * vc = [WMSettingViewController new];
    [_svc wm_pushViewController:vc];
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
        WMSegmentStyle * style = [WMSegmentStyle new];
        style.itemSizeStyle = wm_itemSizeStyle_equal_textSize;
        style.allowStretchableHeader = NO;
        style.scaleTitle = YES;
        _scrollPageView = [[WMScrollPageView alloc] initWithSegmentStyle:style parentVC:self];
        _scrollPageView.frame = CGRectMake(0, 0, self.view.frame.size.width, kTableViewHeight);
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
