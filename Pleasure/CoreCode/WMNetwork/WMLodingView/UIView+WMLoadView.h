//
//  UIView+WMLoadView.h
//  Pleasure
//
//  Created by Sper on 2017/12/15.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMGifLoadingView.h"
#import "WMLoadFailedEmptyView.h"

@interface UIView (WMLoadView)
@property (nonatomic , strong , readonly) WMGifLoadingView *gifLoadingView;
/// 默认这种是自定制动画样式
- (void)showLoading;
- (void)showLoadingType:(WMLoadingType)type;
- (void)showLoadingType:(WMLoadingType)type message:(NSString *)message;
- (void)hiddenLoading;

/// 空态样式   只有文案  文案和图片  文案图片按钮
- (void)showLoadEmpty;
- (void)showLoadEmptyMessage:(NSString *)message image:(UIImage *)image;
- (void)showLoadEmptyWithRetryBlcok:(WMRetryBlock)retryBlcok;
- (void)showLoadEmptyMessage:(NSString *)message image:(UIImage *)image buttonTitle:(NSString *)title RetryBlcok:(WMRetryBlock)retryBlcok;


/// 失败样式
- (void)showLoadFailedWithRetryBlcok:(WMRetryBlock)retryBlcok;
- (void)showLoadFailedWithType:(WMLoadFailedStyle)style RetryBlcok:(WMRetryBlock)retryBlcok;
- (void)showLoadFailedMessage:(NSString *)message image:(UIImage *)image buttonTitle:(NSString *)title style:(WMLoadFailedStyle)style RetryBlcok:(WMRetryBlock)retryBlcok;


@end
