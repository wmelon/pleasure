//
//  WMTapDetectingImageView.m
//  Pleasure
//
//  Created by Sper on 2017/8/11.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMTapDetectingImageView.h"

@implementation WMTapDetectingImageView

@synthesize tapDelegate;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = YES;
        [self wm_configTap];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    if ((self = [super initWithImage:image])) {
        self.userInteractionEnabled = YES;
        [self wm_configTap];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    if ((self = [super initWithImage:image highlightedImage:highlightedImage])) {
        self.userInteractionEnabled = YES;
        [self wm_configTap];
    }
    return self;
}

- (void)wm_configTap{
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [self addGestureRecognizer:singleTapGestureRecognizer];
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
    [self addGestureRecognizer:doubleTapGestureRecognizer];
    
    //这行很关键，意思是只有当没有检测到doubleTapGestureRecognizer 或者 检测doubleTapGestureRecognizer失败，singleTapGestureRecognizer才有效
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
}

- (void)singleTap:(UITapGestureRecognizer *)tapGesture{
    if ([self.tapDelegate respondsToSelector:@selector(imageView:singleTapDetected:)]){
        [self.tapDelegate imageView:self singleTapDetected:[tapGesture locationInView:self]];
    }
}
- (void)doubleTap:(UITapGestureRecognizer *)tapGesture{
    if ([self.tapDelegate respondsToSelector:@selector(imageView:doubleTapDetected:)]){
        [self.tapDelegate imageView:self doubleTapDetected:[tapGesture locationInView:self]];
    }
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    NSUInteger tapCount = touch.tapCount;
//    switch (tapCount) {
//        case 1:
//            [self handleSingleTap:touch];
//            break;
//        case 2:
//            [self handleDoubleTap:touch];
//            break;
//        case 3:
//            [self handleTripleTap:touch];
//            break;
//        default:
//            break;
//    }
//    [[self nextResponder] touchesEnded:touches withEvent:event];
//}
//
//- (void)handleSingleTap:(UITouch *)touch {
//    if ([tapDelegate respondsToSelector:@selector(imageView:singleTapDetected:)])
//        [tapDelegate imageView:self singleTapDetected:touch];
//}
//
//- (void)handleDoubleTap:(UITouch *)touch {
//    if ([tapDelegate respondsToSelector:@selector(imageView:doubleTapDetected:)])
//        [tapDelegate imageView:self doubleTapDetected:touch];
//}

@end


@implementation WMTapDetectingBgView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

