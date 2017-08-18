//
//  WMDownloadWaveLayer.h
//  Pleasure
//
//  Created by Sper on 2017/8/18.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface WMDownloadWaveLayer : CAShapeLayer
/** frame*/
@property (nonatomic , strong) UIView *onView;
/** 是否停止*/
@property(nonatomic, assign,getter=isStop)BOOL stop;
- (void)waveAnimate;

@end
