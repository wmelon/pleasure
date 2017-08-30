//
//  WMSwizzleMethod.h
//  ins
//
//  Created by Sper on 16/10/27.
//  Copyright © 2016年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void WMSwizzleMethod(Class cls, SEL originalSelector, SEL swizzledSelector);
