//
//  AppNavigationBar.m
//  Pleasure
//
//  Created by Sper on 2017/7/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "AppNavigationBar.h"

@interface AppNavigationBar()
//@property (nonatomic , strong)UIView *barBackgroundView;
@end

@implementation AppNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translucent = YES;
//        UIImage *_storedBackgroundImage = [UIImage buildImageWithColor:[UIColor mainColor]];
        
        /// 设置系统的导航栏背景为空，为的是显示自己定义的背景视图
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        
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
    }
    return self;
}

//- (UIView *)barBackgroundView{
//    if (_barBackgroundView == nil){
//        //    //拦截背景视图
//        for (UIView * view in self.subviews){
//            NSString * className = NSStringFromClass([view class]);
//            if ([className isEqualToString:@"_UINavigationBarBackground"] || [className isEqualToString:@"_UIBarBackground"]){
//                _barBackgroundView = view;
//            }
//        }
//    }
//    return _barBackgroundView;
//}
//
//////MARK: 隐藏背景的NavigationBar
//- (void)willMoveToSuperview:(UIView *)newSuperview{
//    if (newSuperview != nil){
//        //隐藏navigationBar背景视图
//        self.barBackgroundView.hidden = YES;
//    }
//}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end





