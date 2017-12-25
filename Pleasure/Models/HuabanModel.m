//
//  HuabanModel.m
//  仿花瓣
//
//  Created by Sper on 16/8/12.
//  Copyright © 2016年 WM. All rights reserved.
//

#import "HuabanModel.h"
static NSString * baseImage = @"http://img.hb.aicdn.com/";
static NSString * baseFile =  @"http://hbfile.b0.upaiyun.com/";
static NSString * baseTopic = @"http://hb-topic-img.b0.upaiyun.com/";

@implementation HuabanModel

+ (NSDictionary *)modelPropertyMapper{
    return @{};
}
+ (NSDictionary *)modelClassMapper{
    return @{@"file" :[File class],
             @"user" : [User class],
             @"board": [Board class]};
}

@end

@implementation File
+ (NSDictionary *)modelPropertyMapper{
    return @{@"bucket":@"bucket",
             @"key":@"key",
             @"realImageKey":@"realImageKey"};
}

- (NSString *)realImageKey{
    if (self.key != nil) {
        if (self.bucket != nil) {
            if ([self.bucket isEqualToString:@"hb-topic-img"]){
                return [NSString stringWithFormat:@"%@%@",baseTopic,self.key];
            }else if ([self.bucket isEqualToString:@"hbfile"]){
                return [NSString stringWithFormat:@"%@%@",baseFile,self.key];
            }else {
                return [NSString stringWithFormat:@"%@%@",baseImage,self.key];
            }
        } else {
            return [NSString stringWithFormat:@"%@%@",baseImage,self.key];
        }
    } else {
        return @"";
    }
}
@end

@implementation User
@end
@implementation Board
@end
