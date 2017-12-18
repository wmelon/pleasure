//
//  WMScrollPageView.m
//  AllDemo
//
//  Created by Sper on 2017/7/28.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMScrollPageView.h"
#import "WMScrollBarItem.h"
#import "WMScrollContentView.h"
#import "WMStretchableTableHeaderView.h"


@interface WMManyGesturesTableView : UITableView

@end

@implementation WMManyGesturesTableView

//允许同时识别多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

@interface WMScrollPageView()<WMScrollBarItemDelegate , UITableViewDataSource ,UITableViewDelegate , WMScrollContentViewDelegate>

/// 导航条视图
@property (nonatomic , strong) WMScrollBarItem * barItem;

/// 当前容器滚动视图
@property (nonatomic , strong) WMManyGesturesTableView * tableView;

/// 内部分页cell
@property (nonatomic , strong) WMScrollContentView * contentCell;

/// 内部分页显示的控制器
@property (nonatomic , strong) NSArray * viewControllers;

/// 下拉放大视图
@property (nonatomic , strong) WMStretchableTableHeaderView *stretchableTableHeaderView;

/// 容器滚动视图是否可以滚动 默认是可以滚动的
@property (nonatomic , assign) BOOL mainCanScroll;

/// 头部视图的高度
@property (nonatomic , assign) CGFloat tableViewHeaderViewHeight;

/// 所有视图的样式
@property (nonatomic , strong) WMScrollBarItemStyle * style;

@end


@implementation WMScrollPageView

- (void)setDataSource:(id<WMScrollPageViewDataSource>)dataSource{
    _dataSource = dataSource;
    
    NSInteger barItemCount = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfCountInScrollPageView:)]){
        barItemCount = [self.dataSource numberOfCountInScrollPageView:self];
    }
    
    /// 设置默认选中
    [self wm_configDefaultSelectedWithBarItemCount:barItemCount];
    
    /// 创建显示视图
    [self wm_creatShowControllersWithCount:barItemCount];
    
    /// 创建标题视图
    [self wm_createScrollBarWithCount:barItemCount];
    
    /// 创建标题视图头部视图
    [self wm_configTableViewHeaderView];
}

/// 配置默认选中 /// 初始化当前选中
- (void)wm_configDefaultSelectedWithBarItemCount:(NSInteger)barItemCount{
    _currentSelectedIndex = 0;
    if ([self.dataSource respondsToSelector:@selector(defaultSelectedIndexAtScrollPageView:)]){
        _currentSelectedIndex = [self.dataSource defaultSelectedIndexAtScrollPageView:self];
        if (_currentSelectedIndex >= barItemCount){
            _currentSelectedIndex = 0;
        }
    }
    
}
/// 配置头部视图
- (void)wm_configTableViewHeaderView{

    UIView * headerView;
    if ([self.dataSource respondsToSelector:@selector(headerViewInScrollPageView:)]){
        headerView = [self.dataSource headerViewInScrollPageView:self];
    }
    
    if (headerView){
        self.tableViewHeaderViewHeight = CGRectGetHeight(headerView.frame);
        
        if (self.style.allowStretchableHeader){  /// 允许下拉放大
            
            [self.stretchableTableHeaderView stretchHeaderForTableView:self.tableView withView:headerView];
            
        }else {   /// 不允许下拉放大
            
            self.tableView.tableHeaderView = headerView;
        }
        
        /// 设置初始化数据
        [self changeMainTableViewAllowScroll:YES];
    }else {
        self.tableView.scrollEnabled = NO;
        /// 设置初始化数据
        [self changeMainTableViewAllowScroll:NO];
    }
}
- (void)wm_creatShowControllersWithCount:(NSInteger)count{
    NSMutableArray * array = [NSMutableArray array];
    for (int i = 0 ; i < count ; i++){
        if ([self.dataSource respondsToSelector:@selector(scrollPageView:controllerAtIndex:)]){
            
            UIViewController * viewController = [self.dataSource scrollPageView:self controllerAtIndex:i];
        
            [array addObject:viewController];
            
        }
    }
    self.viewControllers = array;
    
    /// 刷新
    [self.tableView reloadData];
}
- (void)wm_createScrollBarWithCount:(NSInteger)count{
    WMScrollBarItemStyle * style;
    if ([self.dataSource respondsToSelector:@selector(scrollBarItemStyleInScrollPageView:)]){
        style = [self.dataSource scrollBarItemStyleInScrollPageView:self];
    }
    if (style == nil){
        style = [[WMScrollBarItemStyle alloc] init];
    }

    self.style = style;
    
    [self.barItem wm_configBarItemsWithCount:count currentIndex:_currentSelectedIndex barItemStyle:style];
    
    /// 刷新
    [self.tableView reloadData];

}

