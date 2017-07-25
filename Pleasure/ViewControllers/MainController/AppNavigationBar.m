//
//  AppNavigationBar.m
//  Pleasure
//
//  Created by Sper on 2017/7/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "AppNavigationBar.h"

@interface AppNavigationBar()
@property (nonatomic , strong)UIView *barBackgroundView;

@property (nonatomic , strong)UIView * blurBackView;
@end

@implementation AppNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translucent = YES;
//        UIImage *_storedBackgroundImage = [UIImage buildImageWithColor:[UIColor tabBarColor]];
//        [self setBackgroundImage:_storedBackgroundImage forBarMetrics:UIBarMetricsDefault];
        
        NSShadow* shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor clearColor];
        self.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17],
                                     NSForegroundColorAttributeName:[UIColor whiteColor],
                                     NSShadowAttributeName:shadow};
        self.shadowImage = [[UIImage alloc] init];
        self.layer.shadowColor = [UIColor lineColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0.5);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 0.1;
        self.tintColor = [UIColor whiteColor];
        
        
        /// 添加背景毛玻璃效果
//        [self addSubview:self.blurBackView];
//        [self sendSubviewToBack:self.blurBackView];
    }
    return self;
}

- (UIView *)barBackgroundView{
    if (_barBackgroundView == nil){
        //    //拦截背景视图
        for (UIView * view in self.subviews){
            NSString * className = NSStringFromClass([view class]);
            if ([className isEqualToString:@"_UINavigationBarBackground"] || [className isEqualToString:@"_UIBarBackground"]){
                _barBackgroundView = view;
            }
        }
    }
    return _barBackgroundView;
}

////MARK: 隐藏背景的NavigationBar
- (void)willMoveToSuperview:(UIView *)newSuperview{
    if (newSuperview != nil){
        //隐藏navigationBar背景视图
        self.barBackgroundView.hidden = YES;
    }
}


- (UIView *)blurBackView
{
    if (_blurBackView == nil) {
        _blurBackView = [UIView new];
        _blurBackView.frame = CGRectMake(0, -20, self.frame.size.width, 64);
//        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
//        gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, 64);
//        gradientLayer.colors = @[(__bridge id)[UIColor redColor].CGColor , (__bridge id)[UIColor yellowColor].CGColor];
//        gradientLayer.startPoint = CGPointMake(0, 0);
//        gradientLayer.endPoint = CGPointMake(0, 1.0);
        _blurBackView.backgroundColor = [UIColor blackColor];
//        [_blurBackView.layer addSublayer:gradientLayer];
        _blurBackView.userInteractionEnabled = NO;
        _blurBackView.alpha = 0.2;
    }
    return _blurBackView;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end





