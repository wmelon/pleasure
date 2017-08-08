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
    self.navigationBarBackgroundView.alpha = _isTest;
    /// 初始化滚动数据
    self.automaticallyAdjustsScrollViewInsets = _isTest;
    [self.view addSubview:self.scrollPageView];
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
    return _isTest ? nil : self.userHeaderView;
}

- (NSInteger)defaultSelectedIndexAtScrollPageView:(WMScrollPageView *)scrollPageView{
    return 1;
}

- (void)scrollPageView:(WMScrollPageView *)scrollPageView navigationBarAlpha:(CGFloat)alpha{
    self.navigationBarBackgroundView.alpha = alpha;
}


- (void)productListViewController:(WMProductListViewController *)productListViewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MineViewController * vc = [MineViewController new];
    [vc setIsTest:YES];
    [_svc wm_pushViewController:vc];
}

- (WMScrollBarItemStyle *)scrollBarItemStyleInScrollPageView:(WMScrollPageView *)scrollPageView{

    
    WMScrollBarItemStyle * style = [WMScrollBarItemStyle new];
    style.scrollContentViewTableViewHeight = kTableViewHeight;
    style.itemSizeStyle = wm_itemSizeStyle_equal_textSize;
    style.allowStretchableHeader = NO;
    return _isTest ? nil : style;
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
        if (_isTest){
            array = @[@"我的作品",@"阅读历史",@"我的收藏"];
        }else {
            array = @[@"我的作品",@"阅读历史",@"我的收藏",@"1111111111111111111",@"222" , @"3333333" , @"444444" , @"55" , @"666666666"];
        }
        _segmentArray = [NSMutableArray arrayWithArray:array];
    }
    return _segmentArray;
}

- (WMScrollPageView *)scrollPageView{

    if (_scrollPageView == nil){
    
        _scrollPageView = [[WMScrollPageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _isTest ? kScreenHeight :kTableViewHeight)];
        _scrollPageView.dataSource = self;
        _scrollPageView.delegate = self;
        
    }
    
    return _scrollPageView;
}


- (void)setIsTest:(BOOL)isTest{
    _isTest = isTest;
    
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
