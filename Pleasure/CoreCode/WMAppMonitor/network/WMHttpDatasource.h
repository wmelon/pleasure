//
//  WMHttpDatasource.h
//  Pleasure
//
//  Created by Sper on 2018/4/16.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMAPMHttpModel.h"

@interface WMHttpDatasource : NSObject
+ (instancetype)shareInstance;

- (void)addHttpRequest:(WMAPMHttpModel *)httpModel;
- (NSArray<WMAPMHttpModel *> *)httpRequestArray;
- (void)clearAllHttpRequest;
@end
