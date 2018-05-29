//
//  NSString+WN_StringTools.h
//  Wanna
//
//  Created by X-Liang on 16/1/11.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

/**
 *  判断某个字符串是否是有效的字符串(不为空, 长度>0)
 *
 *  @return 判断结果
 */
- (BOOL)isValidString;

/**
 判断某个字符串是否是有效的字符串（主要处理字符串为NSNull的情况）

 @param str 需要判断的字符串
 @return 判断结果，为空返回YES, 否则返回NO
 */
+ (BOOL)isBlankString:(NSString *)str;

/**
 * 将传入的 Objective-C 字典转为 JSon 形式的字典
 */
+ (NSString *)dicToJsonStr:(NSDictionary *)param;

/**
 * 判断是否是iTunes URL
 */
- (BOOL)isiTunesURL;

/// 从str中分离出数字（array）
/**
 *  @"111*(()&&&2343" -> @[111, 2343];
 */
+ (NSArray *)getOnlyNum:(NSString *)str;
/// 从str中分离出数字（string）
/**
 * @"1234" → @"1234"
 * @"001234" → @"001234"
 * @"leading text get removed 001234" → @"001234"
 * @"001234 trailing text gets removed" → @"001234"
 * @"a0b0c1d2e3f4" → @"001234"
 */
+ (NSString *)extractNumberFromText:(NSString *)text;
@end
