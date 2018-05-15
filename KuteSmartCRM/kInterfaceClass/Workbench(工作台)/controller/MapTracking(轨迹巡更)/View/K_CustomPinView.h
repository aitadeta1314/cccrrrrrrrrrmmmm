//
//  K_CustomPinView.h
//  KuteSmartCRM
//
//  Created by Fenly on 2018/5/10.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface K_CustomPinView : MAAnnotationView

/**
 人员姓名
 */
@property (nonatomic,copy) NSString *name;
/**
 人员头像 url
 */
@property (nonatomic, copy) NSString *portraitUrl;
/**
 callout 弹出气泡
 */
@property (nonatomic, strong) UIView *calloutView;


@end
