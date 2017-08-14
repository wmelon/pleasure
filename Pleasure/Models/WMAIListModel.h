//
//  WMAIListModel.h
//  Pleasure
//
//  Created by Sper on 2017/8/14.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMBaseModel.h"

@interface WMAIListModel : WMBaseModel
/** title*/
@property(nonatomic, copy)NSString *title;
@property (nonatomic, strong, readonly) NSMutableAttributedString *titleString;
/** 跳转的VC*/
@property(nonatomic,strong)Class targetVC;
/** 第几个*/
@property(nonatomic,assign)NSInteger index;

/** 创建富文本*/
- (void)createAttributedString ;
+ (instancetype)initWithTitle:(NSString *)title andTargetVC:(Class )targetVC;

@end
