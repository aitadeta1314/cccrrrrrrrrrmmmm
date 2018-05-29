//
//  NSString+WN_StringTools.m
//  Wanna
//
//  Created by X-Liang on 16/1/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (BOOL)isValidString {
    return ([self isValidObject] && self.length > 0);
}

+ (BOOL)isBlankString:(NSString *)str {
    NSString *string = str;
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    
    return NO;
}


+ (NSString *)dicToJsonStr:(NSDictionary *)param {
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

- (BOOL)isMatch:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    if (error) {
        return NO;
    }
    NSTextCheckingResult *res = [regex firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    return res != nil;
}

- (BOOL)isiTunesURL {
    return [self isMatch:@"\\/\\/itunes\\.apple\\.com\\/"];
}
+ (NSArray *)getOnlyNum:(NSString *)str {
    
    NSString *onlyNumStr = [str stringByReplacingOccurrencesOfString:@"[^0-9,]"
                                                          withString:@""
                                                             options:NSRegularExpressionSearch
                                                               range:NSMakeRange(0, [str length])];
    NSArray *numArr = [onlyNumStr componentsSeparatedByString:@""];
    return numArr;
}
+ (NSString *)extractNumberFromText:(NSString *)text
{
    NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [[text componentsSeparatedByCharactersInSet:nonDigitCharacterSet] componentsJoinedByString:@""];
}
@end