/// 切换主滚动视图和子滚动视图之间是否滚动
- (void)changeMainTableViewAllowScroll:(BOOL)mainAllowScroll{
    self.mainCanScroll = mainAllowScroll;
    self.contentCell.canScroll = !mainAllowScroll;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.tableView.scrollEnabled == NO) return;  /// 父滚动视图允许滚动的情况下才执行滚动计算
    
    //计算导航栏的透明度
    CGFloat minAlphaOffset = 0;
    CGFloat maxAlphaOffset = self.tableViewHeaderViewHeight - 64;
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat alpha = (offset - minAlphaOffset) / (maxAlphaOffset - minAlphaOffset);
    
    //子控制器和主控制器之间的滑动状态切换
    CGFloat tabOffsetY = [_tableView rectForSection:0].origin.y - 64;

    //下拉放大 必须实现
    [self.stretchableTableHeaderView scrollViewDidScroll:scrollView];
    
    if (offset >= tabOffsetY) {
        if (_mainCanScroll) {
            [self changeMainTableViewAllowScroll:NO];
        }
    }
    
    if (!_mainCanScroll){
        scrollView.contentOffset = CGPointMake(0, tabOffsetY);
        alpha = 1.0;  /// 防止不可以滚动的时候会出现透明度问题
    }
        
    if ([self.delegate respondsToSelector:@selector(scrollPageView:navigationBarAlpha:)]){
        [self.delegate scrollPageView:self navigationBarAlpha:alpha];
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
    
    WMScrollContentView * cell = [WMScrollContentView cellForTableView:tableView showViewControllers:self.viewControllers];
    self.contentCell = cell;
    cell.delegate = self;
    
    /// 设置默认选中
    [self setSelectedIndex:_currentSelectedIndex];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //要减去导航栏 状态栏 以及 sectionheader的高度
    CGFloat naviBarAndTabBArHeight = 0.0;
    if (self.style.isShowNavigationBar){
        naviBarAndTabBArHeight = 64 - self.frame.origin.y;
    }
    CGFloat height = self.frame.size.height - naviBarAndTabBArHeight - self.style.segmentHeight;
    if (height <= 0){
        height = 0;
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.barItem;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //sectionheader的高度，这是要放分段控件的
    return self.style.segmentHeight;
}


#pragma mark -- WMScrollContentViewDelegate

/// 分页控制器手势滑动控制当前滚动视图实付可以滚动
- (void)scrollContentView:(WMScrollContentView *)scrollContentView pageControlScroll:(UIScrollView *)scrollView{
    
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {  /// 当滑动下面的PageView时，当前要禁止滑动

        if (self.tableViewHeaderViewHeight > 0){
            self.tableView.scrollEnabled = NO;
        }

    } else if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {  /// bottomView停止滑动了  当前页可以滑动
        
        if (self.tableViewHeaderViewHeight > 0){
            self.tableView.scrollEnabled = YES;
        }
    }
}

/// 控制器的滚动视图滚动

- (void)scrollContentView:(WMScrollContentView *)scrollContentView controlScroll:(UIScrollView *)scrollView canScroll:(BOOL)canScroll{
    
    
    if (self.tableView.scrollEnabled == NO) return;  /// 父滚动视图允许滚动才执行两个滚动视图的滚动切换
    
    _tableView.bounces = self.style.allowStretchableHeader;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (offsetY < 0){
        
        if (canScroll == YES){
            //子控制器到顶部了 主控制器可以滑动
            [self changeMainTableViewAllowScroll:YES];
        }
        
    }
    
    if (_tableView.bounces){  /// 允许下拉放大头部
        
        if (!canScroll && scrollView.contentOffset.y != 0) {
            [scrollView setContentOffset:CGPointZero];
        }
        
    
    } else {
        
        if (!canScroll && scrollView.contentOffset.y != 0) {
            if (_tableView.contentOffset.y > 0) {
                [scrollView setContentOffset:CGPointZero];
            }
        }
        
    }
}

/// 处理pageView滚动进度
- (void)scrollContentView:(WMScrollContentView *)scrollContentView adjustUIWithProgress:(CGFloat)progress currentIndex:(NSInteger)currentIndex{
    
    /// 处理barItem切换
    [self.barItem adjustUIWithProgress:progress currentIndex:currentIndex];
 
    /// 更新当前选中的下标
    _currentSelectedIndex = currentIndex;
}

- (void)scrollContentView:(WMScrollContentView *)scrollContentView scrollAnimating:(BOOL)scrollAnimating{
    
    [self.barItem wm_scrollViewDidEndDecelerating];
    
}

#pragma mark -- WMScrollBarItemDelegate

- (NSString *)barItem:(WMScrollBarItem *)barItem titleForItemAtIndex:(NSInteger)index{
    NSString * title;
    
    if ([self.dataSource respondsToSelector:@selector(scrollPageView:titleForBarItemAtIndex:)]){
        title = [self.dataSource scrollPageView:self titleForBarItemAtIndex:index];
    }
    return title;
}

/// 右边添加按钮点击事件
- (void)plusButtonClickAtBarItem:(WMScrollBarItem *)barItem{
    if ([self.delegate respondsToSelector:@selector(plusButtonClickAtScrollPageView:)]){
        [self.delegate plusButtonClickAtScrollPageView:self];
    }
}
/// 选择了barItem需要切换界面
- (void)barItem:(WMScrollBarItem *)barItem didSelectIndex:(NSInteger)index{
    /// 更新当前选中的下标
    _currentSelectedIndex = index;
    [self.contentCell setSelectIndex:index];
}

#pragma mark -- public method
/// 设置默认选中
- (void)setSelectedIndex:(NSInteger)selectedIndex{
    
    [self.contentCell setSelectIndex:selectedIndex];
    
    [self.barItem scrollToIndex:selectedIndex currentIndex:0 animated:NO];
}


//下拉放大必须实现
- (void)viewDidLayoutSubviews {
    [self.stretchableTableHeaderView resizeView];
}

#pragma mark -- Getter method
/// 刷新数据
- (void)reloadScrollPageView{
    [self setDataSource:_dataSource];
}

- (WMStretchableTableHeaderView *)stretchableTableHeaderView{
    if (_stretchableTableHeaderView == nil){
    
        _stretchableTableHeaderView = [WMStretchableTableHeaderView new];
        
    }
    return _stretchableTableHeaderView;
}

- (WMScrollBarItem *)barItem{
    if (_barItem == nil){
        
        _barItem = [[WMScrollBarItem alloc] init];
        
        _barItem.delegate = self;
    }
    return _barItem;
}

- (UITableView *)tableView{
    
    if (_tableView == nil){
        _tableView = [[WMManyGesturesTableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.delegate= self;
        _tableView.dataSource= self;
        [_tableView setShowsVerticalScrollIndicator:NO];
        [_tableView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:_tableView];
    }
    
    return _tableView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.tableView.frame = self.bounds;
    self.barItem.frame = CGRectMake(0, self.tableViewHeaderViewHeight, self.frame.size.width, self.style.segmentHeight);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
