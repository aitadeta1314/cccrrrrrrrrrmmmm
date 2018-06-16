//
//  K_ChangePasswordViewController.m
//  KuteSmartCRM
//
//  Created by Fenly on 2017/5/18.
//  Copyright © 2017年 redcollar. All rights reserved.
//

#import "K_ChangePasswordViewController.h"

@interface K_ChangePasswordViewController ()<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordNewTF;
@property (weak, nonatomic) IBOutlet UITextField *sureNewTF;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;

/**
 *  指示器
 */
@property (nonatomic, strong) UIActivityIndicatorView *activitIndicatorView;

@end

@implementation K_ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.shadowImage = nil;// 导航栏下面的黑线显示
    
    self.navigationItem.title = @"修改密码";
    [self addBackButton];
    
    [self defineNavBar];
    
    [self configureInterface];
}

- (void)configureInterface {
    self.sureButton.layer.cornerRadius = 5;
    
    self.oldPasswordTF.secureTextEntry = YES;
    self.oldPasswordTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.oldPasswordTF.delegate = self;
    
    self.passwordNewTF.secureTextEntry = YES;
    self.passwordNewTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordNewTF.delegate = self;
    
    self.sureNewTF.secureTextEntry = YES;
    self.sureNewTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.sureNewTF.delegate = self;
    
    // 指示器
    _activitIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    if (UI_IS_IPHONE5) {
        _activitIndicatorView.center = CGPointMake(CGRectGetWidth(self.sureButton.frame)/2-55, 20);
    }
    if (UI_IS_IPHONE6) {
        _activitIndicatorView.center = CGPointMake(CGRectGetWidth(self.sureButton.frame)/2-30, 20);
    }
    if (UI_IS_IPHONE6P) {
        _activitIndicatorView.center = CGPointMake(CGRectGetWidth(self.sureButton.frame)/2-10, 20);
    }
    
    [self.sureButton addSubview:_activitIndicatorView];
}

// 自定义导航栏
- (void)defineNavBar {
    
//    UIButton * leftItemBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
//    [leftItemBtn addTarget:self action:@selector(goLeft) forControlEvents:UIControlEventTouchUpInside];
//    [leftItemBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftItemBtn];
    
    // 设置自定义返回按钮 左滑返回失效问题
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}


- (void)goLeft {
    [self.navigationController popViewControllerAnimated:YES];
}

/** 确定点击*/
- (IBAction)sureClick:(UIButton *)sender {
    [self.view endEditing:YES];
    
    if ([self.oldPasswordTF.text isEqualToString:@""]) {
        [K_GlobalUtil HUDShowMessage:@"请输入旧密码" addedToView:SharedAppDelegate.window];
        return;
    }
    if ([self.oldPasswordTF.text isEqualToString:self.passwordNewTF.text]) {
        [K_GlobalUtil HUDShowMessage:@"请更新您的密码" addedToView:SharedAppDelegate.window];
        return;
    }
    if ([self.passwordNewTF.text isEqualToString:self.sureNewTF.text]) {
        // 新密码tf  确认新密码tf 相同
        if (self.passwordNewTF.text.length >= 6 && self.passwordNewTF.text.length <= 15) {
            // 校验密码
            [K_NetWorkClient modifyPasswordNewPassword:self.passwordNewTF.text oldPassword:self.oldPasswordTF.text success:^(id response) {
                
                NSLog(@"modifyPassword ' response :%@", response);

                NSDictionary *data = response[@"data"];
                
                NSString *result_flag = data[@"result_flag"];
                NSString *result_message = data[@"result_message"];
                NSLog(@"result_message:%@",result_message);
                if ([result_flag isEqualToString:@"Y"]) {
                    // 成功
                    [SAMKeychain setPassword:self.passwordNewTF.text forService:ServiceName account:KUSERNAME];
                    [K_GlobalUtil HUDShowMessage:@"修改成功" addedToView:SharedAppDelegate.window];
                    [self goLeft];
                } else {
                    
                    [K_GlobalUtil HUDShowMessage:@"修改失败" addedToView:SharedAppDelegate.window];
                }
                
                
            } failure:^(NSError *error) {
                [K_GlobalUtil HUDShowMessage:@"请检查您的网络" addedToView:SharedAppDelegate.window];
            }];
        }
        else {
            // 密码格式不正确
            [K_GlobalUtil HUDShowMessage:@"请输入6-15位新密码" addedToView:SharedAppDelegate.window];
        }
    }
    else {
        
        // 确认密码不相同
        [K_GlobalUtil HUDShowMessage:@"请输入相同的新密码" addedToView:SharedAppDelegate.window];
        return;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sureClick:self.sureButton];
    return YES;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.oldPasswordTF resignFirstResponder];
    [self.passwordNewTF resignFirstResponder];
    [self.sureNewTF resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    /** 触摸释放第一响应者*/
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
