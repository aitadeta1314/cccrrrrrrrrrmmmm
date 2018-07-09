//
//  K_RecordEventInfoViewController.h
//  KuteSmartCRM
//
//  Created by Fenly on 2018/6/25.
//  Copyright © 2018年 redcollar. All rights reserved.
//  事件上报 / 事件处理

#import "K_BasicViewController.h"

@interface K_RecordEventInfoViewController : K_BasicViewController

/**
 位置坐标
 */
@property (nonatomic, assign) CLLocationCoordinate2D location;


/**
 是否是事件处理
 */
@property (nonatomic, assign) BOOL isEventDispose;

/**
 数据字典
 */
@property (nonatomic, strong) NSDictionary *eventData;

@end
