//
//  WMDownloadButton.m
//  Pleasure
//
//  Created by Sper on 2017/8/15.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMDownloadButton.h"
#import <POP.h>

@interface WMDownloadButton()<CAAnimationDelegate>
/// 背景圆
@property (nonatomic , strong) CAShapeLayer *bgCircleShapeLayer;
/// 竖线
@property (nonatomic , strong) CAShapeLayer *verLineShapeLayer;
/// 箭头
@property (nonatomic , strong) CAShapeLayer *arrowShapeLayer;
/// 进度
@property (nonatomic , strong) CAShapeLayer *progressShapeLayer;
/// 文件下载大小显示
@property (nonatomic , strong) UILabel *progressLabel;
@end

@implementation WMDownloadButton

- (instancetype)init{
    if (self = [super init]){
        [self wm_configUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        [self wm_configUI];
    }
    return self;
}

- (void)wm_configUI{
    
    self.progressLabel = [[UILabel alloc] init];
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.progressLabel.textColor = [UIColor redColor];
    self.progressLabel.font = [UIFont systemFontOfSize:13];
    self.progressLabel.alpha = 0.0;
    [self addSubview:self.progressLabel];

    
    self.bgCircleShapeLayer = [CAShapeLayer layer];
    self.bgCircleShapeLayer.lineWidth = 6.0;
    self.bgCircleShapeLayer.strokeColor = [self flatWhiteColorDark].CGColor;
    self.bgCircleShapeLayer.fillColor = [self flatSkyBlueColor].CGColor;
    self.bgCircleShapeLayer.opacity = 0.2;  /// 不透明度
    [self.layer addSublayer:self.bgCircleShapeLayer];
    
    
    self.verLineShapeLayer = [CAShapeLayer layer];
    self.verLineShapeLayer.lineWidth = 4.0;
    self.verLineShapeLayer.lineCap = kCALineCapRound;
    self.verLineShapeLayer.strokeColor = [self flatWhiteColorDark].CGColor;
    [self.layer addSublayer:self.verLineShapeLayer];
    
    
    self.arrowShapeLayer = [CAShapeLayer layer];
    self.arrowShapeLayer.lineWidth = 3.0;
    self.arrowShapeLayer.lineCap = kCALineCapRound;
    self.arrowShapeLayer.strokeColor = [self flatWhiteColorDark].CGColor;
    self.arrowShapeLayer.fillColor      = [UIColor clearColor].CGColor;
    [self.layer addSublayer:self.arrowShapeLayer];
    
    
    self.progressShapeLayer = [CAShapeLayer layer];
    self.progressShapeLayer.strokeStart = 1;
    self.progressShapeLayer.lineWidth = 6.0;
    self.progressShapeLayer.lineCap = kCALineCapRound;
    self.progressShapeLayer.strokeColor = [self flatWhiteColorDark].CGColor;
    self.progressShapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:tap];
}

- (UIColor *)flatWhiteColorDark{
    return [UIColor colorWithRed:204 / 255.0 green:5 / 255.0 blue:78 / 255.0 alpha:1.0];
}
- (UIColor *)flatSkyBlueColor {
    return [UIColor colorWithRed:204 / 255.0 green:76 / 255.0 blue:86 / 255.0 alpha:1.0];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-self.frame.size.height *.25);
    }];
    
    UIBezierPath *bgCiclePath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    self.bgCircleShapeLayer.path = bgCiclePath.CGPath;
    
    
    UIBezierPath *verLinePath = [UIBezierPath bezierPath];
    [verLinePath moveToPoint:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) * 0.25)];
    [verLinePath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) * 0.75 - self.arrowShapeLayer.lineWidth)];
    self.verLineShapeLayer.path = verLinePath.CGPath;
    
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:CGPointMake(CGRectGetWidth(self.frame) * 0.35, CGRectGetHeight(self.frame) * 0.5)];
    [arrowPath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) * 0.75)];
    [arrowPath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame) * 0.65, CGRectGetHeight(self.frame) * 0.5)];
    self.arrowShapeLayer.path = arrowPath.CGPath;
    
    
    UIBezierPath *progressPath = [UIBezierPath bezierPath];
