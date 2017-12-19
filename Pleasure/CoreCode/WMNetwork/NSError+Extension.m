//
//  NSError+Extension.m
//  Pleasure
//
//  Created by Sper on 2017/12/19.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "NSError+Extension.h"

@implementation NSError (Extension)
#pragma mark - 处理请求失败信息
+ (NSError *)getError:(NSError *)error resp:(NSHTTPURLResponse *)resp {
    
    NSDictionary *dict;
    if (error.userInfo[@"NSUnderlyingError"]) {
        NSError *errors = error.userInfo[@"NSUnderlyingError"];
        dict = errors.userInfo;
    }else {
        dict = error.userInfo;
    }
    NSString *errorInfo = [[NSString alloc] initWithData:dict[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
    return [[NSError alloc]initWithDomain:[self erroInfo:errorInfo statusCode:resp.statusCode] code:resp.statusCode userInfo:nil];
}

+ (NSString *)erroInfo:(NSString *)erroInfo statusCode:(NSInteger)statusCode{
    if(statusCode == 401 || [erroInfo rangeOfString:@"HTTP Status 401"].length){
        erroInfo = @"请重新登录";
    }
    if ([erroInfo rangeOfString:@"<html>"].location != NSNotFound){
        erroInfo = @"服务器异常，请稍后再试";
    }
    if (!statusCode){
        erroInfo = @"亲,你的网络好像有问题哦~";
    }
    return erroInfo;
}
@end
