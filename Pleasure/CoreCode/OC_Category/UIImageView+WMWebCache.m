//
//  UIImageView+WMWebCache.m
//  Pleasure
//
//  Created by Sper on 2017/12/22.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "UIImageView+WMWebCache.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (WMWebCache)
- (void)pc_setImageWithURL:(id)url placeholderImage:(UIImage *)placeholder{
    NSURL *imageUrl = [[SwitchAppRequestUrl shareInstance] imageUrlWithId:url];
    SDWebImageOptions options = SDWebImageRetryFailed | SDWebImageLowPriority;
    [self sd_setImageWithURL:imageUrl placeholderImage:placeholder options:options];
}

- (void)pc_setImageWithURL:(id)url placeholderImage:(UIImage *)placeholder options:(PCWebImageOptions)options progress:(PCWebImageDownloaderProgressBlock)progressBlock completed:(PCWebImageCompletionBlock)completedBlock{
    
    NSURL *imageUrl = [[SwitchAppRequestUrl shareInstance] imageUrlWithId:url];
    
    [self sd_setImageWithURL:imageUrl placeholderImage:placeholder options:(SDWebImageOptions)options progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (progressBlock){
            progressBlock(receivedSize,expectedSize);
        }
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock){
            completedBlock(image , error , (PCImageCacheType)cacheType , imageURL);
        }
    }];
}
@end
