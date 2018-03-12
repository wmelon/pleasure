//
//  WMZoomingScrollCell.m
//  Pleasure
//
//  Created by Sper on 2017/8/10.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMZoomingScrollCell.h"
#import <DACircularProgressView.h>

@interface WMZoomingScrollCell() <UIScrollViewDelegate , WMTapDetectingImageViewDelegate>

/// 接收手势的视图
@property (nonatomic , strong) WMTapDetectingBgView *tapBgView;

/// 图片加载进度条
@property (nonatomic , strong) DACircularProgressView *loadingIndicator;

/// 加载失败显示图片
@property (nonatomic , strong) UIImageView *loadingError;

/// 缩放的视图
@property (nonatomic , strong , readonly) UIScrollView *zoomScrollView;

/// 图片数据源
@property (nonatomic , strong) WMPhotoModel *photoModel;

@end

@implementation WMZoomingScrollCell

- (instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]){
    
        [self wm_configView];
    }
    return self;
}

- (void)wm_configView{

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:scrollView];
    _zoomScrollView = scrollView;
    
    
    WMTapDetectingBgView *tapBgView = [[WMTapDetectingBgView alloc] init];
    tapBgView.tapDelegate = self;
    tapBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tapBgView.backgroundColor = [UIColor clearColor];
    [_zoomScrollView addSubview:tapBgView];
    self.tapBgView = tapBgView;
    
    
    WMTapDetectingImageView *imageView = [[WMTapDetectingImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.tapDelegate = self;
    [_zoomScrollView addSubview:imageView];
    _imageShowView = imageView;
    
    
    
    // Loading indicator
    _loadingIndicator = [[DACircularProgressView alloc] initWithFrame:CGRectMake(140.0f, 30.0f, 40.0f, 40.0f)];
    _loadingIndicator.userInteractionEnabled = NO;
    _loadingIndicator.thicknessRatio = 0.25;
    _loadingIndicator.roundedCorners = NO;
    _loadingIndicator.hidden = YES;
    _loadingIndicator.trackTintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    _loadingIndicator.progressTintColor = [UIColor whiteColor];
    _loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [_zoomScrollView addSubview:_loadingIndicator];

}

/// 设置显示数据源

- (void)wm_setDataPhotoModel:(WMPhotoModel *)photo{
    _photoModel = photo;
    
    [self hideImageFailure];
    // Cancel any loading on old photo
    if (_photoModel && _photoModel == nil) {
        if ([_photoModel respondsToSelector:@selector(cancelAnyLoading)]) {
            [_photoModel cancelAnyLoading];
        }
    }
}

/// 显示图片
- (void)wm_displayImageWithIsPresenting:(BOOL)isPresenting tempImage:(UIImage *)tempImage{
    
    if (isPresenting == NO){  /// 只有在转场动画结束之后才处理加载图片
        // Setup photo frame
        if (tempImage && tempImage.size.width > 0){
            CGFloat width = self.frame.size.width;
            CGFloat height = width * tempImage.size.height / tempImage.size.width;
            CGRect photoImageViewFrame = CGRectMake(0, (self.frame.size.height - height) / 2, width, height);
            self.imageShowView.frame = photoImageViewFrame;
            self.imageShowView.image = tempImage;
        }
        [self wm_displayImage];
    }
}
/// 显示图片
- (void)wm_displayImage{
    if (_photoModel.image){
        [self wm_displayImageSuccessWithImage:_photoModel.image];
    }else {
        __weak typeof(self) weakself = self;
        [_photoModel loadUnderlyingImageAndNotify:^(CGFloat progress) {
            /// 显示进度条
            [weakself showLoadingIndicator];
            weakself.loadingIndicator.progress = MAX(MIN(1, progress), 0);
        } complete:^(UIImage *image) {
            weakself.imageShowView.hidden = !image;
            /// 隐藏进度条
            [weakself hideLoadingIndicator];
            if (image){
                [weakself wm_displayImageSuccessWithImage:image];
            } else {
                [weakself wm_displayImageFailure];
            }
            [weakself setNeedsLayout];
        }];
    }
}

- (void)showLoadingIndicator {
    // Reset
    self.zoomScrollView.maximumZoomScale = 1;
    self.zoomScrollView.minimumZoomScale = 1;
    self.zoomScrollView.zoomScale = 1;
    self.zoomScrollView.contentSize = CGSizeMake(0, 0);
    _loadingIndicator.progress = 0;
    _loadingIndicator.hidden = NO;
    [self hideImageFailure];
}

- (void)hideLoadingIndicator{
    _loadingIndicator.hidden = YES;
}

- (void)hideImageFailure {
    if (_loadingError) {
        [_loadingError removeFromSuperview];
        _loadingError = nil;
    }
}

/// 加载图片成功显示
- (void)wm_displayImageSuccessWithImage:(UIImage *)image{
    self.imageShowView.image = image;
    
    // Setup photo frame
    CGRect photoImageViewFrame;
    photoImageViewFrame.origin = CGPointZero;
    photoImageViewFrame.size = image.size;
    
    self.imageShowView.frame = photoImageViewFrame;
    self.zoomScrollView.contentSize = photoImageViewFrame.size;
    
    // Set zoom to minimum zoom
    [self setMaxMinZoomScalesForCurrentBounds];
}

/// 加载图片失败显示
- (void)wm_displayImageFailure{

    self.imageShowView.image = nil;
    
    // Show if image is not empty
    if (![_photoModel respondsToSelector:@selector(emptyImage)] || !_photoModel.emptyImage) {
        if (!_loadingError) {
            _loadingError = [UIImageView new];
            _loadingError.image = [UIImage imageNamed:@"discovery"];
            _loadingError.userInteractionEnabled = NO;
            _loadingError.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
            [_loadingError sizeToFit];
            [self.zoomScrollView addSubview:_loadingError];
        }
        _loadingError.frame = CGRectMake(floorf((self.bounds.size.width - _loadingError.frame.size.width) / 2.),
                                         floorf((self.bounds.size.height - _loadingError.frame.size.height) / 2),
                                         _loadingError.frame.size.width,
                                         _loadingError.frame.size.height);
    }
}


#pragma mark - Layout

- (void)layoutSubviews {
    // Update tap view frame
    // Super
    [super layoutSubviews];
    self.tapBgView.frame = self.bounds;
    self.zoomScrollView.frame = self.bounds;
    
    
    // Position indicators (centre does not seem to work!)
    _loadingIndicator.frame = CGRectMake(floorf((self.bounds.size.width - _loadingIndicator.frame.size.width) / 2.),
                                             floorf((self.bounds.size.height - _loadingIndicator.frame.size.height) / 2),
                                             _loadingIndicator.frame.size.width,
                                             _loadingIndicator.frame.size.height);
    if (_loadingError)
        _loadingError.frame = CGRectMake(floorf((self.bounds.size.width - _loadingError.frame.size.width) / 2.),
                                         floorf((self.bounds.size.height - _loadingError.frame.size.height) / 2),
                                         _loadingError.frame.size.width,
                                         _loadingError.frame.size.height);
    
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageShowView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(self.imageShowView.frame, frameToCenter))
        self.imageShowView.frame = frameToCenter;
}

