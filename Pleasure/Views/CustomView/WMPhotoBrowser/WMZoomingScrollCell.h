//
//  WMZoomingScrollCell.h
//  Pleasure
//
//  Created by Sper on 2017/8/10.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMPhotoModel.h"
#import "WMTapDetectingImageView.h"

@class WMZoomingScrollCell;

@protocol WMZoomingScrollCellDelegate <NSObject>

- (void)tapHiddenPhotoBrowserAtZoomingScrollCell:(WMZoomingScrollCell *)zoomingScrollCell;

@end

@interface WMZoomingScrollCell : UICollectionViewCell
@property (nonatomic ,weak) id<WMZoomingScrollCellDelegate> delegate;
/// 展示图片的视图
@property (nonatomic , strong , readonly) WMTapDetectingImageView *imageShowView;
/// 缩放的视图
@property (nonatomic , strong , readonly) UIScrollView *zoomScrollView;

@property (nonatomic , strong) WMPhotoModel *photoModel;

@property (nonatomic) CGFloat maximumDoubleTapZoomScale;

/// 开始显示图片
- (void)wm_displayImageWithIsPresenting:(BOOL)isPresenting tempImage:(UIImage *)tempImage;

@end
