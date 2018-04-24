//
//  K_GlobalUtil.h
//  KuteSmartCRM
//
//  Created by Fenly on 2018/4/24.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface K_GlobalUtil : NSObject

//显示toast
+ (MBProgressHUD*)HUDShowMessage:(NSString*)msg addedToView:(UIView*)view;

+ (MBProgressHUD*)HUDShowMessage:(NSString*)msg yOffset:(CGFloat)yOffset addedToView:(UIView*)view;

+ (MBProgressHUD*)HUDShowTitle:(NSString*)title message:(NSString*)msg addedToView:(UIView*)view;


@end
