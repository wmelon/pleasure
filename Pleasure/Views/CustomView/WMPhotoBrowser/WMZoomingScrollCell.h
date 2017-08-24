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

@interface WMZoomingScrollCell : UICollectionViewCell

/// 展示图片的视图
@property (nonatomic , strong , readonly) WMTapDetectingImageView *imageShowView;
/// 缩放的视图
@property (nonatomic , strong , readonly) UIScrollView *zoomScrollView;

@property (nonatomic , strong) WMPhotoModel *photoModel;

@property (nonatomic) CGFloat maximumDoubleTapZoomScale;

@end
