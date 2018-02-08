//
//  WMDeviceUsageMonitor.m
//  Pleasure
//
//  Created by Sper on 2018/2/8.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMDeviceUsageMonitor.h"
#import <QuartzCore/QuartzCore.h>
#import <sys/sysctl.h>
#import <mach/mach.h>

@implementation WMDeviceInfo
+ (instancetype)deviceInfoWithFps:(NSInteger)fps cpu:(CGFloat)cpu curMemUsage:(double)curMemUsage freeMemory:(double)freeMemory{
    WMDeviceInfo *info = [[WMDeviceInfo alloc] init];
    info.cpu = cpu;
    info.fps = fps;
    info.curMemUsage = curMemUsage;
    info.freeMemory = freeMemory;
    return info;
}
@end

@interface WMDeviceUsageMonitor()
@property (nonatomic, strong) CADisplayLink *displayLink;
/// 屏幕渲染开始时间
@property (nonatomic, assign) CFTimeInterval screenUpdatesBeginTime;
/// 屏幕平均渲染指数
@property (nonatomic, assign) CFTimeInterval averageScreenUpdatesTime;
/// 屏幕刷新次数值
@property (nonatomic, assign) CFTimeInterval screenUpdatesCount;
/// 获取设备信息回调
@property (nonatomic, copy  ) WMDeviceUsageHandle deviceHandle;
@end

@implementation WMDeviceUsageMonitor
+ (instancetype)shareDeviceUsage{
    static WMDeviceUsageMonitor *object;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object = [[WMDeviceUsageMonitor alloc] init];
    });
    return object;
}
- (instancetype) init{
    if (self = [super init]){
        self.screenUpdatesBeginTime = 0.0;
        self.averageScreenUpdatesTime = 0.017f;
        self.screenUpdatesCount = 0;
        [self setupDisplayLink];
    }
    return self;
}
#pragma mark -- private method
- (void)setupDisplayLink{
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tickDisplayLink:)];
    //  uiscrollerView   滚动视图的mode 是 UITrackingRunLoopMode 为了保证视图流畅性，因为timer的model是NSDefaultRunLoopMode会被停止
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
- (void)tickDisplayLink:(CADisplayLink *)displayLink{
    if (self.screenUpdatesBeginTime == 0){
        self.screenUpdatesBeginTime = displayLink.timestamp;
    }else {
        self.screenUpdatesCount += 1;
        CFTimeInterval screenUpdatesTime = displayLink.timestamp - self.screenUpdatesBeginTime;
        if (screenUpdatesTime >= 1.0){
            CFTimeInterval updatesOverSecond = screenUpdatesTime - 1.0f;
            int framesOverSecond = updatesOverSecond / self.averageScreenUpdatesTime;
            
            self.screenUpdatesCount -= framesOverSecond;
            if (self.screenUpdatesCount < 0) {
                self.screenUpdatesCount = 0;
            }
            
            [self takeReadings];
        }
    }
}
- (void)takeReadings{
    int fps = self.screenUpdatesCount;
    float cpu = [self cpuUsage];
    double curMemUsage = [self usedMemory];
    double freeMemory = [self availableMemory];
    
    self.screenUpdatesCount = 0;
    self.screenUpdatesBeginTime = 0.0f;
    if (self.deviceHandle){
        WMDeviceInfo *info = [WMDeviceInfo deviceInfoWithFps:fps cpu:cpu curMemUsage:curMemUsage freeMemory:freeMemory];
        self.deviceHandle(info);
    }
}
/**
 *  空闲内存
 *
 *  @return 空闲内存。 单位bytes
 */
//获取当前设备可用内存
- (double)availableMemory{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    return ((vm_page_size * vmStats.free_count)/1024.0)/1024.0;
}

/**
 *  已使用内存
 *
 *  @return 已使用内存。 单位bytes
 */

- (double)usedMemory{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    return taskInfo.resident_size/1024.0/1024.0;
}
/**
 *  获取cpu
 *
 *  @return cpu 使用率
 */
- (float)cpuUsage {
    kern_return_t kern;
    
    thread_array_t threadList;
    mach_msg_type_number_t threadCount;
    
    thread_info_data_t threadInfo;
    mach_msg_type_number_t threadInfoCount;
    
    thread_basic_info_t threadBasicInfo;
    uint32_t threadStatistic = 0;
    
    kern = task_threads(mach_task_self(), &threadList, &threadCount);
    if (kern != KERN_SUCCESS) {
        return -1;
    }
    if (threadCount > 0) {
        threadStatistic += threadCount;
    }
    
    float totalUsageOfCPU = 0;
    
    for (int i = 0; i < threadCount; i++) {
        threadInfoCount = THREAD_INFO_MAX;
        kern = thread_info(threadList[i], THREAD_BASIC_INFO, (thread_info_t)threadInfo, &threadInfoCount);
        if (kern != KERN_SUCCESS) {
            return -1;
        }
        
        threadBasicInfo = (thread_basic_info_t)threadInfo;
        
        if (!(threadBasicInfo -> flags & TH_FLAGS_IDLE)) {
            totalUsageOfCPU = totalUsageOfCPU + threadBasicInfo -> cpu_usage / (float)TH_USAGE_SCALE * 100.0f;
        }
    }
    
    kern = vm_deallocate(mach_task_self(), (vm_offset_t)threadList, threadCount * sizeof(thread_t));
    
    return totalUsageOfCPU;
}
#pragma mark -- publick method
- (void)startDeviceUsage:(WMDeviceUsageHandle)deviceHandle{
    _deviceHandle = deviceHandle;
    if (_displayLink){
        [self.displayLink setPaused:NO];
    }
}
- (void)stopDeviceUsage{
    if (_displayLink){
        [self.displayLink setPaused:YES];
    }
}
- (void)dealloc{
    [_displayLink invalidate];
    _displayLink = nil;
    NSLog(@"timer release");
}
@end