#pragma mark - Setup

- (void)setMaxMinZoomScalesForCurrentBounds {
    // Reset
    self.zoomScrollView.maximumZoomScale = 1;
    self.zoomScrollView.minimumZoomScale = 1;
    self.zoomScrollView.zoomScale = 1;
    
    // Bail
    if (self.imageShowView.image == nil) return;
    
    // Sizes
    CGSize boundsSize = self.bounds.size;
    boundsSize.width -= 0.1;
    boundsSize.height -= 0.1;
    
    CGSize imageSize = self.imageShowView.frame.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    // If image is smaller than the screen then ensure we show it at
    // min scale of 1
    if (xScale > 1 && yScale > 1) {
        //minScale = 1.0;
    }
    
    // Calculate Max
    CGFloat maxScale = 4.0; // Allow double scale
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
        
        if (maxScale < minScale) {
            maxScale = minScale * 2;
        }
    }
    
    // Calculate Max Scale Of Double Tap
    CGFloat maxDoubleTapZoomScale = 4.0 * minScale; // Allow double scale
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxDoubleTapZoomScale = maxDoubleTapZoomScale / [[UIScreen mainScreen] scale];
        
        if (maxDoubleTapZoomScale < minScale) {
            maxDoubleTapZoomScale = minScale * 2;
        }
    }
    
    // Make sure maxDoubleTapZoomScale isn't larger than maxScale
    maxDoubleTapZoomScale = MIN(maxDoubleTapZoomScale, maxScale);
    
    // Set
    self.zoomScrollView.maximumZoomScale = maxScale;
    self.zoomScrollView.minimumZoomScale = minScale;
    self.zoomScrollView.zoomScale = minScale;
    self.maximumDoubleTapZoomScale = maxDoubleTapZoomScale;
    
    // Reset position
    self.imageShowView.frame = CGRectMake(0, 0, self.imageShowView.frame.size.width, self.imageShowView.frame.size.height);
    [self setNeedsLayout];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageShowView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [_photoBrowser cancelControlHiding];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.zoomScrollView.scrollEnabled = YES; // reset
//    [_photoBrowser cancelControlHiding];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    [_photoBrowser hideControlsAfterDelay];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


#pragma mark - Tap Detection

/// 处理单击手势
- (void)handleSingleTap:(CGPoint)touchPoint {
    if ([self.delegate respondsToSelector:@selector(tapHiddenPhotoBrowserAtZoomingScrollCell:)]){
        [self.delegate tapHiddenPhotoBrowserAtZoomingScrollCell:self];
    }
}
/// 处理双击手势
- (void)handleDoubleTap:(CGPoint)touchPoint {

    // Cancel any single tap handling
    [NSObject cancelPreviousPerformRequestsWithTarget:self.imageShowView];
    
    // Zoom
    if (self.zoomScrollView.zoomScale == self.maximumDoubleTapZoomScale) {
        
        // Zoom out
        [self.zoomScrollView setZoomScale:self.zoomScrollView.minimumZoomScale animated:YES];
        
    } else {
        
        // Zoom in
        CGSize targetSize = CGSizeMake(self.frame.size.width / self.maximumDoubleTapZoomScale, self.frame.size.height / self.maximumDoubleTapZoomScale);
        CGPoint targetPoint = CGPointMake(touchPoint.x - targetSize.width / 2, touchPoint.y - targetSize.height / 2);
        
        [self.zoomScrollView zoomToRect:CGRectMake(targetPoint.x, targetPoint.y, targetSize.width, targetSize.height) animated:YES];
        
    }
}


#pragma mark -- WMTapDetectingImageViewDelegate
- (void)imageView:(UIImageView *)imageView singleTapDetected:(CGPoint)point{
    [self handleSingleTap:point];
}
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(CGPoint)point{
    [self handleDoubleTap:point];
}


@end
