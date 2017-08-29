//
//  WMScrollContentView.m
//  AllDemo
//
//  Created by Sper on 2017/7/28.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMScrollContentView.h"

@interface WMScrollContentView()<UIPageViewControllerDelegate,UIPageViewControllerDataSource , UIScrollViewDelegate>

/// 显示的控制器数组
@property (nonatomic , strong) NSArray *showViewControllers;

/// 分页控制器
@property (nonatomic , strong) UIPageViewController * pageViewController;

/// pageView的滚动视图
@property (strong , nonatomic) UIScrollView *pageScrollView;

/// 存储所有分页的控制器里面的滚动视图
@property (nonatomic , strong) NSMutableArray<UIScrollView *> * controlScrollViewArray;

@end

@implementation WMScrollContentView

- (void)dealloc {
    //清除监听
    @try {
        [self.pageScrollView removeObserver:self forKeyPath:@"panGestureRecognizer.state"];
    }
    @catch (NSException *exception) {
        NSLog(@"多次删除了");
    }
    
    [self.controlScrollViewArray enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        @try {
            [obj removeObserver:self forKeyPath:@"contentOffset"];
        }
        @catch (NSException *exception) {
            NSLog(@"多次删除了");
        }
        
    }];
}

+ (instancetype)cellForTableView:(UITableView *)tableView showViewControllers:(NSArray *)showViewControllers{
    WMScrollContentView * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WMScrollContentView class])];
    if (cell == nil){
        cell = [[WMScrollContentView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([WMScrollContentView class])];
    }
    cell.showViewControllers = showViewControllers;
    /// 初始化存储滚动视图的数组
    NSMutableArray<UIScrollView *> * array = [NSMutableArray array];
    
    for (int i = 0 ; i < showViewControllers.count ; i++){
        
        [array addObject:[UIScrollView new]];
    }
    
    cell.controlScrollViewArray = array;
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self wm_customPageView];
    }
    return self;
}

- (void)wm_customPageView{
    NSDictionary *option = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:UIPageViewControllerSpineLocationMin] forKey:UIPageViewControllerOptionSpineLocationKey];
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:option];
    
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    self.pageViewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:self.pageViewController.view];
    
    
    for (UIView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            //监听拖动手势
            self.pageScrollView = (UIScrollView *)view;
            [self.pageScrollView addObserver:self
                                  forKeyPath:@"panGestureRecognizer.state"
                                     options:NSKeyValueObservingOptionNew
                                     context:nil];
            
            /// 监听滚动的contentOffSet 变换
            self.pageScrollView.delegate = self;
        }
    }
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.pageViewController.view.frame = self.contentView.bounds;
}

/// 根据当前显示的控制器得到滚动视图
- (void)wm_getScrollViewWithIndex:(NSInteger)index{
    if (index < self.showViewControllers.count){
        
        __block UIScrollView *controlScrollView;
        
        UIViewController *viewControl = self.showViewControllers[index];
        if (viewControl.isViewLoaded){
            [viewControl.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([obj isKindOfClass:[UIScrollView class]]){
                    
                    if (obj.superview && ([obj.superview isKindOfClass:[UITableView class]] || [obj.superview isKindOfClass:[UICollectionView class]])){

                        controlScrollView = (UIScrollView *)obj.superview;
                    }else {
                        
                        controlScrollView = obj;
                    }
                    if (![self.controlScrollViewArray containsObject:controlScrollView]){
                        [controlScrollView addObserver:self forKeyPath:@"contentOffset"
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];
                    }
                }
            }];
        }
        
        if (controlScrollView){
            if (index < self.controlScrollViewArray.count){  /// 更新
                
                [self.controlScrollViewArray replaceObjectAtIndex:index withObject:controlScrollView];
            }
        }
    }
}

