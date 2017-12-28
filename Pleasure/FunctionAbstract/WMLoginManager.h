//
//  WMLoginManager.h
//  Pleasure
//
//  Created by Sper on 2017/12/27.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WMLoginComplete)(void);
@class WMLoginOperation;

@interface WMLoginManager : NSObject
@property (nonatomic , copy , readonly) WMLoginComplete complete;

+ (instancetype)executeDirectlyOperationAfterLogin:(WMLoginComplete)complete;
+ (instancetype)executeOperationHasLogin:(WMLoginComplete)complete;

@end


@interface WMLoginOperation : NSObject

+ (void)addLoginOperation:(WMLoginManager *)loginManager;

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password complete:(WMLoginComplete)complete;

+ (void)loginWithPhone:(NSString *)phone code:(NSString *)code complete:(WMLoginComplete)complete;

@end