//    [progressPath moveToPoint:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetWidth(self.frame) / 2)];
    [progressPath addArcWithCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2) radius:CGRectGetWidth(self.frame) / 2  startAngle:-M_PI_2 endAngle:2 * M_PI - M_PI_2 clockwise:YES];
    
    self.progressShapeLayer.path = progressPath.CGPath;
}
#pragma mark -Action

/**
 按钮被点击了
 
 @param tap 点击手势
 */
- (void)onTap:(UITapGestureRecognizer*)tap {
    switch (self.state) {
            case WMDownloadButtonNone:  //无状态
        {
            [self wm_beginDownLoading];
        }
            break;
            case WMDownloadButtonLoading: //下载中
        {
//            [self suspend];
            if (self.block) {
                self.block(self);
            }
        }
            break;
            case WMDownloadButtonSuspend: //暂停
        {
//            [self resume];
            if (self.block) {
                self.block(self);
            }
        }
            break;
            case WMDownloadButtonResume: //恢复
        {
            
//            [self suspend];
            if (self.block) {
                self.block(self);
            }
        }
            break;
            case WMDownloadButtonEnd:     //下载完成
        {
//            [self reset];
            if (self.block) {
                self.block(self);
            }
        }
            break;
        default:
            break;
    }
    
}


#pragma mark -- 开始下载
- (void)wm_beginDownLoading{
    self.state  = WMDownloadButtonWillLoad;
    
    
    //变为点
    UIBezierPath         *pointPath      = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2 + 1) radius:.5 startAngle:0 endAngle:2*M_PI clockwise:NO];
    CABasicAnimation    *changeToPoint   = [CABasicAnimation animationWithKeyPath:@"path"];
    changeToPoint.toValue                = (__bridge id)(pointPath.CGPath);
    changeToPoint.fillMode               = kCAFillModeForwards;
    changeToPoint.removedOnCompletion    = NO;
    changeToPoint.duration               = .2;
    [self.verLineShapeLayer addAnimation:changeToPoint forKey:nil];
    
    
    //箭头变为线
    CABasicAnimation   *lineAniamtion  = [CABasicAnimation animationWithKeyPath:@"position.y"];
    lineAniamtion.duration              = .2;
    lineAniamtion.fillMode              = kCAFillModeBackwards;
    lineAniamtion.toValue               = @(self.arrowShapeLayer.frame.origin.y +10);
    lineAniamtion.removedOnCompletion   = NO;
    
    UIBezierPath         *linePath      = [UIBezierPath bezierPath];
    [linePath moveToPoint: CGPointMake(CGRectGetWidth(self.frame) / 2 * .5, CGRectGetHeight(self.frame) *.5 )];
    [linePath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) *.5 )];
    [linePath addLineToPoint: CGPointMake(CGRectGetWidth(self.frame) / 2 * 1.5, CGRectGetHeight(self.frame) *.5 )];;
    
    CASpringAnimation   *lineSpringAnimation    = [CASpringAnimation animationWithKeyPath:@"path"];
    lineSpringAnimation.toValue                 = (__bridge id _Nullable)(linePath.CGPath);
    lineSpringAnimation.duration                = lineSpringAnimation.settlingDuration;
    lineSpringAnimation.damping                 = 0;
    lineSpringAnimation.mass                    = 30;
    lineSpringAnimation.stiffness               = 5;
    lineSpringAnimation.initialVelocity         = 30;
    lineSpringAnimation.fillMode                = kCAFillModeForwards;
    lineSpringAnimation.beginTime               = .2;
    lineSpringAnimation.removedOnCompletion     = NO;
    
    
    CAAnimationGroup    *groupAnimation         = [CAAnimationGroup animation];
    groupAnimation.duration                     = 1;
    groupAnimation.fillMode                     = kCAFillModeForwards;
    groupAnimation.removedOnCompletion          = NO;
    groupAnimation.animations                   = @[lineAniamtion,lineSpringAnimation];
    [self.arrowShapeLayer addAnimation:groupAnimation forKey:nil];
    
    //圆点起跳
    CASpringAnimation   *pointSpringAnimation   = [CASpringAnimation animationWithKeyPath:@"position.y"];
    pointSpringAnimation.delegate               = self;
    [pointSpringAnimation setValue:@"pointLayer" forKey:@"name"];
    pointSpringAnimation.toValue                = @(-CGRectGetHeight(self.frame)*.5 - self.bgCircleShapeLayer.lineWidth * 0.5  + self.verLineShapeLayer.lineWidth * 0.5 );
    pointSpringAnimation.duration               = pointSpringAnimation.settlingDuration;
    pointSpringAnimation.fillMode               = kCAFillModeForwards;
    pointSpringAnimation.removedOnCompletion    = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(changeToPoint.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.verLineShapeLayer addAnimation:pointSpringAnimation forKey:nil];
    });
}

