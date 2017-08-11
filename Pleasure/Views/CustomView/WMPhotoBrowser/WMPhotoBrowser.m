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

#define PADDING                  10

@interface WMPhotoBrowser () <UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout ,UIGestureRecognizerDelegate>{
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

@property (nonatomic, assign) CGPoint panGestureBeginPoint;

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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.hidesBottomBarWhenPushed = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
    [self.view addSubview:self.collectionView];
    
//    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
//    press.delegate = self;
//    [self.view addGestureRecognizer:press];
//    
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
//    [self.view addGestureRecognizer:pan];
    
    [self updateNavigation];
}


- (void)longPressGestureRecognized:(UIGestureRecognizer *)g{
//    if (!_isPresented) return;
//    
//    YYPhotoGroupCell *tile = [self cellForPage:self.currentPage];
//    if (!tile.imageView.image) return;
//    
//    // try to save original image data if the image contains multi-frame (such as GIF/APNG)
//    id imageItem = [tile.imageView.image yy_imageDataRepresentation];
//    YYImageType type = YYImageDetectType((__bridge CFDataRef)(imageItem));
//    if (type != YYImageTypePNG &&
//        type != YYImageTypeJPEG &&
//        type != YYImageTypeGIF) {
//        imageItem = tile.imageView.image;
//    }
//    
//    UIActivityViewController *activityViewController =
//    [[UIActivityViewController alloc] initWithActivityItems:@[imageItem] applicationActivities:nil];
//    if ([activityViewController respondsToSelector:@selector(popoverPresentationController)]) {
//        activityViewController.popoverPresentationController.sourceView = self;
//    }
//    
//    UIViewController *toVC = self.toContainerView.viewController;
//    if (!toVC) toVC = self.viewController;
//    [toVC presentViewController:activityViewController animated:YES completion:nil];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender {
//    // Initial Setup
//    UIScrollView *scrollView = self.zoomingScrollCell.zoomScrollView;
//    //IDMTapDetectingImageView *scrollView.photoImageView = scrollView.photoImageView;
//    
//    static float firstX, firstY;
//    
//    float viewHeight = scrollView.frame.size.height;
//    float viewHalfHeight = viewHeight/2;
//    
//    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
//    
//    // Gesture Began
//    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
////        [self setControlsHidden:YES animated:YES permanent:YES];
//        
//        firstX = [scrollView center].x;
//        firstY = [scrollView center].y;
//        
//        _senderViewForAnimation.hidden = YES;
//        
//        _isdraggingPhoto = YES;
//        [self setNeedsStatusBarAppearanceUpdate];
//    }
//    
//    translatedPoint = CGPointMake(firstX, firstY+translatedPoint.y);
//    [scrollView setCenter:translatedPoint];
//    
//    float newY = scrollView.center.y - viewHalfHeight;
//    float newAlpha = 1 - fabsf(newY)/viewHeight; //abs(newY)/viewHeight * 1.8;
//    
//    self.view.opaque = YES;
//    
//    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:newAlpha];
//    
//    // Gesture Ended
//    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
//        if(scrollView.center.y > viewHalfHeight+40 || scrollView.center.y < viewHalfHeight-40) // Automatic Dismiss View
//        {
//            if (_senderViewForAnimation) {
//                [self performCloseAnimationWithScrollView:scrollView];
//                return;
//            }
//            
//            CGFloat finalX = firstX, finalY;
//            
//            CGFloat windowsHeigt = [_applicationWindow frame].size.height;
//            
//            if(scrollView.center.y > viewHalfHeight+30) // swipe down
//                finalY = windowsHeigt*2;
//            else // swipe up
//                finalY = -viewHalfHeight;
//            
//            CGFloat animationDuration = 0.35;
//            
//            [UIView beginAnimations:nil context:NULL];
//            [UIView setAnimationDuration:animationDuration];
//            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//            [UIView setAnimationDelegate:self];
//            [scrollView setCenter:CGPointMake(finalX, finalY)];
//            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
//            [UIView commitAnimations];
//            
////            [self performSelector:@selector(doneButtonPressed:) withObject:self afterDelay:animationDuration];
//        }
//        else // Continue Showing View
//        {
//            _isdraggingPhoto = NO;
//            [self setNeedsStatusBarAppearanceUpdate];
//            
//            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
//            
//            CGFloat velocityY = (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
//            
//            CGFloat finalX = firstX;
//            CGFloat finalY = viewHalfHeight;
//            
//            CGFloat animationDuration = (ABS(velocityY)*.0002)+.2;
//            
//            [UIView beginAnimations:nil context:NULL];
//            [UIView setAnimationDuration:animationDuration];
//            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//            [UIView setAnimationDelegate:self];
//            [scrollView setCenter:CGPointMake(finalX, finalY)];
//            [UIView commitAnimations];
//        }
//    }
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
    if (_currentIndex < self.photos.count){
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
        
    }
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
        [self.collectionView reloadData];
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
