//
//  processingTime.m
//  CTM
//
//  Created by Sheffi on 16/10/17.
//  Copyright © 2016年 青岛晨之晖信息服务有限公司. All rights reserved.
//

#import "processingTime.h"

@implementation processingTime
//NSDate转时间戳
+(NSString *)timeStampWithDate:(NSDate *)date{
    NSString *timeStamp = [NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];
    return timeStamp;
}
//时间戳转换为时间方法
+(NSString *)dateStringWithTimeStamp:(NSString *)timeStamp andFormatString:(NSString *)formatString{
    NSString *dateString;
    NSDate *tmpDate = [NSDate dateWithTimeIntervalSince1970:[timeStamp floatValue]];
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:formatString];
    dateString = [format stringFromDate:tmpDate];
    return dateString;
}
//格式化NSDate
+(NSString *)dateStringWithDate:(NSDate *)date andFormatString:(NSString *)formatString{

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSLog(@"dateString:%@",dateString);
    return dateString;
}
//获取当前时间并进行格式化
+(NSString *)getCurrentDateWithFormatString:(NSString *)formatString{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSString *currentDateString = [self dateStringWithDate:currentDate andFormatString:formatString];
    return currentDateString;
}
//将时间字符串转换成NSDate格式
+(NSDate *)dateWithDateString:(NSString *)dateString andFormatString:(NSString *)formatString{
    NSDate *tmpDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    tmpDate = [dateFormatter dateFromString:dateString];
    return tmpDate;
}
//将时间字符串转换成时间戳
+(NSString *)timeStampWithDateString:(NSString *)dateString andFormatString:(NSString *)formatString
{
    NSDate * date = [self dateWithDateString:dateString andFormatString:formatString];
    NSString * stampString = [self timeStampWithDate:date];
    return stampString;
}
@end
