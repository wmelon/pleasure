//
//  UIView+WMLoadView.m
//  Pleasure
//
//  Created by Sper on 2017/12/15.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "UIView+WMLoadView.h"
#import <objc/runtime.h>

@implementation UIView (WMLoadView)

#pragma mark -- 加载loading样式
- (void)showLoading{
    [self showLoadingType:(WMLoadingType_gifImage) message:nil];
}
- (void)showLoadingType:(WMLoadingType)type{
    [self showLoadingType:type message:nil];
}
- (void)showLoadingType:(WMLoadingType)type message:(NSString *)message{
    [[self loadFailedEmptyView] hidden];
    [[self gifLoadingView] showWithMessage:message type:type];
}

#pragma mark -- 空态显示样式
- (void)showLoadEmpty{
    [self showLoadEmptyMessage:@"暂时没有数据哦，亲" image:nil buttonTitle:nil RetryBlcok:nil];
}
- (void)showLoadEmptyMessage:(NSString *)message image:(UIImage *)image{
    [self showLoadEmptyMessage:message image:image buttonTitle:nil RetryBlcok:nil];
}
- (void)showLoadEmptyWithRetryBlcok:(WMRetryBlock)retryBlcok{
    [self showLoadEmptyMessage:@"暂时没有数据哦，亲" image:nil buttonTitle:@"重试" RetryBlcok:retryBlcok];
}
- (void)showLoadEmptyMessage:(NSString *)message image:(UIImage *)image buttonTitle:(NSString *)title RetryBlcok:(WMRetryBlock)retryBlcok{
    [[self gifLoadingView] hidden];
    [[self loadFailedEmptyView] showWithMessage:message image:image buttonTitle:title style:WMLoadFailedStyle_dataFailed RetryBlcok:retryBlcok];
}

#pragma mark -- 加载失败显示样式
- (void)showLoadFailedWithRetryBlcok:(WMRetryBlock)retryBlcok{
    [self showLoadFailedWithType:(WMLoadFailedStyle_dataFailed) RetryBlcok:retryBlcok];
}
- (void)showLoadFailedWithType:(WMLoadFailedStyle)style RetryBlcok:(WMRetryBlock)retryBlcok{
    [self showLoadFailedMessage:@"加载失败，请重试" image:[UIImage imageNamed:@"icon_error_unkown"] buttonTitle:@"重试" style:style RetryBlcok:retryBlcok];
}
- (void)showLoadFailedMessage:(NSString *)message image:(UIImage *)image buttonTitle:(NSString *)title style:(WMLoadFailedStyle)style RetryBlcok:(WMRetryBlock)retryBlcok{
    [[self gifLoadingView] hidden];
    [[self loadFailedEmptyView] showWithMessage:message image:image buttonTitle:title style:style RetryBlcok:retryBlcok];
}


/**
 隐藏加载视图
 */
- (void)hiddenLoading{
    [self removeLoadingView];
    [self removeLoadFaileEmptyView];
}

- (void)removeLoadingView{
    if ([self gifLoadingView].superview){
        [[self gifLoadingView] removeFromSuperview];
    }
}
- (void)removeLoadFaileEmptyView{
    if ([self loadFailedEmptyView].superview){
        [[self loadFailedEmptyView] removeFromSuperview];
    }
}

#pragma mark -- getter and setter

- (WMGifLoadingView *)gifLoadingView{
    WMGifLoadingView *gifView = objc_getAssociatedObject(self, _cmd);
    if (gifView == nil){
        CGRect frame = CGRectZero;
        if (self.superview && [self isKindOfClass:[UIButton class]]){
            frame = self.frame;
        }else {
            frame = self.bounds;
        }
        
        gifView = [[WMGifLoadingView alloc] initWithFrame:frame];
        objc_setAssociatedObject(self, _cmd, gifView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        /// 如果有父视图就添加到父视图上 没有父视图就添加到当前视图上
        if (self.superview && [self isKindOfClass:[UIButton class]]){
            [self.superview addSubview:gifView];
        }else {
            [self addSubview:gifView];
        }
    }
    /// 添加在不同视图上设置的frame是不一样的
    if (self.superview && [self isKindOfClass:[UIButton class]]){
        gifView.frame = self.frame;
    }else {
        gifView.frame = self.bounds;
    }
    return gifView;
}

- (WMLoadFailedEmptyView *)loadFailedEmptyView{
    WMLoadFailedEmptyView *failedEmptyView = objc_getAssociatedObject(self, _cmd);
    if (failedEmptyView == nil){
        CGRect frame = CGRectZero;
        if (self.superview && [self isKindOfClass:[UIButton class]]){
            frame = self.frame;
        }else {
            frame = self.bounds;
        }
        failedEmptyView = [[WMLoadFailedEmptyView alloc] initWithFrame:frame];
        objc_setAssociatedObject(self, _cmd, failedEmptyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if (self.superview && [self isKindOfClass:[UIButton class]]){
            [self.superview addSubview:failedEmptyView];
        }else {
            [self addSubview:failedEmptyView];
        }
    }
    if (self.superview && [self isKindOfClass:[UIButton class]]){
        failedEmptyView.frame = self.frame;
    }else {
        failedEmptyView.frame = self.bounds;
    }
    return failedEmptyView;
}

@end
