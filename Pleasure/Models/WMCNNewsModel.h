//
//  WMCNNewsModel.h
//  Pleasure
//
//  Created by Sper on 2018/5/24.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMBaseModel.h"

@interface WMCNNewsModel : WMBaseModel
@property (nonatomic , copy  ) NSString *author;
@property (nonatomic , copy  ) NSString *commentCount;
@property (nonatomic , copy  ) NSString *coverUrl;
@property (nonatomic , copy  ) NSString *displayTime;
@property (nonatomic , copy  ) NSString *title;
@property (nonatomic , copy  ) NSString *type;
@property (nonatomic , copy  ) NSString *videoUrl;
@end
