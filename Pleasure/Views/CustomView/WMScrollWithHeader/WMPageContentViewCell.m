//
//  WMPageContentViewCell.m
//  Pleasure
//
//  Created by Sper on 2017/7/27.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMPageContentViewCell.h"

@interface WMPageContentViewCell()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>
@property (nonatomic , strong) UIPageViewController * pageViewController;
@property (nonatomic , strong) NSMutableArray<WMBaseContentController *> *viewControllers;
@property (strong , nonatomic) UIScrollView *pageScrollView;
@property (nonatomic , strong) UITableView * tableView;
@end

@implementation WMPageContentViewCell

- (void)dealloc {
    //清除监听
    [self.pageScrollView removeObserver:self forKeyPath:@"panGestureRecognizer.state"];
}

+ (instancetype)cellForTableView:(UITableView *)tableView{
    WMPageContentViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WMPageContentViewCell class])];
    if (cell == nil){
        cell = [[WMPageContentViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([WMPageContentViewCell class])];
        cell.tableView = tableView;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self wm_customPageView];
    }
    return self;
}

- (void)setDataSource:(id<WMPageContentViewCellDataSource>)dataSource{
    _dataSource = dataSource;
    
    [self wm_configData];
}

- (void)wm_configData{
    NSInteger count = 1;
    if([self.dataSource respondsToSelector:@selector(numberOfCountInContentCell:)]){
        count = [self.dataSource numberOfCountInContentCell:self];
    }
    
    for (int i = 0 ; i < count ; i++){
        if ([self.dataSource respondsToSelector:@selector(contentCell:contentControllerAtIndex:)]){
            WMBaseContentController * contentController = [self.dataSource contentCell:self contentControllerAtIndex:i];
            
            NSAssert([contentController isKindOfClass:[WMBaseContentController class]], @"传入的控制器必须是 WMBaseContentController 的子类");
            
            [self.viewControllers addObject:contentController];
        }
    }
    
    
    [self.pageViewController setViewControllers:@[[self.viewControllers firstObject]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
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
        }
    }
}


//监听拖拽手势的回调
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    ////当滑动下面的PageView时，当前要禁止滑动
    if (((UIScrollView *)object).panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"bottomSView 滑动了");
        
        self.tableView.scrollEnabled = NO;
        
    } else if (((UIScrollView *)object).panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"结束拖拽");
        //bottomView停止滑动了  当前页可以滑动
        self.tableView.scrollEnabled = YES;
    }
}


////用于让pageView到边缘时不让滑动一段距离的问题
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    scrollView.bounces = NO;
//}


/// 滚动到指定页
- (void)setSelectIndex:(NSInteger)selectIndex {
    if (selectIndex < self.viewControllers.count){
        [self.pageViewController setViewControllers:@[self.viewControllers[selectIndex]]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO
                                         completion:nil];
    }
}

- (void)setCanScroll:(BOOL)canScroll{
    _canScroll = canScroll;
    
    //修改所有的子控制器的状态
    for (WMBaseContentController *ctrl in self.viewControllers) {
        ctrl.canScroll = canScroll;
        if (!canScroll && ctrl.isViewLoaded) {
            ctrl.tableView.contentOffset = CGPointZero;
        }
    }
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
    if (([_viewControllers count] == 0) || (index >= [_viewControllers count])) {
        return nil;
    }
    // 获取控制器类
    UIViewController *dataViewController = _viewControllers[index];
    return dataViewController;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = [_viewControllers indexOfObject:(WMBaseContentController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    // 返回的ViewController，将被添加到相应的UIPageViewController对象上。
    return [self viewControllerAtIndex:index];
    
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSUInteger index = [_viewControllers indexOfObject:(WMBaseContentController *)viewController];
    if (index == NSNotFound || index == ([_viewControllers count] - 1)) {
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
    
    NSUInteger index = [self.viewControllers indexOfObject:self.pageViewController.viewControllers.firstObject];
    [[NSNotificationCenter defaultCenter] postNotificationName:WMCenterPageViewScroll object:[NSNumber numberWithUnsignedInteger:index]];
}



- (NSMutableArray<WMBaseContentController *> *)viewControllers{
    if (_viewControllers == nil){
        _viewControllers = [NSMutableArray array];
    }
    return _viewControllers;
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

