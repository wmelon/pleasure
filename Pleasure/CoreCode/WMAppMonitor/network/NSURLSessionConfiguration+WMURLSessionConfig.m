//
//  NSURLSessionConfiguration+WMURLSessionConfig.m
//  Pleasure
//
//  Created by Sper on 2018/2/6.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "NSURLSessionConfiguration+WMURLSessionConfig.h"
#import <objc/runtime.h>

@implementation NSURLSessionConfiguration (WMURLSessionConfig)
+ (void)swizzleMethod:(Class)cls originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector{
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
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:object_getClass(self) originalSelector:@selector(defaultSessionConfiguration) swizzledSelector:@selector(wm_defaultSessionConfiguration)];
        [self swizzleMethod:object_getClass(self) originalSelector:@selector(ephemeralSessionConfiguration) swizzledSelector:@selector(wm_ephemeralSessionConfiguration)];
    });
}

/// 网络请求配置必须要把当前类注册进去不然就无法实现拦截
+ (NSURLSessionConfiguration *)wm_defaultSessionConfiguration{
    NSURLSessionConfiguration *config = [self wm_defaultSessionConfiguration];
    [self configSession:config];
    return config;
}
+ (NSURLSessionConfiguration *)wm_ephemeralSessionConfiguration{
    NSURLSessionConfiguration *config = [self wm_ephemeralSessionConfiguration];
    [self configSession:config];
    return config;
}
+ (void)configSession:(NSURLSessionConfiguration *)sessionConfig{
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
              @"this method if the user is running iOS7+/OSX9+.", NSStringFromSelector(_cmd));
    }
}

@end
