//
//  WMZoomingScrollCell.m
//  Pleasure
//
//  Created by Sper on 2017/8/10.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMZoomingScrollCell.h"
#import "WMTapDetectingImageView.h"
#import <DACircularProgressView.h>

@interface WMZoomingScrollCell() <UIScrollViewDelegate , WMTapDetectingImageViewDelegate>

/// 展示图片的视图
@property (nonatomic , strong) WMTapDetectingImageView *imageShowView;

/// 接收手势的视图
@property (nonatomic , strong) WMTapDetectingBgView *tapBgView;

/// 图片加载进度条
@property (nonatomic , strong) DACircularProgressView *loadingIndicator;

/// 加载失败显示图片
@property (nonatomic , strong) UIImageView *loadingError;

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
    [self.zoomScrollView addSubview:tapBgView];
    self.tapBgView = tapBgView;
    
    
    WMTapDetectingImageView *imageView = [[WMTapDetectingImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.tapDelegate = self;
    [scrollView addSubview:imageView];
    self.imageShowView = imageView;
    
    
    
    // Loading indicator
    _loadingIndicator = [[DACircularProgressView alloc] initWithFrame:CGRectMake(140.0f, 30.0f, 40.0f, 40.0f)];
    _loadingIndicator.userInteractionEnabled = NO;
    _loadingIndicator.thicknessRatio = 0.1;
    _loadingIndicator.roundedCorners = NO;
    _loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.zoomScrollView addSubview:_loadingIndicator];
    
}

- (void)setPhotoModel:(WMPhotoModel *)photoModel{
    
    [self hideImageFailure];
    // Cancel any loading on old photo
    if (_photoModel && _photoModel == nil) {
        if ([_photoModel respondsToSelector:@selector(cancelAnyLoading)]) {
            [_photoModel cancelAnyLoading];
        }
    }
     _photoModel = photoModel;
    
    
    [self wm_displayImage];
}

/// 显示图片
- (void)wm_displayImage{
    [_photoModel loadUnderlyingImageAndNotify:^(CGFloat progress) {
        
        /// 显示进度条
        [self showLoadingIndicator];
        _loadingIndicator.progress = MAX(MIN(1, progress), 0);

    } complete:^(UIImage *image) {
        
        self.imageShowView.hidden = !image;
        /// 隐藏进度条
        [self hideLoadingIndicator];
        
        if (image){
            
            [self wm_displayImageSuccessWithImage:image];
            
        } else {
            
            [self wm_displayImageFailure];
        }
        [self setNeedsLayout];

    }];
    
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
    self.tapBgView.frame = self.bounds;
    self.zoomScrollView.frame = self.bounds;
    
    
    // Position indicators (centre does not seem to work!)
    if (!_loadingIndicator.hidden)
        _loadingIndicator.frame = CGRectMake(floorf((self.bounds.size.width - _loadingIndicator.frame.size.width) / 2.),
                                             floorf((self.bounds.size.height - _loadingIndicator.frame.size.height) / 2),
                                             _loadingIndicator.frame.size.width,
                                             _loadingIndicator.frame.size.height);
    if (_loadingError)
        _loadingError.frame = CGRectMake(floorf((self.bounds.size.width - _loadingError.frame.size.width) / 2.),
                                         floorf((self.bounds.size.height - _loadingError.frame.size.height) / 2),
                                         _loadingError.frame.size.width,
                                         _loadingError.frame.size.height);
    
    // Super
    [super layoutSubviews];
    
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

- (void)handleSingleTap:(CGPoint)touchPoint {
//    //	[_photoBrowser performSelector:@selector(toggleControls) withObject:nil afterDelay:0.2];
//    [self.imageShowView performSelector:@selector(handleSingleTap) withObject:nil afterDelay:0.2];
}
//
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
    
    // Delay controls
//    [self.imageShowView hideControlsAfterDelay];
}


#pragma mark -- WMTapDetectingImageViewDelegate

// Image View
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch {
    
    CGPoint point = [touch locationInView:imageView];
    [self handleSingleTap:point];
}
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {
    CGPoint point = [touch locationInView:imageView];
    [self handleDoubleTap:point];
}


@end
