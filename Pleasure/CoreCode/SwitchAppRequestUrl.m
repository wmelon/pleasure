//
//  SwitchAppRequestUrl.m
//  PumpkinCar
//
//  Created by Sper on 16/8/5.
//  Copyright © 2016年 mrocker. All rights reserved.
//

#import "SwitchAppRequestUrl.h"

/// 存储切换网络请求的key值
#define kUrlStringCache [NSString stringWithFormat:@"KBaseTestURL%@" , AppVersion]

@implementation SwitchAppRequestUrl

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static SwitchAppRequestUrl * instance;
    dispatch_once(&onceToken, ^{
        instance = [SwitchAppRequestUrl new];
    });
    return instance;
}

/// 缓存上次切换的url地址
- (void)setUrlString:(NSString *)urlString{
    [[NSUserDefaults standardUserDefaults] setObject:urlString forKey:kUrlStringCache];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setAllowHttps:(BOOL)allowHttps{
    [[NSUserDefaults standardUserDefaults] setObject:@(allowHttps) forKey:@"allowHttps"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSString *)urlString{
    /// 不是测试环境就直接返回线上的接口环境
    if (![WMUtility isTestBundleIdentifier]){
        return KBaseURL;
    }
    NSString * testUrl = [[NSUserDefaults standardUserDefaults] objectForKey:kUrlStringCache];
    if (!testUrl || [testUrl isEqualToString:@""]){
        testUrl = [self changeBaseURL:KBaseURL onLine:NO allowHttps:YES];
        [self setUrlString:testUrl];
    }
    return testUrl;
}
- (BOOL)allowHttps{
    NSNumber * number = [[NSUserDefaults standardUserDefaults] objectForKey:@"allowHttps"];
    if (number){
        return [number boolValue];
    }
    return NO;
}

#pragma mark -- api请求地址切换处理
- (NSString *)changeBaseUrl:(NSString *)baseUrl allowHttps:(BOOL)allowHttps{
    [self setAllowHttps:allowHttps];
    
    /// 需要同时检测 http 和 是否线上地址
    baseUrl = [self httpOrHttpsUrlString:baseUrl];
    return baseUrl;
}
- (NSString *)changeBaseURL:(NSString *)baseURL onLine:(BOOL)onLine allowHttps:(BOOL)allowHttps{
    [self setAllowHttps:allowHttps];
    
    /// 需要同时检测 http 和 是否线上地址
    baseURL = [self httpOrHttpsUrlString:baseURL];
    baseURL = [self onLineOrOffLineUrlString:baseURL onLine:onLine];
    
    return baseURL;
}

/// check 请求地址是线上 还是 测试环境
- (NSString *)onLineOrOffLineUrlString:(NSString *)urlString onLine:(BOOL)onLine{
    NSRange range = [urlString rangeOfString:@"://"];
    NSString * str1 = [urlString substringToIndex:range.location];
    NSString * str2 = [urlString substringFromIndex:range.location + range.length];
    
    NSMutableString * BaseURLString = [NSMutableString string];
    if (onLine){
        [BaseURLString appendFormat:@"%@" , urlString];
    }else {
        if ([urlString rangeOfString:@"://test."].location == NSNotFound){
            [BaseURLString appendFormat:@"%@://test.%@" , str1 , str2];
        }else {
            [BaseURLString appendFormat:@"%@://%@" , str1 , str2];
        }
    }
    return BaseURLString;
}

#pragma mark -- webView请求地址处理

- (NSURL *)webViewUrlWithId:(id)url{
    return [self imageUrlWithId:url];
}

#pragma mark -- 图片地址处理
- (NSURL *)imageUrlWithId:(id)url{
    
    if (url == (id)kCFNull || url == nil) return nil;
    
    NSURL * imageUrl;
    if ([url isKindOfClass:[NSString class]]){
        if ([url isEqualToString:@""]){
            return nil;
        }
        imageUrl = [NSURL URLWithString:[self realUrlWithUrlString:url]];
        
    }else if ([url isKindOfClass:[NSURL class]]){
        /// 处理包含中文编码
        imageUrl = [NSURL URLWithString:[self realUrlWithUrlString:[NSString stringWithFormat:@"%@" , url]]];
    }
    return imageUrl;
}

- (NSString *)realUrlWithUrlString:(NSString *)urlString{
    /// 处理地址中包含中文编码
    urlString = [self UTF8StringWithString:urlString];
    if ([self isValidUrl:urlString]){
        return [self httpOrHttpsUrlString:urlString];
    }else {
        /// 这边处理图片id为 图片拼接正确的地址
        NSString * baseUrl = [self httpOrHttpsUrlString:KBaseURL];
        return [NSString stringWithFormat:@"%@%@%@",baseUrl,@"/api/pub/img/",urlString];
    }
}
/**
 * 字符串UTF8编码
 */
- (NSString *)UTF8StringWithString:(NSString *)string {
    /// 已经经过编码的地址不再二次编码
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                    (CFStringRef)string,
                                                                                                    (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                                                                    NULL,
                                                                                                    kCFStringEncodingUTF8));
    return encodedString;
}
/// 判断字符串是否是url
- (BOOL)isValidUrl:(NSString *)urlString{
    NSString *regex =@"[a-zA-z]+://[^\\s]*";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [urlTest evaluateWithObject:urlString];
}
/// check 请求地址是使用 http 还是 https
- (NSString *)httpOrHttpsUrlString:(NSString *)urlString{
    NSMutableString * BaseURLString = [NSMutableString stringWithString:urlString];
    
    NSRange httpsRange = [BaseURLString rangeOfString:@"https://"];
    NSRange httpRange = [BaseURLString rangeOfString:@"http://"];
    
    if (httpsRange.location != NSNotFound){
        if (!self.allowHttps){
            [BaseURLString replaceCharactersInRange:httpsRange withString:@"http://"];
        }
    }else if (httpRange.location != NSNotFound){
        if (self.allowHttps){
            [BaseURLString replaceCharactersInRange:httpRange withString:@"https://"];
        }
    }
    
    return BaseURLString;
}
@end
