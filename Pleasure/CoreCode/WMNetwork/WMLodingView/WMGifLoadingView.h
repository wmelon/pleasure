//
//  WMGifLoadingView.h
//  Pleasure
//
//  Created by Sper on 2017/12/18.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger , WMLoadingType) {
    WMLoadingType_gifImage,  /// 自定制图片动画
    WMLoadingType_indicator /// 系统小菊花
};

@interface WMGifLoadingView : UIView
- (void)showWithMessage:(NSString *)message type:(WMLoadingType)type;
- (void)hidden;
@end
