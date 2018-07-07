//
//  K_CustomPinView.h
//  KuteSmartCRM
//
//  Created by Fenly on 2018/5/10.
//  Copyright © 2018年 redcollar. All rights reserved.
//  显示保安大头针

#import <MAMapKit/MAMapKit.h>

/**
 点击了某个大头针view
 */
typedef void(^ClickCustomPinView)(CLLocationCoordinate2D coordinate, NSString *name);

@interface K_CustomPinView : MAAnnotationView

/**
 点击某个大头针弹出气泡
 */
@property (nonatomic, copy) ClickCustomPinView clickCustomPinView;
/**
 人员姓名
 */
@property (nonatomic,copy) NSString *name;
/**
 人员工号
 */
@property (nonatomic,copy) NSString *employeeNumber;
/**
 人员头像 url
 */
@property (nonatomic, copy) NSString *portraitUrl;
/**
 callout 弹出气泡
 */
@property (nonatomic, strong) UIView *calloutView;


@end
