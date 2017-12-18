//
//  WMLoadFailedEmptyView.h
//  Pleasure
//
//  Created by Sper on 2017/12/18.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , WMLoadFailedStyle) {
    WMLoadFailedStyle_dataFailed, /// 加载失败显示样式 (数据加载失败样式)
    WMLoadFailedStyle_imageFailed  /// 加载失败显示样式 （图片失败样式）
};

typedef void(^WMRetryBlock)(void);
@interface WMLoadFailedEmptyView : UIView
- (void)showWithMessage:(NSString *)message image:(UIImage *)image buttonTitle:(NSString *)title style:(WMLoadFailedStyle)style RetryBlcok:(WMRetryBlock)retryBlcok;
- (void)hidden;
@end
