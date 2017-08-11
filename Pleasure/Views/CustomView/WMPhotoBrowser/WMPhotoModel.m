//
//  WMPhotoModel.m
//  Pleasure
//
//  Created by Sper on 2017/8/10.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMPhotoModel.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <SDWebImage/SDWebImageDecoder.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDWebImageOperation.h>

@interface WMPhotoModel(){
    BOOL _loadingInProgress;
    id <SDWebImageOperation> _webImageOperation;
}

/// 加载成功存储图片
@property (nonatomic, strong) UIImage *image;

/// 图片地址
@property (nonatomic, strong) NSURL *photoURL;


/// 图片加载进度
@property (nonatomic, assign) CGFloat progress;

/// 加载图片成功之后回调
@property (nonatomic , copy) WMLoadImageCompleteHandle complete;

@property (nonatomic , copy) WMLoadImageProgressHandle progressHandle;

@end

@implementation WMPhotoModel

+ (WMPhotoModel *)photoWithImage:(UIImage *)image{
    return [[WMPhotoModel alloc] initWithImage:image];
}

+ (WMPhotoModel *)photoWithURL:(NSURL *)url{

    return [[WMPhotoModel alloc] initWithURL:url];
}


#pragma mark - Init

- (id)initWithImage:(UIImage *)image {
    if ((self = [super init])) {
        self.emptyImage = YES;
        self.image = image;
    }
    return self;
}

- (id)initWithURL:(NSURL *)url {
    if ((self = [super init])) {
        self.emptyImage = YES;
        self.photoURL = url;
    }
    return self;
}

- (void)loadUnderlyingImageAndNotify:(WMLoadImageProgressHandle)progress complete:(WMLoadImageCompleteHandle)complete{
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    if (_loadingInProgress) return;
    _loadingInProgress = YES;
    _complete = complete;
    _progressHandle = progress;
    
    
    // Get underlying image
    if (_image) {
        
        // We have UIImage!
        [self imageLoadingComplete];
        
    } else if (_photoURL) {
        
        // Check what type of url it is
        if ([[[_photoURL scheme] lowercaseString] isEqualToString:@"assets-library"]) {
            
            // Load from assets library
            [self _performLoadUnderlyingImageAndNotifyWithAssetsLibraryURL: _photoURL];
            
        } else if ([_photoURL isFileReferenceURL]) {
            
            // Load from local file async
            [self _performLoadUnderlyingImageAndNotifyWithLocalFileURL: _photoURL];
            
        } else {
            
            // Load async from web (using SDWebImage)
            [self _performLoadUnderlyingImageAndNotifyWithWebURL: _photoURL];
            
        }
        
    }  else {
        
        // Image is empty
        [self imageLoadingComplete];
        
    }

}


#pragma mark -- Load from asset library async

- (void)_performLoadUnderlyingImageAndNotifyWithAssetsLibraryURL:(NSURL *)url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            @try {
                ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
                [assetslibrary assetForURL:url
                               resultBlock:^(ALAsset *asset){
                                   ALAssetRepresentation *rep = [asset defaultRepresentation];
                                   CGImageRef iref = [rep fullScreenImage];
                                   if (iref) {
                                       self.image = [UIImage imageWithCGImage:iref];
                                   }
                                   [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                               }
                              failureBlock:^(NSError *error) {
                                  self.image = nil;
                                  NSLog(@"Photo from asset library error: %@",error);
                                  [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                              }];
            } @catch (NSException *e) {
                NSLog(@"Photo from asset library error: %@", e);
                [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
            }
        }
    });
}

#pragma mark -- 从本地文件中加载图片
- (void)_performLoadUnderlyingImageAndNotifyWithLocalFileURL:(NSURL *)url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            @try {
                self.image = [UIImage imageWithContentsOfFile:url.path];
                if (!_image) {
                    NSLog(@"Error loading photo from path: %@", url.path);
                }
            } @finally {
                [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
            }
        }
    });
}

#pragma mark -- 从网站加载图片
- (void)_performLoadUnderlyingImageAndNotifyWithWebURL:(NSURL *)url {
    @try {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        _webImageOperation = [manager downloadImageWithURL:url
                                                   options:0
                                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                      if (expectedSize > 0) {
                                                          float progress = receivedSize / (float)expectedSize;
                                                          self.image = nil;
                                                          self.progress = progress;
                                                          
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [self imageLoadingProgress];
                                                          });
                                                      }
                                                  }
                                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                     if (error) {
                                                         NSLog(@"SDWebImage failed to download image: %@", error);
                                                     }
                                                     _webImageOperation = nil;
                                                     self.image = image;
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [self imageLoadingComplete];
                                                     });
                                                 }];
    } @catch (NSException *e) {
        NSLog(@"Photo from web: %@", e);
        _webImageOperation = nil;
        [self imageLoadingComplete];
    }
}

/// 加载中显示进度
- (void)imageLoadingProgress{
     NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    _loadingInProgress = YES;
    
    if (_progressHandle){
        _progressHandle(self.progress);
    }
}

/// 加载完成显示图片
- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    _loadingInProgress = NO;
    
    if (_complete){
        _complete(self.image);
    }
}

- (void)dealloc {
    [self cancelAnyLoading];
}

/// 停止所有请求
- (void)cancelAnyLoading {
    if (_webImageOperation != nil) {
        [_webImageOperation cancel];
        _loadingInProgress = NO;
    }
}

@end
