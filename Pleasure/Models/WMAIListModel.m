//
//  WMAIListModel.m
//  Pleasure
//
//  Created by Sper on 2017/8/14.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMAIListModel.h"
#import "StringAttribute.h"
#import "FontAttribute.h"
#import "ForegroundColorAttribute.h"
#import "NSMutableAttributedString+StringAttribute.h"

@implementation WMAIListModel


+(instancetype)initWithTitle:(NSString *)title andTargetVC:(Class )targetVC{
    WMAIListModel *model = [[WMAIListModel alloc]initWithTitle:title andTargetVC:targetVC];
    return model;
}

- (instancetype)initWithTitle:(NSString *)title andTargetVC:(Class )targetVC{
    self = [super init];
    if (self) {
        _title = title;
        _targetVC = targetVC;
    }
    return self;
}

- (void)createAttributedString {
    
    NSString *fullStirng = [NSString stringWithFormat:@"%02ld. %@", (long)self.index, self.title];

    NSMutableAttributedString *richString = [[NSMutableAttributedString alloc] initWithString:fullStirng];

    {
        FontAttribute *fontAttribute = [FontAttribute new];
        fontAttribute.font           = [UIFont systemFontOfSize:16.f];
        fontAttribute.effectRange    = NSMakeRange(0, richString.length);
        [richString addStringAttribute:fontAttribute];
    }
    
    {
        FontAttribute *fontAttribute = [FontAttribute new];
        fontAttribute.font           = [UIFont fontWithName:@"GillSans-Italic" size:16.f];
        fontAttribute.effectRange    = NSMakeRange(0, 3);
        [richString addStringAttribute:fontAttribute];
    }
    
    {
        ForegroundColorAttribute *foregroundColorAttribute = [ForegroundColorAttribute new];
        foregroundColorAttribute.color                     = [[UIColor blackColor] colorWithAlphaComponent:0.65f];
        foregroundColorAttribute.effectRange               = NSMakeRange(0, richString.length);
        [richString addStringAttribute:foregroundColorAttribute];
    }
    
    {
        ForegroundColorAttribute *foregroundColorAttribute = [ForegroundColorAttribute new];
        foregroundColorAttribute.color                     = [[UIColor redColor] colorWithAlphaComponent:0.65f];
        foregroundColorAttribute.effectRange               = NSMakeRange(0, 3);
        [richString addStringAttribute:foregroundColorAttribute];
    }
    
    _titleString = richString;
}
@end