#pragma mark -CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSString *name = [anim valueForKey:@"name"];
    if ([name isEqualToString:@"pointLayer"]) { //完成点的动画
        [self.layer addSublayer:self.progressShapeLayer];
        
        //变更状态
        self.state = WMDownloadButtonLoading;
        if (self.block) {
            self.block(self);
        }
        
        [self opacityAnimationWithLayer:self.arrowShapeLayer fromValue:1. toValue:0.];
        self.progressShapeLayer.lineWidth       = 6.;
        
//        self.waveLayer                          = [[AIDownloadWaveLayer alloc]init];
//        self.waveLayer.onView                   = self;
//        self.waveLayer.lineWidth                = 3.;
//        self.waveLayer.waveColor                = [UIColor flatWhiteColor];
//        [self.layer addSublayer:self.waveLayer];
//        [self.waveLayer waveAnimate];
        //文件大小
        
        [self scaleAnimationWithLayer:self.progressLabel.layer fromValue:.1 toValue:1.];
        
        [self opacityAnimationWithLayer:self.progressLabel.layer fromValue:0. toValue:1.];
    }
    
}

/**
 不透明度动画
 
 @param layer 要执行动画的layer
 @param from 从多少开始
 @param to 到多少
 */
- (void)opacityAnimationWithLayer:(CALayer*)layer fromValue:(CGFloat)from toValue:(CGFloat)to {
    POPBasicAnimation *opacityAnimation          = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnimation.toValue                     = @(to);
    opacityAnimation.fromValue                   = @(from);
    opacityAnimation.duration                    = .3;
    [layer pop_addAnimation:opacityAnimation forKey:nil];
}

/**
 缩放动画
 
 @param layer 所要缩放的layer
 @param from 从多少比例开始
 @param to 到多少比例
 */
- (void)scaleAnimationWithLayer:(CALayer*)layer fromValue:(CGFloat)from toValue:(CGFloat)to {
    //文件大小
    POPBasicAnimation   *scaleAnimation          = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.fromValue                     = [NSValue valueWithCGPoint:CGPointMake(from, from)];
    scaleAnimation.toValue                       = [NSValue valueWithCGPoint:CGPointMake(to, to)];
    scaleAnimation.duration                      = .3;
    [layer pop_addAnimation:scaleAnimation forKey:nil];
}

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    self.progressShapeLayer.strokeStart   = 1-progress;
    NSLog(@"++++++++++++++++++%f" , progress);
    if (progress >= 1) {
//        [self end];
    }
}
- (void)setText:(NSString *)text{
    _text = text;
    self.progressLabel.text = text;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
