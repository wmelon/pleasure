//
//  WMPhotoBrowser.m
//  Pleasure
//
//  Created by Sper on 2017/8/10.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMPhotoBrowser.h"
#import "SDImageCache.h"
#import "WMZoomingScrollCell.h"
#import "WMInteractiveTransition.h"
#import "WMBaseTransitionAnimator.h"
#import "WMTopToolBar.h"

#define PADDING                  10

@interface WMPhotoBrowser () <UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout ,UIGestureRecognizerDelegate , UIViewControllerTransitioningDelegate , WMBaseTransitionAnimatorDelegate , WMZoomingScrollCellDelegate>{
    
    UIWindow *_applicationWindow;
}
/// 原显示图片的视图
@property (nonatomic , strong) UIImageView *srcImageView;

/// 图片显示的视图
@property (nonatomic , strong) UICollectionView *collectionView;

/// 图片数据源
@property (nonatomic , strong) NSMutableArray<WMPhotoModel *> *photos;

/// 是否正在转场动画 默认是 NO
@property (nonatomic , assign) BOOL isPresenting;

/// 手势过度管理器
@property (nonatomic , strong) WMInteractiveTransition *interactiveTransition;

/// 显示图片描述的视图
@property (nonatomic , strong) WMCaptionView *captionView;

/// 头部工具栏
@property (nonatomic , strong) WMTopToolBar *topTollBar;

@end

@implementation WMPhotoBrowser

- (void)dealloc{
    [[SDImageCache sharedImageCache] clearMemory]; // clear memory
    NSLog(@"dealloc -- %@" , self);
}

#pragma mark - Init
- (id)initWithDelegate:(id <WMPhotoBrowserDelegate>)delegate {
    if ((self = [self init])) {
        _delegate = delegate;
        [self wm_initialisation];
        [self wm_configData];
    }
    return self;
}

- (instancetype)initWithPhotos:(NSArray<WMPhotoModel *> *)photosArray{
    if (self = [super  init]){
        [self.photos setArray:photosArray];
        [self wm_initialisation];
    }
    return self;
}

