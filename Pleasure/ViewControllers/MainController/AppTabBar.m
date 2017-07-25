//
//  AppTabBar.m
//  Pleasure
//
//  Created by Sper on 2017/7/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "AppTabBar.h"

@implementation AppTabBar

- (nonnull instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.translucent = NO;
        self.tintColor = [UIColor orangeColor];
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
