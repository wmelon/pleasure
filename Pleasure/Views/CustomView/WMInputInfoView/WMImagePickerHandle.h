//
//  WMImagePickerHandle.h
//  Pleasure
//
//  Created by Sper on 2017/8/9.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMPhoto.h"

/// 选择图片和拍照之后回调
typedef void(^WMImageResultHandle) (NSArray *images);

/// 删除图片的回调
typedef void(^WMPhotoDeleteHandle) (NSInteger deleteIndex);

@interface WMImagePickerHandle : NSObject

- (instancetype)initWithController:(UIViewController *)viewController;

/// 打开相机拍照
- (void)openCameraWithImageResultHandle:(WMImageResultHandle)imageResultHandle;

/// 打开相册选择图片
- (void)openPhotoAlbumWithMaxImagesCount:(NSInteger)maxImagesCount imageResultHandle:(WMImageResultHandle)imageResultHandle;

/// 浏览图片
- (void)photoBrowserWithCurrentIndex:(NSInteger)currentIndex photosArray:(NSArray<WMPhoto *> *)photos deleteHandle:(WMPhotoDeleteHandle)deleteHandle;

@end
