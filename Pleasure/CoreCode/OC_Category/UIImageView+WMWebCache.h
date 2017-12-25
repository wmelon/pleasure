//
//  UIImageView+WMWebCache.h
//  Pleasure
//
//  Created by Sper on 2017/12/22.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCWebImage.h"

@interface UIImageView (WMWebCache)
/// 传入id类型。图片显示只处理NSURL 和NSString 作为图片显示
- (void)pc_setImageWithURL:(id)url placeholderImage:(UIImage *)placeholder;

- (void)pc_setImageWithURL:(id)url placeholderImage:(UIImage *)placeholder options:(PCWebImageOptions)options progress:(PCWebImageDownloaderProgressBlock)progressBlock completed:(PCWebImageCompletionBlock)completedBlock;
@end
