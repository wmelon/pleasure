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
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;
@end


@interface WMTapDetectingImageView : UIImageView

@property (nonatomic, weak) id<WMTapDetectingImageViewDelegate> tapDelegate;

@end


@interface WMTapDetectingBgView : WMTapDetectingImageView

@end
