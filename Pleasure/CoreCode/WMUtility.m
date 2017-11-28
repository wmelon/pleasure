//
//  WMUtility.m
//  Pleasure
//
//  Created by Sper on 2017/11/28.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMUtility.h"

@implementation WMUtility
/// 通过图片获取base64字符
+ (void)Base64ImageStrWithImages:(NSArray *)images complete:(void(^)(NSArray *imageIds))complete{
    dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    /// 将传入的图片转换为字符串
    NSMutableArray<NSString *> *selectedImageStr = [NSMutableArray array];
    dispatch_async(queue, ^{
        NSMutableString * imageMuStr;
        for (int i = 0 ; i < images.count ; i++){
            /// 三张一起上传
            if (i % 3 == 0){
                imageMuStr = [NSMutableString string];
            }
            UIImage * image = images[i];
            if ([image isKindOfClass:[UIImage class]]){
                [self PhotoshopImageWithImage:image imageStr:imageMuStr];
            }
            if ((i % 3 == 2) || (i == images.count - 1)){
                [selectedImageStr addObject:imageMuStr];
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (selectedImageStr.count){
                NSMutableArray *imageIds = [NSMutableArray arrayWithCapacity:selectedImageStr.count];
                [self uploadImage:selectedImageStr beforeIndex:0 imageIds:imageIds complete:^() {
                    if (complete){
                        complete(imageIds);
                    }
                }];
            }else if (complete){
                complete(nil);
            }
        });
    });
}
+ (void)PhotoshopImageWithImage:(UIImage *)oldImage imageStr:(NSMutableString *)imageStr{
    NSString *encodedImageStr = [[self imageData:oldImage withDataLength:250] base64EncodedStringWithOptions:0];
    NSString * str = [NSString stringWithFormat:@"%@,",[self encodedImageStr:encodedImageStr]];
    [imageStr appendString:str];
}
+ (NSString *)encodedImageStr:(NSString *)string{
    return (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                  (CFStringRef)string,
                                                                                  NULL,
                                                                                  CFSTR(":/?#[]@!$&’()*+,;="),
                                                                                  kCFStringEncodingUTF8);
}
#pragma mark -- 递归上传图片，3张一次上传
+ (void)uploadImage:(NSArray<NSString *> *)imageStrArray beforeIndex:(NSInteger)beforeIndex imageIds:(NSMutableArray *)imageIds complete:(void(^)(void))complete {
    __block NSInteger index = beforeIndex;
    NSString * imageStr;
    if (index < imageStrArray.count){
        imageStr = imageStrArray[index];
    }
    if (imageStr && ![imageStr isEqualToString:[NSMutableString string]]){
         //图片上传
        WMRequestAdapter *request = [WMRequestAdapter requestWithUrl:@"" requestMethod:(WMRequestMethodPOST)];
        [request requestParameterSetValue:imageStr forKey:@"bin"];
        
        [WMRequestManager requestWithSuccessHandler:^(WMRequestAdapter *request) {
            NSArray *ids = request.responseDictionary[@"data"][@"imgIds"];
            if (ids.count){
                [imageIds addObjectsFromArray:ids];
            }
            /// 递归上传图片
            [self uploadImage:imageStrArray beforeIndex:++index imageIds:imageIds complete:complete];

        } progressHandler:nil failureHandler:^(WMRequestAdapter *request) {
            if (complete){
                complete();
            }
        } requestAdapter:request];
        
    }else {
        if (complete){
            complete();
        }
    }
}
+ (NSData *)imageData:(UIImage *)image withDataLength:(NSInteger)length{
#ifdef DEBUG
    NSLog(@"图片压缩前的大小为 %zdkb" , [UIImageJPEGRepresentation(image, 1.0) length]/1024);
#endif
    if (length > 200 || length < 100){
        length = 200;
    }
    /// 图片按照指定的尺寸裁剪
    image = [UIImage scaleAndRotateImage:image resolution:800];
    NSData *imageData;
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    do {
        imageData = UIImageJPEGRepresentation(image, compression);
        compression -= 0.1;
#ifdef DEBUG
        NSLog(@"压缩后图片的大小为 %zdkb" , [imageData length]/1024);
#endif
    } while ([imageData length] > length * 1024 && compression > maxCompression);
    return imageData;
}
@end
