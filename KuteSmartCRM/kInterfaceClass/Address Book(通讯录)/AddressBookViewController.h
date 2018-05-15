//
//  AddressBookViewController.h
//  KuteSmartCRM
//
//  Created by mac pro on 2018/3/23.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_BasicViewController.h"

@interface AddressBookViewController : K_BasicViewController
@property (nonatomic,strong)NSString *orgId;
/**
 是否是push过来的
 */
@property (nonatomic, assign) BOOL isPushed;
@end
