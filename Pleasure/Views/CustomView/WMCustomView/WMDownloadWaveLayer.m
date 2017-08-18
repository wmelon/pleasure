//
//  WMDownloadWaveLayer.m
//  Pleasure
//
//  Created by Sper on 2017/8/18.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMDownloadWaveLayer.h"

static const NSTimeInterval KAnimationDuration = 0.3;

@interface WMDownloadWaveLayer()<CAAnimationDelegate>
@property (nonatomic , assign) CGFloat amplitude_A;
@property (nonatomic , assign) CGFloat cycle_ω;
@property (nonatomic , strong) NSMutableArray<UIBezierPath *> *wavePathArray;
@property (nonatomic , strong) UIBezierPath *wavePathComplete;
@property (nonatomic , assign) BOOL isStop;
@end

@implementation WMDownloadWaveLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.fillColor = [UIColor clearColor].CGColor;
        self.lineCap   = kCALineCapRound;
        self.lineJoin  = kCALineJoinRound;
        _amplitude_A   = 3.;
        _cycle_ω       = .3;
    }
    return self;
}

-(void)setOnView:(UIView *)onView {
    _onView    = onView;
    
    for (int i = 0 ; i <= 4 ; i ++){
        UIBezierPath *path = [self wm_getPathWithIndex:i view:onView];
        [self.wavePathArray addObject:path];
    }
    
    _wavePathComplete = [UIBezierPath bezierPath];
    [_wavePathComplete moveToPoint:CGPointMake(onView.frame.size.width / 2 *.7, onView.frame.size.height / 2)];
    [_wavePathComplete addLineToPoint:CGPointMake(onView.frame.size.width / 2*.9, onView.frame.size.height / 2 *1.25)];
    [_wavePathComplete addLineToPoint:CGPointMake(onView.frame.size.width / 2 *1.3, onView.frame.size.height *0.35)];
    
}
- (void)waveAnimate {
    [self waveAnimateWithLayer:self];
}

- (UIBezierPath *)wm_getPathWithIndex:(NSInteger)index view:(UIView *)onView{
    CGFloat y = 0.0;
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if (index == 0){
        [path moveToPoint:CGPointMake(onView.frame.size.width / 4, onView.frame.size.height / 2)];
        for (CGFloat x = 0.0 ; x < onView.frame.size.width / 2 ; x++){
            y = self.amplitude_A * sin(self.cycle_ω * x);
            [path addLineToPoint:CGPointMake(x + onView.frame.size.width / 4, y + onView.frame.size.height / 2)];
        }
        self.path = path.CGPath;
    }else {
    
        for (float x = 0.0f; x<onView.frame.size.width * .5; x++) {
            y        = self.amplitude_A * sin(_cycle_ω * x + M_PI_2 * index);
            if (x == 0) {
                [path moveToPoint:CGPointMake(x + onView.frame.size.width / 4, y + onView.frame.size.height / 2)];
            }else {
                [path addLineToPoint:CGPointMake(x + onView.frame.size.width / 4 , y + onView.frame.size.height / 2)];
            }
        }
    }
    
    return path;
}

- (void)waveAnimateWithLayer:(CALayer*)layer {

    __block CFTimeInterval durationComplete = 0.0;

    NSMutableArray * array = [NSMutableArray arrayWithCapacity:self.wavePathArray.count];
    [self.wavePathArray enumerateObjectsUsingBlock:^(UIBezierPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        if (idx < self.wavePathArray.count - 1){
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
            animation.fromValue = (__bridge id _Nullable)obj.CGPath;
            animation.toValue = (__bridge id _Nullable)self.wavePathArray[idx + 1].CGPath;
            animation.duration =  KAnimationDuration;
            animation.beginTime = durationComplete;


            durationComplete += animation.duration;
            [array addObject:animation];
        }
    }];


    CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc] init];
    animationGroup.delegate = self;
    [animationGroup setValue:@"group" forKey:@"name"];
    animationGroup.animations = array;
    animationGroup.duration = durationComplete;
    animationGroup.fillMode               = kCAFillModeForwards;
    animationGroup.removedOnCompletion    = NO;
    [layer addAnimation:animationGroup forKey:nil];

}

#pragma mark -CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSString *name  = [anim valueForKey:@"name"];
    if ([name isEqualToString:@"group"] ) {
        if (self.isStop) {
            CABasicAnimation *waveAnimationCompelted = [CABasicAnimation animationWithKeyPath:@"path"];
            waveAnimationCompelted.fromValue = (__bridge id _Nullable)([self.wavePathArray firstObject].CGPath);
            waveAnimationCompelted.toValue = (__bridge id _Nullable)(self.wavePathComplete.CGPath);
            waveAnimationCompelted.duration = KAnimationDuration;
            waveAnimationCompelted.fillMode = kCAFillModeForwards;
            waveAnimationCompelted.removedOnCompletion = NO;
            [self addAnimation:waveAnimationCompelted forKey:nil];
        }else {
            [self waveAnimateWithLayer:self];
        }
    }
}

- (NSMutableArray *)wavePathArray{
    if (_wavePathArray == nil){
        _wavePathArray = [NSMutableArray array];
    }
    return _wavePathArray;
}
@end
