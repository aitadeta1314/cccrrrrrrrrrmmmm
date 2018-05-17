//
//  AppDelegate.h
//  KuteSmartCRM
//
//  Created by kutesmart on 2017/5/6.
//  Copyright © 2017年 redcollar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 开启定位 定时器
 */
- (void)openTimer;
/**
 销毁定时器（退出登录，token有效期过期需要重新登录 etc.）
 */
- (void)invalidateTimer;



@end

