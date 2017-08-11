//
//  WMZoomingScrollCell.h
//  Pleasure
//
//  Created by Sper on 2017/8/10.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMPhotoModel.h"

@interface WMZoomingScrollCell : UICollectionViewCell

/// 缩放的视图
@property (nonatomic , strong , readonly) UIScrollView *zoomScrollView;

@property (nonatomic , strong) WMPhotoModel *photoModel;

@property (nonatomic) CGFloat maximumDoubleTapZoomScale;

@end
