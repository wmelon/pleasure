//
//  WMPhoto.h
//  Pleasure
//
//  Created by Sper on 2017/8/10.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMPhoto : NSObject

@property (nonatomic , copy) NSString * photoUrl;
@property (nonatomic , strong) UIImage * photo;

/// 是否是添加视图 默认是 NO
@property (nonatomic , assign) BOOL isAddPhoto;
/// 为显示图片分配一个顺序
//@property (nonatomic , assign) NSInteger index;



//- (instancetype)initWithIndex:(NSInteger)index;

@end
