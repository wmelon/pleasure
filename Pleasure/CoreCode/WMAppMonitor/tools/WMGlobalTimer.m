//
//  WMGlobalTimer.m
//  Pleasure
//
//  Created by Sper on 2018/3/8.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMGlobalTimer.h"

static CFMutableDictionaryRef wm_global_callbacks = nil;
static dispatch_source_t wm_global_timer = nil;
@interface WMGlobalTimer()

@end

@implementation WMGlobalTimer

CF_INLINE void __WMInitGlobalCallbacks(){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wm_global_callbacks = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    });
}
CF_INLINE void __WMASyncExecute(dispatch_block_t block) {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        assert(block != nil);
        block();
    });
}
CF_INLINE void __WMAutoSwitchTimer(){
    /// 有监听定时器的回调方法 可以开启定时器
    if (CFDictionaryGetCount(wm_global_callbacks) > 0){
        if (wm_global_timer == nil){
            __WMResetTimer();
            dispatch_resume(wm_global_timer);
        }
    }else {
        if (wm_global_timer){
            dispatch_source_cancel(wm_global_timer);
            wm_global_timer = nil;
        }
    }
}
CF_INLINE void __WMResetTimer(){
    if (wm_global_timer){
        dispatch_source_cancel(wm_global_timer);
        wm_global_timer = nil;
    }
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    wm_global_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatchQueue);
    dispatch_source_set_timer(wm_global_timer, DISPATCH_TIME_NOW, 2.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(wm_global_timer, ^{
        NSUInteger count = CFDictionaryGetCount(wm_global_callbacks);
        void *callbacks[count];
        CFDictionaryGetKeysAndValues(wm_global_callbacks, NULL, (const void **)callbacks);
        for (uint i = 0; i < count; i++) {
            dispatch_block_t callback = (__bridge dispatch_block_t)callbacks[i];
            assert(callback != nil);
            callback();
        }
    });
}
+ (NSString *)registerTimerCallback:(dispatch_block_t)callback{
    NSString *key = [NSString stringWithFormat:@"%.2f" , [[NSDate date] timeIntervalSince1970]];
    [self registerTimerCallback:callback key:key];
    return key;
}
+ (void)registerTimerCallback: (dispatch_block_t)callback key:(NSString *)key{
    if (!callback || !key) return;
    __WMInitGlobalCallbacks();
    __WMASyncExecute(^{
        CFDictionarySetValue(wm_global_callbacks, (__bridge void *)key, (__bridge void *)callback);
        __WMAutoSwitchTimer();
    });
}
+ (void)resignTimerCallbackWithKey:(NSString *)key{
    if (key == nil) return;
    __WMInitGlobalCallbacks();
    __WMASyncExecute(^{
        CFDictionaryRemoveValue(wm_global_callbacks, (__bridge void *)key);
        __WMAutoSwitchTimer();
    });
}
@end
