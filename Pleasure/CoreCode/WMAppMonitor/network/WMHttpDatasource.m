//
//  WMHttpDatasource.m
//  Pleasure
//
//  Created by Sper on 2018/4/16.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMHttpDatasource.h"

#define kMaxLength 40
@interface WMHttpDatasource()
@property (nonatomic , strong) NSMutableArray<WMAPMHttpModel *> *requestArray;
@end

@implementation WMHttpDatasource

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static WMHttpDatasource *object;
    dispatch_once(&onceToken, ^{
        object = [[WMHttpDatasource alloc] init];
    });
    return object;
}
- (void)addHttpRequest:(WMAPMHttpModel *)httpModel{
    if (httpModel && [httpModel isKindOfClass:[WMAPMHttpModel class]]){
        [self.requestArray insertObject:httpModel atIndex:0];
    }
    if (self.requestArray.count > kMaxLength){
        [self.requestArray removeLastObject];
    }
}
- (NSArray<WMAPMHttpModel *> *)httpRequestArray{
    return self.requestArray;
}

- (void)clearAllHttpRequest{
    @synchronized(self.requestArray) {
        [self.requestArray removeAllObjects];
    }
}

- (NSMutableArray<WMAPMHttpModel *> *)requestArray{
    if (_requestArray == nil){
        _requestArray = [NSMutableArray array];
    }
    return _requestArray;
}
@end
