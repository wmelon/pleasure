//
//  MineViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "MineViewController.h"
#import "WMPageContentViewCell.h"
#import "WMManyGesturesTableView.h"
#import "HFStretchableTableHeaderView.h"
#import <HMSegmentedControl.h>
#import "WMUserHeaderView.h"

#define kUserHeaderViewHeight kScreenWidth  / 1.5
#define kTableViewHeight (kScreenHeight - 49)

@interface MineViewController ()<UITableViewDelegate , UITableViewDataSource , WMPageContentViewCellDataSource>
/// 允许多个手势交互的tablView
@property (nonatomic , strong) WMManyGesturesTableView * tableView;
/// 头部视图
@property (nonatomic , strong) WMUserHeaderView * userHeaderView;
/// 分段控制器
@property (nonatomic , strong) HMSegmentedControl * segment;
/// 内部分页cell
@property (nonatomic , strong) WMPageContentViewCell * contentCell;
/// 分段标题数组
@property (nonatomic , strong) NSMutableArray * segmentArray;
//下拉头部放大控件
@property (strong, nonatomic) HFStretchableTableHeaderView* stretchableTableHeaderView;
//YES代表能滑动
@property (nonatomic, assign) BOOL canScroll;
@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    [self wm_addNotification];
    [self configView];
}
- (void)wm_addNotification{
    //通知的处理，本来也不需要这么多通知，只是写一个简单的demo，所以...根据项目实际情况进行优化吧
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPageViewCtrlChange:) name:WMCenterPageViewScroll object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainScrollerViewAllowScroll:) name:WMMainScrollerViewScroll object:nil];
}
- (void)configView{
    self.title = @"我的";
    self.navigationBarBackgroundView.alpha = 0;
    /// 初始化滚动数据
    [self changeMainTableViewAllowScroll:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
    
    self.userHeaderView = [WMUserHeaderView userHeaderView];
    self.userHeaderView.frame = CGRectMake(0, 0, kScreenWidth, kUserHeaderViewHeight);
    
    _stretchableTableHeaderView = [HFStretchableTableHeaderView new];
    [_stretchableTableHeaderView stretchHeaderForTableView:self.tableView withView:self.userHeaderView];
}

//pageViewController页面变动时的通知
- (void)onPageViewCtrlChange:(NSNotification *)ntf {
    //更改YUSegment选中目标
    [self.segment setSelectedSegmentIndex:[ntf.object integerValue] animated:YES];
}
//
//子控制器到顶部了 主控制器可以滑动
- (void)mainScrollerViewAllowScroll:(NSNotification *)ntf {
    [self changeMainTableViewAllowScroll:YES];
}
- (void)changeMainTableViewAllowScroll:(BOOL)mainAllowScroll{
    self.canScroll = mainAllowScroll;
    self.contentCell.canScroll = !mainAllowScroll;
}


//监听segment的变化
- (void)onSegmentChange {
    //改变pageView的页码
    self.contentCell.selectIndex = self.segment.selectedSegmentIndex;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //下拉放大 必须实现
    [_stretchableTableHeaderView scrollViewDidScroll:scrollView];
    
    //计算导航栏的透明度
    CGFloat minAlphaOffset = 0;
    CGFloat maxAlphaOffset = kUserHeaderViewHeight - 64;
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat alpha = (offset - minAlphaOffset) / (maxAlphaOffset - minAlphaOffset);
    NSLog(@"------%f" , alpha);
    self.navigationBarBackgroundView.alpha = alpha;
    
    //子控制器和主控制器之间的滑动状态切换
    CGFloat tabOffsetY = [_tableView rectForSection:0].origin.y - 64;

    if (offset >= tabOffsetY) {
        if (_canScroll) {
            [self changeMainTableViewAllowScroll:NO];
        }
    }
    
    if (!_canScroll){
        scrollView.contentOffset = CGPointMake(0, tabOffsetY);
    }
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WMPageContentViewCell * cell = [WMPageContentViewCell cellForTableView:tableView];
    cell.dataSource = self;
    self.contentCell = cell;
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //要减去导航栏 状态栏 以及 sectionheader的高度
    CGFloat height = kTableViewHeight - 44 - 64;
    return height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //sectionheader的高度，这是要放分段控件的
    return 44;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.segment;
}

#pragma mark -- WMPageContentViewCellDelegate and WMPageContentViewCellDataSource
- (NSInteger)numberOfCountInContentCell:(WMPageContentViewCell *)contentCell{
    return self.segmentArray.count;
}
- (WMBaseContentController *)contentCell:(WMPageContentViewCell *)contentCell contentControllerAtIndex:(NSInteger)index{
    return [WMProductListViewController new];
}

-(HMSegmentedControl *)segment{
    if (!_segment) {
        _segment = [[HMSegmentedControl alloc] initWithSectionTitles:self.segmentArray];
        _segment.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        _segment.borderType = HMSegmentedControlBorderTypeBottom;
        _segment.borderWidth = 0.5;
        _segment.borderColor = [UIColor lineColor];
        _segment.selectionIndicatorColor = [UIColor mainColor];
        _segment.selectionIndicatorHeight = 2.0;
        _segment.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
        _segment.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.00];
        [_segment addTarget:self action:@selector(onSegmentChange) forControlEvents:UIControlEventValueChanged];
    }
    return _segment;
}

- (NSMutableArray *)segmentArray{
    if (_segmentArray == nil){
        _segmentArray = [NSMutableArray arrayWithArray:@[@"我的作品",@"阅读历史",@"我的收藏"]];
    }
    return _segmentArray;
}

//下拉放大必须实现
- (void)viewDidLayoutSubviews {
    [_stretchableTableHeaderView resizeView];
}


- (WMManyGesturesTableView *)tableView{
    if (_tableView == nil){
        _tableView = [[WMManyGesturesTableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTableViewHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
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
