//
//  WMInputInfoView.h
//  Pleasure
//
//  Created by Sper on 2017/8/8.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>


@class WMInputInfoView;


@protocol WMInputInfoViewDelegate <NSObject>

@optional

/// 最多显示图片数 默认是 3张
- (NSInteger)maxPhotoCountAtInputInfoView:(WMInputInfoView *)inputInfoView;

/// 每一行显示图片个数 默认是 3张
- (NSInteger)eachRowShowPhotoCountAtInputInfoView:(WMInputInfoView *)inputInfoView;

/// 已经选择的图片数 默认是 0张 (用于编辑图片的)
- (NSInteger)selectedPhotoCountAtInputInfoView:(WMInputInfoView *)inputInfoView;

/// 已经选择图片网络地址
- (NSString *)inputInfoView:(WMInputInfoView *)inputInfoView selectedPhotoUrlAtIndex:(NSInteger)index;

/// 已经选择图片对象
- (UIImage *)inputInfoView:(WMInputInfoView *)inputInfoView selectedPhotoAtIndex:(NSInteger)index;

/// 添加图片图标
- (UIImage *)addIconAtAtInputInfoView:(WMInputInfoView *)inputInfoView;

/// 当前视图的高度
- (void)inputInfoViewHeight:(CGFloat)height;

/// 是否允许拖动显示图片位置  默认是不允许的
- (BOOL)allowDragItemAtInputInfoView:(WMInputInfoView *)inputInfoView;

@end

/// 上传图片回调
typedef void(^WMUploadImageHandle)(NSArray *imageIds);

@interface WMInputInfoView : UIView

@property (nonatomic , weak) id<WMInputInfoViewDelegate> delegate;

/// 上传选中的图片
- (void)uploadSelectedImage:(WMUploadImageHandle)handle;

/// 刷新数据
- (void)reloadView;


@end
