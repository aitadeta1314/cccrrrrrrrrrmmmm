//
//  K_PendingEventPinView.h
//  KuteSmartCRM
//
//  Created by Fenly on 2018/7/7.
//  Copyright © 2018年 redcollar. All rights reserved.
//  待处理事件大头针

#import <MAMapKit/MAMapKit.h>

@interface K_PendingEventPinView : MAAnnotationView

/**
 大头针气泡
 */
@property (nonatomic, strong) UIView *calloutView;

/**
 数据字典
 */
@property (nonatomic, strong) NSDictionary *dataDic;
/**
 
 */
@property (nonatomic,copy) NSString *urgentStatus;

@end
