//
//  K_PersonViewController.h
//  KuteSmartCRM
//
//  Created by mac pro on 2018/3/26.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_BasicViewController.h"

@interface K_PersonViewController : K_BasicViewController
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *phoneNum;
@property (nonatomic,copy)NSString *org;
@property (nonatomic,copy)NSString *pernr;//工号
/**
 功能（岗位）
 */
@property (nonatomic, copy) NSString *plstx;

@end
