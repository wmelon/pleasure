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
@property (nonatomic , weak) NSURLSessionTask *requestTask;
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
    if (!request || !request.requestTask || ![request.requestTask isKindOfClass:[NSURLSessionTask class]]) {
        return;
    }
    [_lock lock];
    [self.weakRequests addObject:request];
    [_lock unlock];
}

- (void)dealloc{
    for (WMWeakRequestManager *weakRequest in _weakRequests) {
        if ([weakRequest.requestTask isKindOfClass:[NSURLSessionTask class]]){
            [weakRequest.requestTask cancel];
        }
    }
    [_lock lock];
    [_weakRequests removeAllObjects];
    [_lock unlock];
}
@end


@implementation NSObject (WMAutoCancelRequest)

- (void)autoCancelRequestOnDealloc:(NSURLSessionTask *)request{
    WMWeakRequestManager *weakRequest = [[WMWeakRequestManager alloc] init];
    weakRequest.requestTask = request;
    [[self deallocRequests] addRequest:weakRequest];
}

- (void)autoCancelMoreRequestOnDealloc:(NSArray<NSURLSessionTask *> *)requests{
    for (NSURLSessionTask *task in requests) {
        [self autoCancelRequestOnDealloc:task];
    }
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
