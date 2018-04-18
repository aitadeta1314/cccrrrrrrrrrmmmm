//
//  UIViewController+NavigationBar.h
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/22.
//  Copyright © 2018年 red. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (NavigationBar)

//自定义返回按
- (void)addBackButton;
- (void)backButtonPressed;
//自定义导航栏左侧按钮
- (void)addLeftButtonWithTitle:(NSString *)title;
- (void)addLeftButtonWithImage:(NSString *)imagename;
- (void)changeLeftButtonTile:(NSString *)title;
//移除导航栏左侧按钮
-(void)removeLeftBtn;
//自定义导航栏左侧按钮点击方法
-(void)leftButtonPress;

//自定义导航栏右侧按钮
- (void)addRightButtonWithTitle:(NSString *)title;
- (void)addRightButtonWithImage:(NSString *)imagename;
- (void)changeRightButtonTile:(NSString *)title;
//移除导航栏右侧按钮
-(void)removeRightBtn;
//自定义导航栏右侧按钮点击方法
-(void)rightButtonPress;

@end
