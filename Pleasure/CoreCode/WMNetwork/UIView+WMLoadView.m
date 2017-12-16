//
//  UIView+WMLoadView.m
//  Pleasure
//
//  Created by Sper on 2017/12/15.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "UIView+WMLoadView.h"
#import <objc/runtime.h>

/// 图片为整个宽度的 1 / 4
#define kWMImageWithScale  0.25

typedef NS_ENUM(NSInteger , WMLoadStatus) {
    WMLoadStatus_failed,  /// 加载失败
    WMLoadStatus_empty  /// 加载成功但是没有数据
};

@interface WMGifLoadingView : UIView
/// 系统loading小菊花
@property (nonatomic , strong , readonly) UIActivityIndicatorView *indicatorView;
/// 自定制加载动效
@property (nonatomic , strong , readonly) UIImageView *gifImageView;
/// 显示加载文案
@property (nonatomic , strong , readonly) UILabel *stateLabel;
/// 存储loading图片数组
@property (nonatomic , strong) NSMutableArray *loadingImages;
/// 加载样式
@property (nonatomic , assign) WMLoadingType loadingType;
@end

@implementation WMGifLoadingView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.backgroundColor = [UIColor whiteColor];
        [_indicatorView startAnimating];
        _indicatorView.userInteractionEnabled = NO;
        [self addSubview:_indicatorView];
        
        _gifImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _gifImageView.highlighted = NO;
        [self addSubview:_gifImageView];
        
        _stateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.font = [UIFont systemFontOfSize:12.0f];
        _stateLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:_stateLabel];
        
        self.loadingImages = [NSMutableArray array];
        for (int i = 1 ; i < 9  ; i++){
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_hud_%zd", i]];
            if (image){
                [self.loadingImages addObject:image];
            }
        }
    }
    return self;
}
- (void)showWithMessage:(NSString *)message type:(WMLoadingType)type{
    self.hidden = NO;
    _stateLabel.text = message;
    _loadingType = type;
    
    if (_loadingType == WMLoadingType_gifImage){
        [self showGifImageView];
    }else {
        [self showIndicatorView];
    }
}
- (void)showGifImageView{
    NSArray *images = self.loadingImages;
    if (images.count == 0) return;
    [_gifImageView stopAnimating];
    if (images.count == 1) { // 单张图片
        _gifImageView.image = [images lastObject];
    } else { // 多张图片
        _gifImageView.animationImages = images;
        _gifImageView.animationDuration = images.count * 0.1;
        [_gifImageView startAnimating];
    }
}
- (void)showIndicatorView{
    _indicatorView.frame = self.bounds;
    _gifImageView.hidden = YES;
    _stateLabel.hidden = YES;
    _indicatorView.hidden = NO;
}
- (void)hidden{
    self.hidden = YES;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    if (_loadingType == WMLoadingType_gifImage && self.loadingImages.count){

        UIImage *image = [self.loadingImages firstObject];
        if (image){
            CGFloat imageWidth = kWMImageWithScale * self.frame.size.width;
            CGFloat imageHeight = imageWidth * image.size.height / image.size.width;
            CGFloat stateLabelHeight = 20;
            CGFloat padding = 10;
            
            _gifImageView.hidden = NO;
            _stateLabel.hidden = NO;
            _indicatorView.hidden = YES;
            _gifImageView.frame = CGRectMake((self.frame.size.width - imageWidth) / 2, (self.frame.size.height - imageHeight - stateLabelHeight - padding) / 2, imageWidth, imageHeight);
            _stateLabel.frame = CGRectMake(20, CGRectGetMaxY(_gifImageView.frame) + padding, self.frame.size.width - 40, stateLabelHeight);
        }
    }else {
        [self showIndicatorView];
    }
}

@end


@interface WMLoadFailedEmptyView : UIView
@property (nonatomic , assign) WMLoadStatus loadStatus;
@property (nonatomic , strong) UIImageView *failImageView;
@property (nonatomic , strong) UILabel * stateLabel;
@property (nonatomic , strong) UIButton * btnRetry;
@property (nonatomic , copy  ) WMRetryBlock retryBlcok;
@property (nonatomic , assign) WMLoadingType loadingType;
@end

