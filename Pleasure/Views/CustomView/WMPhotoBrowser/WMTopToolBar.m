//
//  WMTopToolBar.m
//  Pleasure
//
//  Created by Sper on 2017/9/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMTopToolBar.h"

@interface WMTopToolBar()
/// 关闭图片浏览按钮
@property (nonatomic , strong) UIButton *closeButton;
/// 查看其它功能按钮
@property (nonatomic , strong) UIButton *detailButton;
@end

@implementation WMTopToolBar

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        
        CGFloat colorIndex = 0.0;
        //为透明度设置渐变效果
        UIColor *colorOne = [UIColor colorWithRed:(colorIndex/255.0)  green:(colorIndex/255.0)  blue:(colorIndex/255.0)  alpha:0.3];
        UIColor *colorTwo = [UIColor colorWithRed:(colorIndex/255.0)  green:(colorIndex/255.0)  blue:(colorIndex/255.0)  alpha:0.0];
        NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        //设置开始和结束位置(设置渐变的方向)
        gradient.startPoint = CGPointMake(0, 0);
        gradient.endPoint = CGPointMake(0, 1.0);
        gradient.colors = colors;
        gradient.frame = self.bounds;
        [self.layer insertSublayer:gradient atIndex:0];
        

        CGFloat width = 40;
        CGFloat leftPadding = 10;
        CGFloat topPadding = 25;
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(leftPadding, topPadding, width, width)];
        [_closeButton setImage:[UIImage imageNamed:@"icon_close_more_wm"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
        
        _detailButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - width - leftPadding, topPadding, width, width)];
        [_detailButton setImage:[UIImage imageNamed:@"icon_detail_more_wm"] forState:UIControlStateNormal];
        [_detailButton addTarget:self action:@selector(detailMoreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_detailButton];

        
        
        
    }
    return self;
}

- (void)closeButtonClick:(UIButton *)button{
    
}

- (void)detailMoreButtonClick:(UIButton *)button{

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
