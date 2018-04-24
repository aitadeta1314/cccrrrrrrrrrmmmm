//
//  K_GlobalUtil.m
//  KuteSmartCRM
//
//  Created by Fenly on 2018/4/24.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_GlobalUtil.h"

@implementation K_GlobalUtil

+ (MBProgressHUD*)HUDShowMessage:(NSString*)msg addedToView:(UIView*)view
{
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    HUD.labelText = msg;
    HUD.mode = MBProgressHUDModeText;
    
    //指定距离中心点的X轴和Y轴的偏移量，如果不指定则在屏幕中间显示
    //        HUD.yOffset = SCREEN_HEIGHT/2-50;
    //HUD.xOffset = 100.0f;
    [HUD show:YES];
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hide:YES afterDelay:1];
    return HUD;
}

+ (MBProgressHUD*)HUDShowMessage:(NSString*)msg yOffset:(CGFloat)yOffset addedToView:(UIView*)view
{
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    HUD.labelText = msg;
    HUD.mode = MBProgressHUDModeText;
    
    //指定距离中心点的X轴和Y轴的偏移量，如果不指定则在屏幕中间显示
    HUD.yOffset = yOffset;
    //HUD.xOffset = 100.0f;
    [HUD show:YES];
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hide:YES afterDelay:1];
    return HUD;
}


+ (MBProgressHUD*)HUDShowTitle:(NSString*)title message:(NSString*)msg addedToView:(UIView*)view
{
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    HUD.labelText = title;
    HUD.detailsLabelText = msg;
    HUD.detailsLabelFont = [UIFont boldSystemFontOfSize:16.0f];
    HUD.mode = MBProgressHUDModeText;
    
    [HUD show:YES];
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hide:YES afterDelay:1];
    return HUD;
}

@end
