//
//  CustomActionSheet.m
//  KuteSmartCRM
//
//  Created by Fenly on 2018/6/24.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "WN_CustomActionSheet.h"

#define BaseTag 900
#define BackcolorAlpha 0.7
@interface WN_CustomActionSheet ()
@property (weak, nonatomic) IBOutlet UIButton *phone;
@property (weak, nonatomic) IBOutlet UIButton *album;
@property (weak, nonatomic) IBOutlet UIButton *cancle;
@property (nonatomic, weak) UIView *backView;
@property (nonatomic, strong) UIView *bottomBackgroundWhiteView;  // 主要用于iPhone X弹出时候底部加一块白色背景。

@end

@implementation WN_CustomActionSheet

+ (instancetype)customActionSheet
{
    return [[[NSBundle mainBundle] loadNibNamed:@"WN_CustomActionSheet" owner:nil options:nil] firstObject];
}

- (IBAction)buttonClicked:(UIButton *)sender {
    [self cancleClicked:self.cancle];
    if ([self.delegate respondsToSelector:@selector(customActionSheet:didSelecetWithButtonIndex:)]) {
        [self.delegate customActionSheet:self didSelecetWithButtonIndex:sender.tag - BaseTag];
    }
}

- (void)showInView:(UIView *)view
{
    self.frame = CGRectMake(0, kDeviceHeight+self.bounds.size.height, kDeviceWidth, self.bounds.size.height);
    
    UIView *backView = [[UIView alloc] initWithFrame:view.bounds];
    backView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:BackcolorAlpha];
    self.backView = backView;
    self.backView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackView:)];
    [self.backView addGestureRecognizer:tap];
    [SharedAppDelegate.window addSubview:backView];
    
    self.bottomBackgroundWhiteView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.frame), kDeviceWidth, 30)];
    self.bottomBackgroundWhiteView.backgroundColor = UIColor.whiteColor;
    [self.backView addSubview:self.bottomBackgroundWhiteView];
    
    [self.backView addSubview:self];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         backView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:BackcolorAlpha];
                         CGRect rect;
                         if (iPhoneX) {
                             rect = CGRectMake(0, kDeviceHeight - self.bounds.size.height - 30, kDeviceWidth, self.bounds.size.height);
                         } else {
                             rect = CGRectMake(0, kDeviceHeight - self.bounds.size.height, kDeviceWidth, self.bounds.size.height);
                         }
                         self.frame = rect;
                         self.bottomBackgroundWhiteView.frame = CGRectMake(rect.origin.x, CGRectGetMaxY(rect), rect.size.width, 30);
    } completion:nil];
}

- (IBAction)cancleClicked:(UIButton *)sender {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
                         self.bottomBackgroundWhiteView.frame = CGRectMake(0, CGRectGetMaxY(self.frame), kDeviceWidth, 30);
                         self.frame = CGRectMake(0, kDeviceHeight+self.bounds.size.height, kDeviceWidth, self.bounds.size.height);
                     } completion:^(BOOL finished) {
                         [self.backView removeFromSuperview];
                         [self.bottomBackgroundWhiteView removeFromSuperview];
                         [self removeFromSuperview];
                     }];
}

- (void)tapBackView:(UITapGestureRecognizer *)tap
{
    [self cancleClicked:self.cancle];
}

@end
