//
//  WMAPMHttpModel.h
//  Pleasure
//
//  Created by Sper on 2018/4/16.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMAPMHttpModel : NSObject
@property (nonatomic,copy  ,readonly) NSURL     *url;
@property (nonatomic,copy  ,readonly) NSString  *method;
@property (nonatomic,assign,readonly) NSInteger statusCode;
@property (nonatomic,strong,readonly) NSData    *requestBody;
@property (nonatomic,copy  ,readonly) NSData    *responseData;
@property (nonatomic,assign,readonly) BOOL      isImage;
@property (nonatomic,copy  ,readonly) NSString  *mineType;
@property (nonatomic,copy  ,readonly) NSString  *startTime;
/// 单位 ms
@property (nonatomic,copy  ,readonly) NSString  *totalDuration;
/// 单位 KB
@property (nonatomic,copy  ,readonly) NSString  *totalLength;
+ (instancetype)httpModelWithURLRequest:(NSURLRequest *)urlRequest urlResponse:(NSHTTPURLResponse *)urlResponse responseData:(NSData *)responseData;
- (void)dealWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;
@end