@implementation WMLoadFailedEmptyView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.failImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.failImageView];
        
        _stateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.font = [UIFont systemFontOfSize:12.0f];
        _stateLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:_stateLabel];
        
        self.btnRetry = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnRetry setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.btnRetry.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        self.btnRetry.backgroundColor = [UIColor whiteColor];
        self.btnRetry.layer.cornerRadius = 2.0f;
        self.btnRetry.clipsToBounds = YES;
        [self.btnRetry addTarget:self action:@selector(btnRetry:) forControlEvents:UIControlEventTouchUpInside];
        self.btnRetry.layer.borderWidth = .5f;
        self.btnRetry.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [self addSubview:self.btnRetry];
    }
    return self;
}
- (void)showWithLoadStatus:(WMLoadStatus)loadStatus RetryBlcok:(WMRetryBlock)retryBlcok type:(WMLoadingType)type{
    _retryBlcok = retryBlcok;
    _loadStatus = loadStatus;
    _loadingType = type;
    self.hidden = NO;
    
    if (_loadStatus == WMLoadStatus_failed){
        [self showFailedView];
    }else if (_loadStatus == WMLoadStatus_empty){
        [self showEmptyView];
    }
}

- (void)showFailedView{
    if (_loadingType == WMLoadingType_gifImage){
        _stateLabel.text = @"加载数据失败,请重试~";
        [self.btnRetry setTitle:@"重试" forState:UIControlStateNormal];
        self.failImageView.image = [UIImage imageNamed:@"icon_error_unkown"];
    }else {
        _stateLabel.text = @"加载数据失败,请重试~";
        [self.btnRetry setTitle:@"重试" forState:UIControlStateNormal];
    }
    [self layoutSubviews];
}
- (void)showEmptyView{
    _stateLabel.text = @"亲没有数据了,请重试~";
    [self.btnRetry setTitle:@"重试" forState:UIControlStateNormal];
    
    [self layoutSubviews];
}

- (void)btnRetry:(UIButton *)button{
    if (_retryBlcok){
        _retryBlcok();
    }
}
- (void)hidden{
    self.hidden = YES;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat stateLabelHeight = 20;
    CGFloat padding = 10;
    CGFloat btnHeight = 30;
    CGFloat btnWidth = 100;
    
    if (_loadingType == WMLoadingType_gifImage){
        
    }else {
        
    }
    
    if (self.failImageView.image){
        CGFloat imageWidth = kWMImageWithScale * self.frame.size.width;
        CGFloat imageHeight = imageWidth * self.failImageView.image.size.height / self.failImageView.image.size.width;
        
        CGFloat selfWidth = self.frame.size.width;
        CGFloat selfHeight = self.frame.size.height;
        
        if (selfHeight < (imageHeight + stateLabelHeight + 2 *padding +btnHeight) || selfWidth < imageWidth){
            self.failImageView.frame = CGRectZero;
        }else {
            self.failImageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
        }
    }
    self.failImageView.center = self.center;
    _stateLabel.frame = CGRectMake(20, CGRectGetMaxY(self.failImageView.frame) + padding, self.frame.size.width - 40, stateLabelHeight);
    self.btnRetry.frame = CGRectMake((self.frame.size.width - btnWidth) / 2, CGRectGetMaxY(_stateLabel.frame) + padding, btnWidth, btnHeight);
}

@end


@implementation UIView (WMLoadView)
/**
 显示加载动画
 */
- (void)showLoadingType:(WMLoadingType)type{
    [self setLoadingType:type];
    [[self loadFailedEmptyView] hidden];
    
    [[self gifLoadingView] showWithMessage:@"努力加载中..." type:type];
}

/**
 显示加载失败视图

 @param retryBlcok 失败视图按钮点击回调
 */
- (void)showLoadFailedWithRetryBlcok:(WMRetryBlock)retryBlcok{
    [[self gifLoadingView] hidden];
    
    [[self loadFailedEmptyView] showWithLoadStatus:(WMLoadStatus_failed) RetryBlcok:retryBlcok type:[self loadingType]];
}

/**
 显示加载没有数据视图

 @param retryBlcok 空数据页面按钮点击回调
 */
- (void)showLoadEmptyWithRetryBlcok:(WMRetryBlock)retryBlcok{
    [[self gifLoadingView] hidden];
    
    [[self loadFailedEmptyView] showWithLoadStatus:(WMLoadStatus_empty) RetryBlcok:retryBlcok type:[self loadingType]];
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
- (void)setLoadingType:(WMLoadingType)loadingType{
    objc_setAssociatedObject(self, @selector(loadingType), @(loadingType) , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (WMLoadingType)loadingType{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (WMGifLoadingView *)gifLoadingView{
    WMGifLoadingView *gifView = objc_getAssociatedObject(self, _cmd);
    if (gifView == nil){
        gifView = [[WMGifLoadingView alloc] initWithFrame:CGRectZero];
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
        failedEmptyView = [[WMLoadFailedEmptyView alloc] initWithFrame:CGRectZero];
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
