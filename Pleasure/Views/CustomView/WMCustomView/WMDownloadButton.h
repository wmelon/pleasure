//
//  WMDownloadButton.h
//  Pleasure
//
//  Created by Sper on 2017/8/15.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    WMDownloadButtonNone,
    WMDownloadButtonEnd, //完成
    WMDownloadButtonSuspend,  //暂停
    WMDownloadButtonLoading,   //下载中
    WMDownloadButtonWillLoad,  //将要下载（小圆点动画完成后）
    WMDownloadButtonResume     //恢复下载
} WMDownloadButtonStates;

@interface WMDownloadButton : UIView
/** 按钮状态*/
@property(nonatomic, assign)WMDownloadButtonStates state;

/** block*/
@property(nonatomic, copy)void(^ _Nullable block)(WMDownloadButton * _Nullable button);

@property(nonatomic , assign) CGFloat progress;

@property(nonatomic , copy) NSString * _Nullable text;

@end
