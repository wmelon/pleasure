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
#import "WMCaptionView.h"

@class WMZoomingScrollCell;

@protocol WMZoomingScrollCellDelegate <NSObject>

- (void)tapHiddenPhotoBrowserAtZoomingScrollCell:(WMZoomingScrollCell *)zoomingScrollCell;

@end

@interface WMZoomingScrollCell : UICollectionViewCell

@property (nonatomic ,weak) id<WMZoomingScrollCellDelegate> delegate;
/// 展示图片的视图
@property (nonatomic , strong , readonly) WMTapDetectingImageView *imageShowView;

/// 图片最大缩放比例
@property (nonatomic , assign) CGFloat maximumDoubleTapZoomScale;


/// 显示图片和描述视图
- (void)wm_setDataPhotoModel:(WMPhotoModel *)photo captionView:(WMCaptionView *)captionView;

/// 开始显示图片
- (void)wm_displayImageWithIsPresenting:(BOOL)isPresenting tempImage:(UIImage *)tempImage;

@end
