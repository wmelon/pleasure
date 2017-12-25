//
//  UIView+WMAppView.m
//  Pleasure
//
//  Created by Sper on 2017/12/22.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "UIView+WMAppView.h"

@implementation UIView (WMAppView)
- (UIImage *)snapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}
@end
