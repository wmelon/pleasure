//
//  NSObject+WMAutoCancelRequest.m
//  Pleasure
//
//  Created by Sper on 2017/12/14.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "NSObject+WMAutoCancelRequest.h"
#import <objc/runtime.h>

@interface WMWeakRequestManager : NSObject
@property (nonatomic , strong) MKRequestTask *requestTask;
@end

@implementation WMWeakRequestManager
@end


@interface WMDeallocRequests : NSObject
@property (strong, nonatomic) NSMutableArray<WMWeakRequestManager *> *weakRequests;
@property (strong, nonatomic) NSLock *lock;
@end

@implementation WMDeallocRequests
- (instancetype)init{
    if (self = [super init]) {
        _weakRequests = [NSMutableArray array];
        _lock = [[NSLock alloc]init];
    }
    return self;
}
- (void)addRequest:(WMWeakRequestManager *)request{
    if (!request || !request.requestTask) {
        return;
    }
    [_lock lock];
    [self.weakRequests addObject:request];
    [_lock unlock];
}

- (void)dealloc{
    for (WMWeakRequestManager *weakRequest in _weakRequests) {
        if ([weakRequest.requestTask respondsToSelector:@selector(cancel)]){
            [weakRequest.requestTask cancel];
        }
    }
    [_lock lock];
    [_weakRequests removeAllObjects];
    [_lock unlock];
}
@end


@implementation NSObject (WMAutoCancelRequest)

- (void)autoCancelRequestOnDealloc:(MKRequestTask *)request{
    WMWeakRequestManager *weakRequest = [[WMWeakRequestManager alloc] init];
    weakRequest.requestTask = request;
    [[self deallocRequests] addRequest:weakRequest];
}


- (WMDeallocRequests *)deallocRequests{
    WMDeallocRequests *requests = objc_getAssociatedObject(self, _cmd);
    if (!requests) {
        requests = [[WMDeallocRequests alloc] init];
        objc_setAssociatedObject(self, _cmd, requests, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return requests;
}
- (void)showLoadingWithMessage:(NSString *)message{
    
}

@end
