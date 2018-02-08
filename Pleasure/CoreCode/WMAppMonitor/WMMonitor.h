//
//  WMMonitor.h
//  Pleasure
//
//  Created by Sper on 2018/2/6.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WMMonitorDelegate <NSObject>
@end

@interface WMMonitor : NSObject
/**
 *  不添加observer，启动 监听
 */
+ (void)startMonitor;
/**
 *  添加observer 并 启动监听
 *
 *  @param delegate 监听者
 */
+ (void)startMonitorWithDelegate:(id<WMMonitorDelegate>)delegate;
/// 停止监听
+ (void)stopMonitoring;
@end
