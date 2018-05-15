//
//  NSObject+WN_Extension.m
//  Wanna
//
//  Created by X-Liang on 16/6/20.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "NSObject+WN_Extension.h"

@implementation NSObject (WN_Extension)

- (BOOL)isValidObject {
    return ![self isKindOfClass:[NSNull class]] && self != nil;
}

@end