- (void)wm_initialisation{
    _applicationWindow = [[[UIApplication sharedApplication] delegate] window];
    [self setShouldShowRightItem:YES];
    self.transitioningDelegate = self;
    self.interactiveTransition = [WMInteractiveTransition interactiveTransitionWithTransitionType:(WMInteractiveTransitionTypeDismiss) gestureDirection:(WMInteractiveTransitionGestureDirectionDown)];
    __weak typeof(self) weakself = self;
    [self.interactiveTransition addPanGestureForViewController:self gestureConifg:^{
        [weakself wm_dismiss];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.hidesBottomBarWhenPushed = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.captionView];
    [self updateNavigation];
}

#pragma mark -- UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    WMBaseTransitionAnimator *animator = [WMBaseTransitionAnimator transitionAnimatorWithTransitionType:(WMTransitionAnimatorTypePresent)];
    animator.delegate = self;
    _isPresenting = YES;
    return animator;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    WMBaseTransitionAnimator *animator = [WMBaseTransitionAnimator transitionAnimatorWithTransitionType:(WMTransitionAnimatorTypeDismiss)];
    animator.delegate = self;
    return animator;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator{
    return self.interactiveTransition.interation ? self.interactiveTransition : nil;
}

#pragma mark -- WMZoomingScrollCellDelegate
- (void)tapHiddenPhotoBrowserAtZoomingScrollCell:(WMZoomingScrollCell *)zoomingScrollCell{
    if (_srcImageView){  /// 如果是采用自定义转场动画打开的图片浏览  单击是关闭图片浏览
        [self wm_dismiss];
    }else if (_shouldShowTopToolBar){   ///  如果是头部有自定制的工具栏图片浏览   单击是隐藏图片描述和头部工具栏
        [UIView animateWithDuration:0.25 animations:^{
            if (self.topTollBar.alpha == 0.0){   /// 显示图片描述和头部工具栏
                self.topTollBar.alpha = 1.0;
                self.captionView.alpha = 1.0;

            }else {      /// 隐藏图片描述和头部工具栏
                
                self.topTollBar.alpha = 0.0;
                self.captionView.alpha = 0.0;
            }
            
        }];
    }else {  /// 隐藏导航栏

        [UIView animateWithDuration:0.25 animations:^{
            if (self.navigationController.navigationBar.alpha == 0.0){
                self.navigationController.navigationBar.alpha = 1.0;
            }else {
                self.navigationController.navigationBar.alpha = 0.0;
            }
        }];
    }
}

#pragma mark -- WMBaseTransitionAnimatorDelegate 

- (UIImageView *)srcImageViewForTransitionAnimator:(WMBaseTransitionAnimator *)transitionAnimator{
    return self.srcImageView;
}

- (UIImageView *)destImageViewForTransitionAnimator:(WMBaseTransitionAnimator *)transitionAnimator{
    return [self wm_getDestImageView];
}

- (void)animationFinishedAtTransitionAnimator:(WMBaseTransitionAnimator *)transitionAnimator{
    _isPresenting = NO;
    /// 当前正在显示的cell视图
    WMZoomingScrollCell *cell = (WMZoomingScrollCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
    [cell wm_displayImageWithIsPresenting:_isPresenting tempImage:self.srcImageView.image];
}

- (UIImageView *)wm_getDestImageView{
    if (self.collectionView == nil) return nil;
    WMZoomingScrollCell *cell = (WMZoomingScrollCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
    cell.delegate = self;
    UIImageView * imageView = cell.imageShowView;
    
    return imageView;
}

#pragma mark -- public method

- (void)setShouldShowRightItem:(BOOL)shouldShowRightItem{
    _shouldShowRightItem = shouldShowRightItem;
    if (_shouldShowRightItem){
        [self showRightItem:nil image:[UIImage imageNamed:@"icon_delete_image_wm"]];
    }
}
- (void)setShouldShowTopToolBar:(BOOL)shouldShowTopToolBar{
    _shouldShowTopToolBar = shouldShowTopToolBar;
    if (_shouldShowTopToolBar){
        /// 显示了头部工具栏就不能显示系统的导航栏
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        if (!self.topTollBar.superview){
            [self.view addSubview:self.topTollBar];
        }
    }
}

- (void)setCurrentPhotoIndex:(NSUInteger)index{
    _currentIndex = index;
    [self wm_updateSrcImageView];
    /// 滚动到默认起始位置
    [self wm_photoScrollToShow];
    [self wm_configCaptionViewAtIndex:index];
}

- (void)reloadData{
    [self setDelegate:_delegate];
}

- (void)setDelegate:(id<WMPhotoBrowserDelegate>)delegate{
    _delegate = delegate;
    [self wm_configData];
}

- (void)wm_configData{
    
    if ([self.delegate respondsToSelector:@selector(numberOfPhotosInPhotoBrowser:)]){
        
        NSInteger photoCount = [self.delegate numberOfPhotosInPhotoBrowser:self];
        
        
        [self.photos removeAllObjects];
        
        WMPhotoModel *photo;
        for (int index = 0 ; index < photoCount ; index++){
            
            if ([self.delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:)]){
                
                photo = [self.delegate photoBrowser:self photoAtIndex:index];
            }
            [self.photos addObject:photo];
        }
    }
    
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = self.view.frame.size;
    self.collectionView.frame = CGRectMake(-PADDING, 0, self.view.frame.size.width + 2 * PADDING, self.view.frame.size.height);
    [self wm_photoScrollToShow];
}

/// 滚动到显示指定图片
- (void)wm_photoScrollToShow{
    if (_currentIndex < self.photos.count){
        [self.collectionView setContentOffset:CGPointMake(_currentIndex * self.collectionView.frame.size.width, 0) animated:NO];
        [self updateNavigation];
    }
}

/// 返回上一页
- (void)wm_backToPrevious{
    [self.navigationController popViewControllerAnimated:YES];
}

/// 模态弹出视图返回
- (void)wm_dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- UICollectionViewDelegate and UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WMZoomingScrollCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WMZoomingScrollCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    /// 设置显示数据
    [cell wm_setDataPhotoModel:self.photos[indexPath.row]];
    [cell wm_displayImageWithIsPresenting:_isPresenting tempImage:self.srcImageView.image];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offSetX = scrollView.contentOffset.x;
    _currentIndex = (offSetX  + 0.5 * self.collectionView.frame.size.width) / self.collectionView.frame.size.width;
    
    [self wm_updateSrcImageView];
    [self updateNavigation];
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self wm_configCaptionViewAtIndex:_currentIndex];
}

- (void)wm_updateSrcImageView{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:imageViewAtIndex:)]){  /// 滚动页面重新为源视图赋值
        self.srcImageView = [self.delegate photoBrowser:self imageViewAtIndex:_currentIndex];
    }
}

