//
//  WMPhotoModel.h
//  Pleasure
//
//  Created by Sper on 2017/8/10.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 加载图片成功回调
typedef void(^WMLoadImageCompleteHandle) (UIImage *image);

/// 加载图片进度
typedef void(^WMLoadImageProgressHandle) (CGFloat progress);


@interface WMPhotoModel : NSObject

@property (nonatomic) BOOL emptyImage;

+ (WMPhotoModel *)photoWithImage:(UIImage *)image;
+ (WMPhotoModel *)photoWithURL:(NSURL *)url;

/// 加载图片
- (void)loadUnderlyingImageAndNotify:(WMLoadImageProgressHandle)progress complete:(WMLoadImageCompleteHandle)complete;

/// 清除正在加载
- (void)cancelAnyLoading;

@end
