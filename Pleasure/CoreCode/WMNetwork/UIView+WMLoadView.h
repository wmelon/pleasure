//
//  UIView+WMLoadView.h
//  Pleasure
//
//  Created by Sper on 2017/12/15.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , WMLoadingType) {
    WMLoadingType_gifImage,  /// 自定制图片动画
    WMLoadStatus_indicator /// 系统小菊花
};

@class WMGifLoadingView;
typedef void(^WMRetryBlock)(void);

@interface UIView (WMLoadView)
@property (nonatomic , strong , readonly) WMGifLoadingView *gifLoadingView;
- (void)showLoadingType:(WMLoadingType)type;
- (void)showLoadFailedWithRetryBlcok:(WMRetryBlock)retryBlcok;
- (void)showLoadEmptyWithRetryBlcok:(WMRetryBlock)retryBlcok;


- (void)showLoadEmpty;
- (void)hiddenLoading;
@end
