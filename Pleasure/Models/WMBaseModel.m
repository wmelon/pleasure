//
//  WMBaseModel.m
//  Pleasure
//
//  Created by Sper on 2017/8/14.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMBaseModel.h"

@implementation WMBaseModel
/**
 *  返回属性的映射关系，一样的不用写  eg:  "Id":"id"
 *
 *  @return 解析完成的字典
 */
+ (NSDictionary *)modelPropertyMapper{
    NSLog(@"子类需要重写%s",__FUNCTION__);
    return nil;
}

/**
 *  返回属性中模型的映射关系， eg:  "item":[ItemModel class]
 *
 *  @return 解析完成的字典
 */
+ (NSDictionary *)modelClassMapper{
    NSLog(@"子类需要重写%s",__FUNCTION__);
    return nil;
}

+ (instancetype)pc_modelWithDictionary:(NSDictionary *)dict {
    return [self yy_modelWithDictionary:dict];
}
+ (NSArray *)pc_modelListWithArray:(NSArray *)array{
    NSMutableArray * dataArray = [NSMutableArray array];
    for (int i = 0 ; i < [array count]; i ++ ) {
        [dataArray addObject:[self pc_modelWithDictionary:array[i]]];
    }
    return dataArray;
}
@end
