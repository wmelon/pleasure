//
//  WMLoadFailedEmptyView.m
//  Pleasure
//
//  Created by Sper on 2017/12/18.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMLoadFailedEmptyView.h"
/// 图片为整个宽度的 1 / 4
#define kWMImageWithScale  0.25

@interface WMLoadFailedEmptyView()
@property (nonatomic , strong) UIImageView *failImageView;
@property (nonatomic , strong) UILabel * stateLabel;
@property (nonatomic , strong) UIButton * btnRetry;
@property (nonatomic , copy  ) WMRetryBlock retryBlcok;
@property (nonatomic , assign) WMLoadFailedStyle failedStyle;
@end

@implementation WMLoadFailedEmptyView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor whiteColor];
        
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
        [self.btnRetry addTarget:self action:@selector(btnRetry:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnRetry];
    }
    return self;
}
- (void)showWithMessage:(NSString *)message image:(UIImage *)image buttonTitle:(NSString *)title style:(WMLoadFailedStyle)style RetryBlcok:(WMRetryBlock)retryBlcok{
    _retryBlcok = retryBlcok;
    _failedStyle = style;
    self.hidden = NO;
    
    if (style == WMLoadFailedStyle_imageFailed){
        self.stateLabel.hidden = YES;
        self.failImageView.hidden = YES;
        self.btnRetry.hidden = NO;
        [self imageFailedButtonStyle];
    }else {
        [self dataFailedButtonStyle];
        self.stateLabel.hidden = !message;
        self.failImageView.hidden = !image;
        self.btnRetry.hidden = !title;
        self.stateLabel.text = message;
        self.failImageView.image = image;
        [self.btnRetry setTitle:title forState:UIControlStateNormal];
    }
    [self layoutSubviews];
}
- (void)dataFailedButtonStyle{
    self.btnRetry.layer.cornerRadius = 2.0f;
    self.btnRetry.clipsToBounds = YES;
    self.btnRetry.layer.borderWidth = .5f;
    self.btnRetry.layer.borderColor = [UIColor lightGrayColor].CGColor;
}
- (void)imageFailedButtonStyle{
    self.btnRetry.titleLabel.numberOfLines = 0;
    [self.btnRetry setTitle:@"获取失败\n点击重试" forState:UIControlStateNormal];
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
    
    if (_failedStyle == WMLoadFailedStyle_imageFailed){
        self.btnRetry.frame = self.bounds;
    }else {
        CGFloat padding = 10;
        CGFloat btnHeight = 30;
        CGFloat btnWidth = 100;
        if (self.failImageView.image){
            CGFloat imageWidth = kWMImageWithScale * self.frame.size.width;
            CGFloat imageHeight = imageWidth * self.failImageView.image.size.height / self.failImageView.image.size.width;
            self.failImageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
        }
        self.failImageView.center = self.center;
        _stateLabel.frame = CGRectMake(20, CGRectGetMaxY(self.failImageView.frame) + padding, self.frame.size.width - 40, 20);
        self.btnRetry.frame = CGRectMake((self.frame.size.width - btnWidth) / 2, CGRectGetMaxY(_stateLabel.frame) + padding, btnWidth, btnHeight);
    }
}

- (CGSize)getSizeOfContent:(NSString *)str width:(CGFloat)width font:(CGFloat)font{
    CGSize size =CGSizeMake(width,CGFLOAT_MAX);
    UIFont *tfont = [UIFont systemFontOfSize:font];
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    CGSize  actualsize = CGSizeMake(0, 0);
    actualsize =[str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    //强制转化为整型(比初值偏小)，因为float型size转到view上会有一定的偏移，导致view setBounds时候 错位
    CGSize contentSize =CGSizeMake(ceil(actualsize.width), ceil(actualsize.height));
    return contentSize;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
