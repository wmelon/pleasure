//
//  SwitchAppRequestUrl.h
//  PumpkinCar
//
//  Created by Sper on 16/8/5.
//  Copyright © 2016年 mrocker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwitchAppRequestUrl : NSObject
@property (nonatomic , strong , readonly) NSString *urlString;
/// 是否允许https请求
@property (nonatomic , assign , readonly) BOOL allowHttps;

+ (instancetype)shareInstance;

/// 控制面板控制切换网路请求地址
- (NSString *)changeBaseURL:(NSString *)baseURL onLine:(BOOL)onLine allowHttps:(BOOL)allowHttps;

- (NSString *)changeBaseUrl:(NSString *)baseUrl allowHttps:(BOOL)allowHttps;

/// 网页地址处理
- (NSURL *)webViewUrlWithId:(id)url;

/// 处理图片地址（可以传入id类型  和 string 和 url）
// @return 完整的图片url
- (NSURL *)imageUrlWithId:(id)url;


@end
