//
//  WMJsonParse.h
//  Pleasure
//
//  Created by Sper on 2018/4/19.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMJsonModel : NSObject
/// 显示的名称
@property (nonatomic , copy  ) NSString *key;
/// 显示的值
@property (nonatomic , copy  ) NSString *value;
/// 是否有允许打开
@property (nonatomic , assign) BOOL canOpen;
/// 所有的子集
@property (nonatomic , strong) NSArray<WMJsonModel *> *subList;
/// 层级深度
@property (nonatomic , assign) NSInteger degree;
/// 是否是打开的
@property (nonatomic , assign , getter=isOpen) BOOL open;
/// cell的高度
@property (nonatomic , assign) CGFloat cellHeight;
/// 不同层级缩进距离
@property (nonatomic , assign) CGFloat leftPadding;
/// 展开和关闭按钮高度
@property (nonatomic , assign) CGFloat btnHeight;
@property (nonatomic , assign) CGFloat btnWidth;
@end

@interface WMJsonParse : NSObject
+ (NSArray<WMJsonModel *> *)parseJsonWithData:(id)data;
@end
