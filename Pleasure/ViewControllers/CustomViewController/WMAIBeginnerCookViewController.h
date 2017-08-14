//
//  WMAIBeginnerCookViewController.h
//  Pleasure
//
//  Created by Sper on 2017/8/14.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "BaseViewController.h"

@class WMAIHerbModel;
@interface WMAIBeginnerCookViewController : BaseViewController

@end


@interface WMAIHerbModel : NSObject
/** 名字*/
@property(nonatomic, copy)NSString *name;
/** 图片名字*/
@property(nonatomic, copy)NSString *image;
/** 执照*/
@property(nonatomic, copy)NSString *license;
/** 信用*/
@property(nonatomic, copy)NSString *credit;
/** 描述*/
@property(nonatomic, copy)NSString *descriptionString;
@end
