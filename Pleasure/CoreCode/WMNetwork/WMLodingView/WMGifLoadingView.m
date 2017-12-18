//
//  WMGifLoadingView.m
//  Pleasure
//
//  Created by Sper on 2017/12/18.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMGifLoadingView.h"
#import "JQIndicatorView.h"

@interface WMGifLoadingView()
/// 系统loading小菊花
@property (nonatomic , strong) UIActivityIndicatorView *indicatorView;
/// 显示加载文案
@property (nonatomic , strong) UILabel *stateLabel;
/// 加载样式
@property (nonatomic , assign) WMLoadingType loadingType;
/// 自定制加载动效
@property (nonatomic , strong) JQIndicatorView *jqIndicatorView;
@end

@implementation WMGifLoadingView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor whiteColor];
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.backgroundColor = [UIColor whiteColor];
        [_indicatorView startAnimating];
        [self addSubview:_indicatorView];
        
        _jqIndicatorView = [[JQIndicatorView alloc] initWithType:(JQIndicatorTypeBounceSpot1)];
        [self addSubview:_jqIndicatorView];
        
        _stateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.font = [UIFont systemFontOfSize:12.0f];
        _stateLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:_stateLabel];
    }
    return self;
}
- (void)showWithMessage:(NSString *)message type:(WMLoadingType)type{
    self.hidden = NO;
    _loadingType = type;
    
    _stateLabel.hidden = !message;
    _stateLabel.text = message;
    
    if (_loadingType == WMLoadingType_gifImage){
        [self showGifImageView];
    }else {
        [self showIndicatorView];
    }
}
- (void)showGifImageView{
    _jqIndicatorView.hidden = NO;
    _indicatorView.hidden = YES;
    [_jqIndicatorView startAnimating];
}
- (void)showIndicatorView{
    _jqIndicatorView.hidden = YES;
    _stateLabel.hidden = YES;
    _indicatorView.hidden = NO;
}
- (void)hidden{
    self.hidden = YES;
    [_jqIndicatorView stopAnimating];
    [_indicatorView stopAnimating];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    if (_loadingType == WMLoadingType_gifImage){
        _jqIndicatorView.center = self.center;
        _stateLabel.frame = CGRectMake(20, CGRectGetMaxY(_jqIndicatorView.frame) + 10, self.frame.size.width - 40, 20);
    }else {
        _indicatorView.frame = self.bounds;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
