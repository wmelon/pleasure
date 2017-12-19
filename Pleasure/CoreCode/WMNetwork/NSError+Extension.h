//
//  NSError+Extension.h
//  Pleasure
//
//  Created by Sper on 2017/12/19.
//  Copyright © 2017年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Extension)
+ (NSError *)getError:(NSError *)error resp:(NSHTTPURLResponse *)resp;
@end