//监听拖拽手势的回调
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentOffset"]){   //// 监听tableView滚动
        
        if ([self.delegate respondsToSelector:@selector(scrollContentView:controlScroll:canScroll:)]){
            [self.delegate scrollContentView:self controlScroll:object canScroll:self.canScroll];
        }
        
    }else if ([keyPath isEqualToString:@"panGestureRecognizer.state"]){
        
        if ([self.delegate respondsToSelector:@selector(scrollContentView:pageControlScroll:)]){
            [self.delegate scrollContentView:self pageControlScroll:object];
        }
        
    }else {
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - pageViewController的滚动视图滚动监听

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat pageWidth = self.frame.size.width;
    CGFloat offPercent = 0.0;
    
    for (UIViewController * vc in self.showViewControllers) {
        
        CGPoint p = [vc.view convertPoint:CGPointZero toView:_pageViewController.view];
        
        if (p.x > 0.0 && p.x < pageWidth){
            NSInteger index = [self.showViewControllers indexOfObject:vc];
            CGFloat stimateOffSetX = index * pageWidth - (p.x);
            
//            offPercent = (pageWidth - p.x) / pageWidth;
            offPercent = stimateOffSetX / pageWidth;
            _selectIndex = (stimateOffSetX + pageWidth / 2) / pageWidth;
            
            if (stimateOffSetX <= 0) return;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(scrollContentView:adjustUIWithProgress:currentIndex:)]){
        
        [self.delegate scrollContentView:self adjustUIWithProgress:offPercent currentIndex:_selectIndex];
    }
}

/// 滚动完成之后更新数据
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([self.delegate respondsToSelector:@selector(scrollContentView:scrollAnimating:)]){
        [self.delegate scrollContentView:self scrollAnimating:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(scrollContentView:scrollAnimating:)]){
        [self.delegate scrollContentView:self scrollAnimating:NO];
    }
}

#pragma mark -- public method

/// 滚动到指定页
- (void)setSelectIndex:(NSInteger)selectIndex{
    if (selectIndex < self.showViewControllers.count){
        _selectIndex = selectIndex;
        
        [self.pageViewController setViewControllers:@[self.showViewControllers[selectIndex]]
                                          direction:UIPageViewControllerNavigationDirectionForward || UIPageViewControllerNavigationDirectionReverse
                                           animated:NO
                                         completion:^(BOOL finished) {
                                         }];
        /// 获取控制器的滚动视图
        [self wm_getScrollViewWithIndex:selectIndex];
    }

}

- (void)setCanScroll:(BOOL)canScroll{
    _canScroll = canScroll;
    
    //修改所有的子控制器的滚动视图的状态
    [self.controlScrollViewArray enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (!canScroll){
            obj.contentOffset = CGPointZero;
        }
        
    }];
}

#pragma mark - UIPageViewControllerDataSource

/**
 *  得到相应的VC对象
 *
 *  @param index 数组下标
 *
 *  @return 视图控制器
 */
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([_showViewControllers count] == 0) || (index >= [_showViewControllers count])) {
        return nil;
    }
    // 获取控制器类
    UIViewController *dataViewController = _showViewControllers[index];
    return dataViewController;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = [_showViewControllers indexOfObject:viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    // 返回的ViewController，将被添加到相应的UIPageViewController对象上。
    return [self viewControllerAtIndex:index];
    
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSUInteger index = [_showViewControllers indexOfObject:viewController];
    if (index == NSNotFound || index == ([_showViewControllers count] - 1)) {
        return nil;
    }
    index++;
    return [self viewControllerAtIndex:index];
}

/**
 *  @brief 该方法会在 UIPageViewController 翻页效果出发之后，尚未完成时执行
 *
 *  @param pageViewController      翻页控制器
 *  @param finished                动画完成
 *  @param previousViewControllers 前一个控制器(非当前)
 *  @param completed               转场动画执行完
 */
- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    
    NSUInteger index = [self.showViewControllers indexOfObject:self.pageViewController.viewControllers.firstObject];
    
    /// 获取控制器的滚动视图
    [self wm_getScrollViewWithIndex:index];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
