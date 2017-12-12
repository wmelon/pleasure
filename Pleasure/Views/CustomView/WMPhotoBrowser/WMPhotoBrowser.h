//
//  WMPhotoBrowser.h
//  Pleasure
//
//  Created by Sper on 2017/8/10.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMPhotoModel.h"
#import "WMCaptionView.h"

@class WMPhotoBrowser;

@protocol WMPhotoBrowserDelegate <NSObject>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(WMPhotoBrowser *)photoBrowser;

- (WMPhotoModel *)photoBrowser:(WMPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;

@optional

/// 缩略图
- (WMPhotoModel *)photoBrowser:(WMPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;

/// 右边按钮点击了
- (void)photoBrowser:(WMPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index;

/// 返回上一页面在当前下标下的图片视图
- (UIImageView *)photoBrowser:(WMPhotoBrowser *)photoBrowser imageViewAtIndex:(NSInteger)index;

/// 当前显示第几张图片
- (NSInteger)currentIndexAtPhotoBrowser:(WMPhotoBrowser *)photoBrowser;

@end

@interface WMPhotoBrowser : UIViewController <UIScrollViewDelegate>

@property (nonatomic , weak) id<WMPhotoBrowserDelegate> delegate;

@property (nonatomic, readonly) NSUInteger currentIndex;

/// 默认是可以显示的
@property (nonatomic , assign) BOOL shouldShowRightItem;
/// 是否显示头部工具栏 默认是不显示的
@property (nonatomic , assign) BOOL shouldShowTopToolBar;

// Init
- (instancetype)initWithPhotos:(NSArray<WMPhotoModel *> *)photosArray;

- (instancetype)initWithDelegate:(id <WMPhotoBrowserDelegate>)delegate;

- (void)reloadData;

// Set page that photo browser starts on
//- (void)setCurrentPhotoIndex:(NSUInteger)index;

/// 显示导航栏右边的按钮
- (UIButton *)showRightItem:(NSString *)title image:(UIImage *)image;

@end
