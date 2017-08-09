//
//  WMImagePickerHandle.h
//  Pleasure
//
//  Created by Sper on 2017/8/9.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^WMImageResultHandle) (NSArray *images);

@interface WMImagePickerHandle : NSObject

- (instancetype)initWithController:(UIViewController *)viewController;

/// 打开相机拍照
- (void)openCameraWithImageResultHandle:(WMImageResultHandle)imageResultHandle;

/// 打开相册选择图片
- (void)openPhotoAlbumWithMaxImagesCount:(NSInteger)maxImagesCount imageResultHandle:(WMImageResultHandle)imageResultHandle;

@end
