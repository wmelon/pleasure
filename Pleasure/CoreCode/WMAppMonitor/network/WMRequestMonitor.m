//
//  WMRequestMonitor.m
//  Pleasure
//
//  Created by Sper on 2018/3/14.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMRequestMonitor.h"
#import "WMURLProtocol.h"
#import <objc/runtime.h>

CF_INLINE void __swizzleMethod(Class cls , SEL originalSelector , SEL swizzledSelector){
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(cls,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(cls,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }

}
CF_INLINE void __configSession(NSURLSessionConfiguration *sessionConfig){
    if (   [sessionConfig respondsToSelector:@selector(protocolClasses)]
        && [sessionConfig respondsToSelector:@selector(setProtocolClasses:)])
    {
        NSMutableArray * urlProtocolClasses = [NSMutableArray arrayWithArray:sessionConfig.protocolClasses];
        Class protoCls = WMURLProtocol.class;
        if (![urlProtocolClasses containsObject:protoCls])
        {
            [urlProtocolClasses insertObject:protoCls atIndex:0];
        }
        sessionConfig.protocolClasses = urlProtocolClasses;
    }
    else
    {
        NSLog(@"[OHHTTPStubs] %@ is only available when running on iOS7+/OSX9+. "
              @"Use conditions like 'if ([NSURLSessionConfiguration class])' to only call "
              @"this method if the user is running iOS7+/OSX9+.", @"__configSession");
    }
}

@interface NSURLSession (WMIntercept)
@end
@implementation NSURLSession (WMIntercept)
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __swizzleMethod(object_getClass(self), @selector(sessionWithConfiguration:delegate:delegateQueue:), @selector(wm_sessionWithConfiguration:delegate:delegateQueue:));
        __swizzleMethod(object_getClass(self), @selector(sessionWithConfiguration:), @selector(wm_sessionWithConfiguration:));
    });
}
+ (NSURLSession *)wm_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue{
    __configSession(configuration);
    return [self wm_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}
+ (NSURLSession *)wm_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration{
    __configSession(configuration);
    return [self wm_sessionWithConfiguration:configuration];
}
@end

@implementation WMRequestMonitor

+ (void)startRequestMonitor{
    [NSURLProtocol registerClass:[WMURLProtocol class]];
    
}
+ (void)stopRequestMonitor{
    [NSURLProtocol unregisterClass:[WMURLProtocol class]];
}
@end
