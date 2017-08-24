//
//  WMTapDetectingImageView.h
//  Pleasure
//
//  Created by Sper on 2017/8/11.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WMTapDetectingImageViewDelegate <NSObject>
@optional

- (void)imageView:(UIImageView *)imageView singleTapDetected:(CGPoint)point;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(CGPoint)point;
@end


@interface WMTapDetectingImageView : UIImageView

@property (nonatomic, weak) id<WMTapDetectingImageViewDelegate> tapDelegate;

@end


@interface WMTapDetectingBgView : WMTapDetectingImageView

@end
