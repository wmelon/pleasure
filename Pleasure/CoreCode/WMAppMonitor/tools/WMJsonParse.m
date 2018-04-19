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
    CGFloat openCloseBtnWidth = 15;
    CGFloat valueHeight = 0;
    jsonModel.key = [NSString stringWithFormat:@"😈 %@ :" , key];
    /// 10是展开按钮距离左边距离  18 是每一层级展开按钮缩进 18
    jsonModel.leftPadding = degree * 18 + leftRightPadding;
    if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]){
        UIFont *font = [UIFont systemFontOfSize:12];
        CGFloat keyWidth = [self sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:font text:jsonModel.key].width;
        CGFloat valueMaxWidth = kWMS_Width - jsonModel.leftPadding - openCloseBtnWidth - keyWidth  - keyValuePadding - leftRightPadding;
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
    jsonModel.valueHeight = (valueHeight > openCloseBtnWidth) ? valueHeight : openCloseBtnWidth;
    jsonModel.cellHeight = (jsonModel.valueHeight + 2 * topBottomPadding);
}

+ (CGSize)sizeWithConstrainedToSize:(CGSize)size font:(UIFont *)font text:(NSString *)text{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    style.alignment = NSTextAlignmentLeft;
    CGSize textSize = [text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: font,NSParagraphStyleAttributeName:style} context:nil].size;
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}
@end
