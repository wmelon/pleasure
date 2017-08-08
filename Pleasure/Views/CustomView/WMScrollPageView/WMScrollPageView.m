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

/// 默认选中标签
@property (nonatomic , assign) NSInteger defaultSelectedIndex;


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
    
    [self wm_configDefaultSelected];
    
    [self wm_creatShowControllersWithCount:barItemCount];
    
    if (!self.style){
        [self wm_createScrollBarWithCount:barItemCount];
    }
    
    [self wm_configTableViewHeaderView];
}

/// 配置默认选中
- (void)wm_configDefaultSelected{
    self.defaultSelectedIndex = 0;
    if ([self.dataSource respondsToSelector:@selector(defaultSelectedIndexAtScrollPageView:)]){
        self.defaultSelectedIndex = [self.dataSource defaultSelectedIndexAtScrollPageView:self];
    }
    
}
/// 配置头部视图
- (void)wm_configTableViewHeaderView{
    if (!self.tableView.superview){
        [self addSubview:self.tableView];
    }
    
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
    self.barItem.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, style.segmentHeight);
    [self.barItem wm_configBarItemsWithCount:count barItemStyle:style];
    
    /// 刷新
    [self.tableView reloadData];

}

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
    
    
    NSLog(@"------%f   %f   %f" , alpha , offset  , tabOffsetY);
    
    if (self.style.allowStretchableHeader){
        //下拉放大 必须实现
        [self.stretchableTableHeaderView scrollViewDidScroll:scrollView];
        
        if (offset >= tabOffsetY) {
            if (_mainCanScroll) {
                [self changeMainTableViewAllowScroll:NO];
            }
        }
        
        if (!_mainCanScroll){
            scrollView.contentOffset = CGPointMake(0, tabOffsetY);
        }
        
    } else {
        
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
    [self setSelectedIndex:self.defaultSelectedIndex];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //要减去导航栏 状态栏 以及 sectionheader的高度
    
    CGFloat height = self.style.scrollContentViewTableViewHeight - 64 - CGRectGetHeight(self.barItem.frame);
    if (height <= 0){
        height = 0;
    }
    return height;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.barItem;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //sectionheader的高度，这是要放分段控件的
    return CGRectGetHeight(self.barItem.frame);
}


#pragma mark -- WMScrollContentViewDelegate

/// 分页控制器手势滑动控制当前滚动视图实付可以滚动
- (void)scrollContentView:(WMScrollContentView *)scrollContentView pageControlScroll:(UIScrollView *)scrollView{
    
    
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {  /// 当滑动下面的PageView时，当前要禁止滑动
        NSLog(@"bottomSView 滑动了");

        if (self.tableViewHeaderViewHeight > 0){
            self.tableView.scrollEnabled = NO;
        }

    } else if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {  /// bottomView停止滑动了  当前页可以滑动
        NSLog(@"结束拖拽");
        
        if (self.tableViewHeaderViewHeight > 0){
            self.tableView.scrollEnabled = YES;
        }
    }
}

/// 控制器的滚动视图滚动

- (void)scrollContentView:(WMScrollContentView *)scrollContentView controlScroll:(UIScrollView *)scrollView canScroll:(BOOL)canScroll{
    
    
    //// 主滚动视图offY <= 0 的时候。这个时候下拉子的滚动视图是主的视图不能滚动 子视图滚动
    
    
    if (self.tableView.scrollEnabled == NO) return;  /// 父滚动视图允许滚动才执行两个滚动视图的滚动切换
    
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (self.style.allowStretchableHeader){
        
        if(_tableView.bounces) {
            if (offsetY < 0){
                
                if (canScroll == YES){
                    //子控制器到顶部了 主控制器可以滑动
                    [self changeMainTableViewAllowScroll:YES];
                }
                
            }
            
            if (!canScroll && scrollView.contentOffset.y != 0) {
                [scrollView setContentOffset:CGPointZero];
            }
        }else {
            NSLog(@"offsetY == >%g",offsetY);
            NSLog(@"tableView == >%g",_tableView.contentOffset.y);

            if (offsetY < 0){
                
                if (canScroll == YES){
                    //子控制器到顶部了 主控制器可以滑动
                    [self changeMainTableViewAllowScroll:YES];
                }
               
            }
            
            if (!canScroll && scrollView.contentOffset.y != 0) {
                if (_tableView.contentOffset.y > 0 && _tableView.contentOffset.y < 212) {
                    [scrollView setContentOffset:CGPointZero];
                }
            }

        }
        
    
    } else {
    
    }
}

/// 处理pageView滚动进度
- (void)scrollContentView:(WMScrollContentView *)scrollContentView adjustUIWithProgress:(CGFloat)progress currentIndex:(NSInteger)currentIndex{
    
    /// 处理barItem切换
    [self.barItem adjustUIWithProgress:progress currentIndex:currentIndex];
    
}

/// 从当前页滚动到指定页
- (void)scrollContentView:(WMScrollContentView *)scrollContentView scrollToIndex:(NSInteger)toIndex currentIndex:(NSInteger)current{
    
    [self.barItem scrollToIndex:toIndex currentIndex:current animated:NO];
}

- (void)scrollContentView:(WMScrollContentView *)scrollContentView scrollAnimating:(BOOL)scrollAnimating{
    
    [self.barItem setScrollAnimating:NO];
    
}

#pragma mark -- WMScrollBarItemDelegate

- (NSString *)barItem:(WMScrollBarItem *)barItem titleForItemAtIndex:(NSInteger)index{
    NSString * title;
    
    if ([self.dataSource respondsToSelector:@selector(scrollPageView:titleForBarItemAtIndex:)]){
        title = [self.dataSource scrollPageView:self titleForBarItemAtIndex:index];
    }
    return title;
}


/// 选择了barItem需要切换界面
- (void)barItem:(WMScrollBarItem *)barItem didSelectIndex:(NSInteger)index{
    
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

/// 刷新数据
- (void)reloadScrollBar{
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
        _tableView.bounces = NO;
        [_tableView setShowsVerticalScrollIndicator:NO];
        [_tableView setShowsHorizontalScrollIndicator:NO];
    }
    
    return _tableView;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
