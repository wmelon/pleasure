//
//  WMBaseModel.h
//  Pleasure
//
//  Created by Sper on 2017/8/14.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

@interface WMBaseModel : NSObject
/**
 *  YYModel 返回属性的映射关系，一样的不用写  eg:  "Id":"id"
 *
 *  @return 解析完成的字典
 */
+ (NSDictionary *)modelPropertyMapper;
/**
 *  返回属性中模型的映射关系， eg:  "item":[ItemModel class]
 *
 *  @return 解析完成的字典
 */
+ (NSDictionary *)modelClassMapper;

/**
 *  字典返回模型
 *
 *  @param dict  字典数据
 *
 *  @return 模型数据
 */
+ (instancetype)pc_modelWithDictionary:(NSDictionary *)dict;
/**
 *  字典解析成数组
 *
 *  @param array json数组数据
 *
 *  @return 模型数组
 */
+ (NSArray *)pc_modelListWithArray:(NSArray *)array;

@end
