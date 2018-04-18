//
//  UIViewController+NavigationBar.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/22.
//  Copyright © 2018年 red. All rights reserved.
//

#import "UIViewController+NavigationBar.h"

@implementation UIViewController (NavigationBar)


- (void)addBackButton
{
    UIImage *image = [UIImage imageNamed:@"icon_back"];
    CGRect buttonFrame = CGRectMake(0, 0, 80, 44);
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = item;
}

-(void)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addLeftButtonWithTitle:(NSString *)title
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(leftButtonPress) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = item;
}

-(void)addLeftButtonWithImage:(NSString *)imagename
{
    UIImage *image = [UIImage imageNamed:imagename];
    CGRect buttonFrame = CGRectMake(0, 0, 20, 20*image.size.height/image.size.width);
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button addTarget:self action:@selector(leftButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = item;
}

-(void)changeLeftButtonTile:(NSString *)title
{
    [self removeLeftBtn];
    [self addLeftButtonWithTitle:title];
}

-(void)removeLeftBtn
{
    self.navigationItem.leftBarButtonItem = nil;
}

-(void)leftButtonPress
{
    
}

-(void)addRightButtonWithTitle:(NSString *)title
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightButtonPress) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
}

-(void)addRightButtonWithImage:(NSString *)imagename
{
    UIImage *image = [UIImage imageNamed:imagename];
    CGRect buttonFrame = CGRectMake(0, 0, 20, 20*image.size.height/image.size.width);
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button addTarget:self action:@selector(rightButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
}

-(void)changeRightButtonTile:(NSString *)title
{
    [self removeRightBtn];
    [self addRightButtonWithTitle:title];
}

-(void)removeRightBtn
{
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)rightButtonPress
{
    
}

@end
