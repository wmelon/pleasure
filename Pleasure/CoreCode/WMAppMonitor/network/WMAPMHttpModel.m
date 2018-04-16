//
//  WMAPMHttpModel.m
//  Pleasure
//
//  Created by Sper on 2018/4/16.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMAPMHttpModel.h"

@implementation WMAPMHttpModel
+ (instancetype)httpModelWithURLRequest:(NSURLRequest *)urlRequest urlResponse:(NSHTTPURLResponse *)urlResponse responseData:(NSData *)responseData{
    return [[WMAPMHttpModel alloc] initWithURLRequest:urlRequest urlResponse:urlResponse responseData:responseData];
}
- (instancetype)initWithURLRequest:(NSURLRequest *)urlRequest urlResponse:(NSHTTPURLResponse *)urlResponse responseData:(NSData *)responseData{
    if (self = [super init]){
        _url = urlRequest.URL;
        _method = urlRequest.HTTPMethod;
//        _requestBody = urlRequest.HTTPBody;
        _mineType = urlResponse.MIMEType;
        _statusCode = urlResponse.statusCode;
        _responseData = responseData;
        _isImage = [urlResponse.MIMEType rangeOfString:@"image"].location != NSNotFound;
        _totalLength = [NSString stringWithFormat:@"%.2f KB",responseData.length / 1024.0];
    }
    return self;
}
- (void)dealWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime{
    NSTimeInterval time = endTime - startTime;
    NSTimeInterval timeInterval = startTime;//获取需要转换的timeinterval
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM-dd HH:mm:ss";
    _startTime = [formatter stringFromDate:date];
    _totalDuration = [NSString stringWithFormat:@"%.2f ms",time * 1000];
}
@end
