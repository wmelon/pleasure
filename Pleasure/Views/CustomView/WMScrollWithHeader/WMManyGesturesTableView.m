//
//  WMManyGesturesTableView.m
//  Pleasure
//
//  Created by Sper on 2017/7/27.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMManyGesturesTableView.h"

@implementation WMManyGesturesTableView

//允许同时识别多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
