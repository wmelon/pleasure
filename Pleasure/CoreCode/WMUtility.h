//
//  WMUtility.h
//  Pleasure
//
//  Created by Sper on 2017/11/28.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMUtility : NSObject
/// 通过图片获取base64字符
+ (void)Base64ImageStrWithImages:(NSArray *)images complete:(void(^)(NSArray *imageIds))complete;
// 是否是测试bunderId
+ (BOOL)isTestBundleIdentifier;
@end
