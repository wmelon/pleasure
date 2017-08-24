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

#define PADDING                  10

@interface WMPhotoBrowser () <UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout ,UIGestureRecognizerDelegate , UIViewControllerTransitioningDelegate>{
    // Present
    UIView *_senderViewForAnimation;
    
    /// 是否正在拉动图片
    BOOL _isdraggingPhoto;
    
    UIWindow *_applicationWindow;
}

@property (nonatomic , strong) UICollectionView *collectionView;

@property (nonatomic , strong) NSMutableArray<WMPhotoModel *> *photos;

@property (nonatomic , assign) BOOL isPresented;

@property (nonatomic , strong) WMZoomingScrollCell *zoomingScrollCell;

@property (nonatomic , assign) CGPoint panGestureBeginPoint;

/// 手势过度管理器
@property (nonatomic , strong) WMInteractiveTransition *interactiveTransition;

@property (nonatomic , strong) UIImageView *MyImageView;
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
    
    self.transitioningDelegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.interactiveTransition = [WMInteractiveTransition interactiveTransitionWithTransitionType:(WMInteractiveTransitionTypeDismiss) gestureDirection:(WMInteractiveTransitionGestureDirectionDown)];
    __weak typeof(self) weakself = self;
    [self.interactiveTransition addPanGestureForViewController:self gestureConifg:^{
        [weakself wm_dismiss];
    }];
    
    _MyImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    UIImage *image = [UIImage imageNamed:@"pc_bg"];
    _MyImageView.userInteractionEnabled = YES;
    _MyImageView.image =image;
    CGFloat width = kScreenWidth;
    CGFloat height = kScreenWidth * image.size.height / image.size.width;
    _MyImageView.frame = CGRectMake(0, 0, width, height);
    [self.view addSubview:_MyImageView];
}
- (void)wm_dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.hidesBottomBarWhenPushed = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
//    [self.view addSubview:self.collectionView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wm_dismiss)];
    [self.view addGestureRecognizer:tap];
    
    [self updateNavigation];
}

#pragma mark -- UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    WMBaseTransitionAnimator *animator = [WMBaseTransitionAnimator transitionAnimatorWithTransitionType:(WMTransitionAnimatorTypePresent)];
    [animator setSrcView:self.srcImageView];
//    [animator setDestFrame:[self wm_getCurrentImageFrame]];
    [animator setDestView:self.MyImageView];
    return animator;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    WMBaseTransitionAnimator *animator = [WMBaseTransitionAnimator transitionAnimatorWithTransitionType:(WMTransitionAnimatorTypeDismiss)];
    [animator setSrcView:self.srcImageView];
//    [animator setDestView:[self wm_getDestImageView]];
//    [animator setDestFrame:[self wm_getCurrentImageFrame]];
    [animator setDestView:self.MyImageView];
    return animator;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator{
    return self.interactiveTransition.interation ? self.interactiveTransition : nil;
}

- (CGRect)wm_getCurrentImageFrame{
    WMPhotoModel *photo = self.photos[_currentIndex];
    CGFloat width = self.view.frame.size.width;
    CGFloat height = width * photo.image.size.height / photo.image.size.width;
    CGRect frame = CGRectMake(0, (self.view.frame.size.height - height) / 2, width, height);
    return frame;
}
- (UIImageView *)wm_getDestImageView{
    
    WMZoomingScrollCell *cell = (WMZoomingScrollCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
    UIImageView * imageView = cell.imageShowView;
    
    return imageView;
}

#pragma mark -- public method

- (void)setCurrentPhotoIndex:(NSUInteger)index{
    _currentIndex = index;
    [self updateNavigation];
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

/// 滚动到默认起始位置
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self wm_photoScrollToShow];
}

/// 滚动到显示指定图片
- (void)wm_photoScrollToShow{
    if (_currentIndex < self.photos.count){
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
        [self updateNavigation];
    }
}

/// 返回上一页
- (void)wm_backToPrevious{
    [self.navigationController popViewControllerAnimated:YES];
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
    _zoomingScrollCell = cell;
    [cell setPhotoModel:self.photos[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offSetX = scrollView.contentOffset.x;
    _currentIndex = (offSetX  + 0.5 * self.collectionView.frame.size.width) / self.collectionView.frame.size.width;
    [self updateNavigation];
}

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