- (void)wm_configCaptionViewAtIndex:(NSUInteger)index{
    CGSize size = [self.captionView captionViewSizeWithPhoto:[self photoAtIndex:index] currentIndex:(index + 1) count:_photos.count captionWidth:self.view.bounds.size.width];
    self.captionView.frame = [self frameForCaptionView:self.captionView size:size];
}

#pragma mark -- Data

- (WMPhotoModel *)photoAtIndex:(NSUInteger)index {
    WMPhotoModel *photo = nil;
    if (index < _photos.count) {
        if ([self.photos objectAtIndex:index]){
            photo = [_photos objectAtIndex:index];
        }else{
            if ([self.delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:)]){
                photo = [_delegate photoBrowser:self photoAtIndex:index];
            }
        }
    }
    return photo;
}

#pragma mark - Frame Calculations
- (CGRect)frameForCaptionView:(WMCaptionView *)captionView size:(CGSize)size{
    CGRect pageFrame = self.view.bounds;
    CGRect captionFrame =  CGRectMake(pageFrame.origin.x,pageFrame.size.height - size.height,pageFrame.size.width,size.height);
    return CGRectIntegral(captionFrame);
}

#pragma mark -- control hidden and show



#pragma mark - Navigation

- (void)updateNavigation {
    
    // Title
    NSUInteger numberOfPhotos = self.photos.count;
    if (_currentIndex < numberOfPhotos){
        self.title = [NSString stringWithFormat:@"%lu %@ %lu", (unsigned long)(_currentIndex+1), NSLocalizedString(@"of", @"Used in the context: 'Showing 1 of 3 items'"), (unsigned long)numberOfPhotos];
    }else {
        self.title = [NSString stringWithFormat:@"%lu %@ %lu", (unsigned long)(1), NSLocalizedString(@"of", @"Used in the context: 'Showing 1 of 3 items'"), (unsigned long)numberOfPhotos];
    }
    
}

- (UIButton *)showRightItem:(NSString *)title image:(UIImage *)image{
    UIButton *button = [UIButton buttonWithImage:image title:title target:self action:@selector(rightAction:)];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    button.contentEdgeInsets = UIEdgeInsetsZero;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addItemForLeft:NO withItem:item spaceWidth:0];
    return button;
}
-(void)addItemForLeft:(BOOL)left withItem:(UIBarButtonItem*)item spaceWidth:(CGFloat)width {
    UIBarButtonItem *space = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                              target:nil action:nil];
    space.width = width;
    
    if (left) {
        self.navigationItem.leftBarButtonItems = @[space,item];
    } else {
        self.navigationItem.rightBarButtonItems = @[space,item];
    }
}

- (void)rightAction:(UIButton *)button{
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:actionButtonPressedForPhotoAtIndex:)]){
        [self.delegate photoBrowser:self actionButtonPressedForPhotoAtIndex:_currentIndex];
        [self.photos removeObjectAtIndex:_currentIndex];
        if (_currentIndex > 0){
            _currentIndex--;
        }
        [self.collectionView reloadData];
        [self wm_photoScrollToShow];
        if (self.photos.count == 0){
            [self wm_backToPrevious];
        }
    }
}

#pragma mark -- getter
- (WMCaptionView *)captionView{
    if (_captionView == nil){
        _captionView = [[WMCaptionView alloc] init];
    }
    return _captionView;
}
- (WMTopToolBar *)topTollBar{
    if (_topTollBar == nil){
        __weak typeof(self) weakself = self;
        _topTollBar = [[WMTopToolBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64) buttonClickHandle:^(WMButtonType buttonType) {
            if (buttonType == WMButtonTypeClose){
                if (self.navigationController){
                    [weakself wm_backToPrevious];
                }else {
                    [weakself wm_dismiss];
                }
            }else {
                /// 详情按钮点击事件处理
            }
        }];
    }
    return _topTollBar;
}
- (UICollectionView *)collectionView{

    if (_collectionView == nil){
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = 2 *PADDING;
        layout.sectionInset = UIEdgeInsetsMake(0, PADDING, 0, PADDING);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-PADDING, 0, self.view.frame.size.width + 2 * PADDING, self.view.frame.size.height) collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[WMZoomingScrollCell class] forCellWithReuseIdentifier:NSStringFromClass([WMZoomingScrollCell class])];
        
    }
    
    return _collectionView;
}

- (NSMutableArray<WMPhotoModel *> *)photos{
    if (_photos == nil){
        _photos = [NSMutableArray array];
    }
    return _photos;
}

- (void)didReceiveMemoryWarning {
    // Release any cached data, images, etc that aren't in use.
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
