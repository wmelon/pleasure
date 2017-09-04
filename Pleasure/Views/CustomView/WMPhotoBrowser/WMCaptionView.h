//
//  WMCaptionView.h
//  Pleasure
//
//  Created by Sper on 2017/8/10.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMPhotoModel.h"

@interface WMCaptionView : UIView

- (CGSize)captionViewSizeWithPhoto:(WMPhotoModel *)photo currentIndex:(NSInteger)currentIndex count:(NSInteger)count captionWidth:(CGFloat)width;
@end
