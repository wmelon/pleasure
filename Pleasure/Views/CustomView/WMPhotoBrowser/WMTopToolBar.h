//
//  WMTopToolBar.h
//  Pleasure
//
//  Created by Sper on 2017/9/4.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger , WMButtonType) {
    WMButtonTypeClose ,  /// 关闭按钮
    WMButtonTypeDetailMore /// 详情按钮
};

/// 关闭按钮点击回调
typedef void (^WMCloseButtonClickHandle)(WMButtonType buttonType);

@interface WMTopToolBar : UIView

- (instancetype)initWithFrame:(CGRect)frame buttonClickHandle:(WMCloseButtonClickHandle)handle;

@end
