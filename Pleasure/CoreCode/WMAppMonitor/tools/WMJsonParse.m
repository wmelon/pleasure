//
//  WMJsonParse.m
//  Pleasure
//
//  Created by Sper on 2018/4/19.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMJsonParse.h"

@implementation WMJsonModel
@end

#define kWMS_Width [UIScreen mainScreen].bounds.size.width
@implementation WMJsonParse

+ (NSArray<WMJsonModel *> *)parseJsonWithData:(id)data{
    NSArray<WMJsonModel *> *resultList;
    if ([data isKindOfClass:[NSDictionary class]]){
        resultList = [self configArrayWithDict:data degree:0];
    }else if ([data isKindOfClass:[NSArray class]]){
        resultList = [self configDictWithArray:data degree:0];
    }
    return resultList;
}
+ (NSArray *)configArrayWithDict:(NSDictionary *)dict degree:(NSInteger)degree{
    NSMutableArray *dataList = [NSMutableArray arrayWithCapacity:dict.count];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        WMJsonModel *jsonModel = [[WMJsonModel alloc] init];
        jsonModel.degree = degree;
        [self dealWithKey:key obj:obj jsonModel:jsonModel degree:degree];
        [dataList addObject:jsonModel];
    }];
    return dataList;
}

+ (NSArray *)configDictWithArray:(NSArray *)array degree:(NSInteger)degree{
    NSMutableArray *dataList = [NSMutableArray arrayWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WMJsonModel *jsonModel = [[WMJsonModel alloc] init];
        jsonModel.degree = degree;
        [self dealWithKey:[NSString stringWithFormat:@"%zd",idx] obj:obj jsonModel:jsonModel degree:degree];
        [dataList addObject:jsonModel];
    }];
    return dataList;
}
+ (void)dealWithKey:(NSString *)key obj:(id)obj jsonModel:(WMJsonModel *)jsonModel degree:(NSInteger)degree{
    /// 显示的key  和 value的间隔
    CGFloat keyValuePadding = 5;
    /// 每一行左右间距
    CGFloat leftRightPadding = 10;
    /// 每一行上下间距
    CGFloat topBottomPadding = 5;
    /// 展开按钮宽度
    CGFloat openCloseBtnWidth = 40;
    /// 展开按钮的宽度
    CGFloat openCloseBtnheight = 20;
    CGFloat valueHeight = 0;
    jsonModel.key = [NSString stringWithFormat:@"😈 %@ :" , key];
    /// 10是展开按钮距离左边距离  18 是每一层级展开按钮缩进 18
    jsonModel.leftPadding = degree * 18 + leftRightPadding;
    UIFont *font = [UIFont systemFontOfSize:12];
    CGSize keySize = [self sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:font text:jsonModel.key];
    if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]){
        CGFloat valueMaxWidth = kWMS_Width - jsonModel.leftPadding - openCloseBtnWidth - keyValuePadding - keySize.width - keyValuePadding - leftRightPadding;
        jsonModel.value = [NSString stringWithFormat:@"%@" , obj];
        valueHeight = [self sizeWithConstrainedToSize:CGSizeMake(valueMaxWidth, CGFLOAT_MAX) font:font text:jsonModel.value].height;
    }else if ([obj isKindOfClass:[NSArray class]]){
        NSArray *subList = [self configDictWithArray:obj degree:degree + 1];
        if (subList.count){
            jsonModel.canOpen = YES;
        }
        jsonModel.subList = subList;
        jsonModel.key = [NSString stringWithFormat:@"[ ] %@" , key];
    }else if ([obj isKindOfClass:[NSDictionary class]]){
        NSArray *subList = [self configArrayWithDict:obj degree:degree + 1];
        if (subList.count){
            jsonModel.canOpen = YES;
        }
        jsonModel.key = [NSString stringWithFormat:@"{ } %@" , key];
        jsonModel.subList = subList;
    }
    if (jsonModel.canOpen){
        valueHeight = openCloseBtnheight;
        jsonModel.btnHeight = valueHeight;
    }else {
        if (valueHeight > openCloseBtnheight){
            jsonModel.btnHeight = keySize.height;
        }else if (valueHeight > 0 && valueHeight < openCloseBtnheight){
            jsonModel.btnHeight = valueHeight;
        }else {
            valueHeight = keySize.height;
            jsonModel.btnHeight = valueHeight;
        }
    }
    jsonModel.btnWidth = openCloseBtnWidth;
    jsonModel.cellHeight = valueHeight + 2 * topBottomPadding;
}


+ (CGSize)sizeWithConstrainedToSize:(CGSize)size font:(UIFont *)font text:(NSString *)text{
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize  actualsize = CGSizeZero;
    actualsize =[text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    //强制转化为整型(比初值偏小)，因为float型size转到view上会有一定的偏移，导致view setBounds时候 错位
    CGSize contentSize =CGSizeMake(ceil(actualsize.width), ceil(actualsize.height));
    return contentSize;
}
@end
