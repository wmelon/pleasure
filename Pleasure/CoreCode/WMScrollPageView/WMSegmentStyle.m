//
//  WMSegmentStyle.m
//  WMScrollPageView
//
//  Created by Sper on 2018/1/20.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMSegmentStyle.h"

@implementation WMSegmentStyle
- (instancetype)init {
    if(self = [super init]) {
        self.showMoveLine = YES;
        self.scaleTitle = NO;
        self.changeTitleColor = NO;
        self.showExtraButton = NO;
        self.scrollLineHeight = 2.0;
        self.scrollLineWidth = 0.0;
        self.titleMargin = 10.0;
        self.titleFont = [UIFont systemFontOfSize:17.0];
        self.titleBigScale = 1.2;
        self.normalTitleColor = [UIColor colorWithRed:51.0/255.0 green:53.0/255.0 blue:75/255.0 alpha:1.0];
        self.selectedTitleColor = [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:121/255.0 alpha:1.0];
        self.scrollLineColor = self.selectedTitleColor;
        self.segmentHeight = 44.0;
        self.bottomLineHeight = 0.5;
        self.bottomLineColor = [UIColor colorWithRed:225.0 / 255.0 green:225.0 / 255.0 blue:225.0 / 255.0 alpha:1.0];
        self.allowShowBottomLine = YES;
        self.showNavigationBar = YES;
        self.allowStretchableHeader = YES;
        self.itemSizeStyle = wm_itemSizeStyle_equal_width;
    }
    return self;
}
@end
