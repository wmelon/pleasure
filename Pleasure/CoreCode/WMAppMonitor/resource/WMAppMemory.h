//
//  WMAppMemory.h
//  Pleasure
//
//  Created by Sper on 2018/3/8.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct WMAppMemoryUsage{
    double usage;   ///< 已用内存(MB)
    double total;   ///< 总内存(MB)
    double ratio;   ///< 占用比率
}WMAppMemoryUsage;
@interface WMAppMemory : NSObject
+ (WMAppMemoryUsage)usageMemory;
@end
