//
//  WMPhoto.h
//  Pleasure
//
//  Created by Sper on 2017/8/10.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMPhoto : NSObject

/// 图片地址（也有可能是图片 的 id）
@property (nonatomic , copy) NSString * photoUrl;
/// 图片对象
@property (nonatomic , strong) UIImage * photo;
/// 是否是添加视图 默认是 NO
@property (nonatomic , assign) BOOL isAddPhoto;

@end
