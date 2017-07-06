//
//  AppNavigationBar.m
//  Pleasure
//
//  Created by Sper on 2017/7/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "AppNavigationBar.h"

@implementation AppNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translucent = YES;
        UIImage *_storedBackgroundImage = [UIImage buildImageWithColor:[UIColor grayColor]];
        [self setBackgroundImage:_storedBackgroundImage forBarMetrics:UIBarMetricsDefault];
        
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
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
