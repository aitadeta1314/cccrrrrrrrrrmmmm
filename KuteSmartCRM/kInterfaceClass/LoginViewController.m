//
//  LoginViewController.m
//  KuteSmartCRM
//
//  Created by kutesmart on 2017/5/6.
//  Copyright © 2017年 redcollar. All rights reserved.
//

#import "LoginViewController.h"
#import "RSAEncryptor.h"
#import "KTabBarController.h"

@interface LoginViewController ()<UITextFieldDelegate>
/** 背景图片*/
@property (weak, nonatomic) IBOutlet UIImageView *background;
/** 用户名*/
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
/** 密码*/
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
/** 登录按钮*/
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet UIView *middleView;
/** 记住密码*/
@property (weak, nonatomic) IBOutlet UIButton *remButton;
/** 自动登录*/
@property (weak, nonatomic) IBOutlet UIButton *autoLoginButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self configureInterface];
}

- (void)configureInterface {
    
    // 需要先设置登录状态（登出为YES, 登录成功为NO）
    KLOGOUT = YES;
    
    // 用户名tf
    if (KUSERNAME) {
        self.userNameTF.text = KUSERNAME;
    }
    
    // 富文本设置placeholder
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:self.userNameTF.placeholder];
    [placeholder addAttributes:@{NSForegroundColorAttributeName:RGBA(255, 255, 255, 0.8)} range:NSMakeRange(0, placeholder.length)];
    self.userNameTF.attributedPlaceholder = placeholder;
    
    self.userNameTF.backgroundColor = FUIColorFromRGB(0x32ffffff, 0.2);
//    self.userNameTF.keyboardType = UIKeyboardTypeNumberPad;
    self.userNameTF.delegate = self;
    self.userNameTF.layer.cornerRadius = 20;
    self.userNameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.userNameTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.userNameTF.frame), CGRectGetHeight(self.userNameTF.frame))];
    self.userNameTF.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *leftImg1 = [[UIImageView alloc] initWithFrame:CGRectMake(12, 9, 22, 22)];
    [leftImg1 setImage:[UIImage imageNamed:@"iconfont-user"]];
    [self.userNameTF.leftView addSubview:leftImg1];
    
    // 密码tf
    if (KUSERPASSWORD) {
        self.passwordTF.text = KUSERPASSWORD;
    }
    
    NSMutableAttributedString *placeholder2 = [[NSMutableAttributedString alloc] initWithString:self.passwordTF.placeholder];
    [placeholder2 addAttributes:@{NSForegroundColorAttributeName:RGBA(255, 255, 255, 0.8)} range:NSMakeRange(0, placeholder2.length)];
    self.passwordTF.attributedPlaceholder = placeholder2;
    
    self.passwordTF.secureTextEntry = YES;
    self.passwordTF.backgroundColor = FUIColorFromRGB(0x32ffffff, 0.2);
    self.passwordTF.delegate = self;
    self.passwordTF.layer.cornerRadius = 20;
    self.passwordTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.passwordTF.frame), CGRectGetHeight(self.passwordTF.frame))];
    self.passwordTF.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *leftImg2 = [[UIImageView alloc] initWithFrame:CGRectMake(9, 6, 28, 28)];
    [leftImg2 setImage:[UIImage imageNamed:@"iconfont-password"]];
    [self.passwordTF.leftView addSubview:leftImg2];
    
    // 记住密码
    [self.remButton setImage:[[UIImage imageNamed:@"unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.remButton setImage:[[UIImage imageNamed:@"selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    [self.remButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    [self.remButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.remButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    self.remButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    self.remButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    self.remButton.selected = KREMEMBERPSD;
    
    // 自动登录
    [self.autoLoginButton setImage:[[UIImage imageNamed:@"unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.autoLoginButton setImage:[[UIImage imageNamed:@"selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    [self.autoLoginButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.autoLoginButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    [self.autoLoginButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    self.autoLoginButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    self.autoLoginButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    self.autoLoginButton.selected = KAUTOLOGIN;
    
    // 登录按钮
    self.loginBtn.layer.cornerRadius = 20;
    
    // 指示器
    _activitIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    if (UI_IS_IPHONE5) {
        _activitIndicatorView.center = CGPointMake(CGRectGetWidth(self.loginBtn.frame)/2-55, 20);
    }
    if (UI_IS_IPHONE6 || iPhoneX) {
        _activitIndicatorView.center = CGPointMake(CGRectGetWidth(self.loginBtn.frame)/2-30, 20);
    }
    if (UI_IS_IPHONE6P) {
        _activitIndicatorView.center = CGPointMake(CGRectGetWidth(self.loginBtn.frame)/2-10, 20);
    }
    
    [self.loginBtn addSubview:_activitIndicatorView];
    
    
}



#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self loginClick:self.loginBtn];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if ([textField.placeholder isEqualToString:@"请输入用户名"]) {
        self.userNameTF.layer.borderColor = [UIColor blackColor].CGColor;
    }
    
    if ([textField.placeholder isEqualToString:@"请输入密码"]) {
        self.passwordTF.layer.borderColor = [UIColor blackColor].CGColor;
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.userNameTF.layer.borderColor = [UIColor grayColor].CGColor;
    self.passwordTF.layer.borderColor = [UIColor grayColor].CGColor;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.userNameTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /** 触摸释放第一响应者*/
    [self.view endEditing:YES];
}

#pragma mark - 按钮点击事件
/** 自动登录*/
- (IBAction)autoLoginClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        // 如果选中状态
        KAUTOLOGIN = YES;
    }
    else {
        KAUTOLOGIN = NO;
        
    }
}


/** 记住密码*/
- (IBAction)remButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        // 选中状态
        KREMEMBERPSD = YES;
    }
    else {
        KREMEMBERPSD = NO;
        KUSERPASSWORD = nil;
    }
}

/** 登录按钮点击*/
- (IBAction)loginClick:(UIButton *)sender {
    [self.view endEditing:YES];
    
    if ([self.userNameTF.text isEqualToString:@""]||[self.passwordTF.text isEqualToString:@""]) {
        
        [K_GlobalUtil HUDShowMessage:@"请输入用户名或密码" addedToView:SharedAppDelegate.window];
    }
    else {
        [_activitIndicatorView startAnimating];
        
        // 保存输入的密码
        NSString *saveStr = self.passwordTF.text;
        
        NSString *encrytPasswordStr = [RSAEncryptor encryptString:self.passwordTF.text publicKey:KRSA_PUBLIC_KEY];
        
        self.passwordTF.text = encrytPasswordStr;
        
        [K_NetWorkClient loginAPPWithUsername:self.userNameTF.text password:self.passwordTF.text success:^(id responseObject) {
            [_activitIndicatorView stopAnimating];
            if(responseObject){
                
                NSDictionary *dic = responseObject[@"data"];
                
                [K_GlobalUtil HUDShowMessage:@"登录成功" addedToView:SharedAppDelegate.window];
                KTOKEN = dic[@"clientDigest"];
                KUSERNAME = dic[@"username"];
                
                if (KAUTOLOGIN) {
                    // 自动登录  并设置退出登录为NO
                    KAUTOLOGIN = YES;
                    KLOGOUT = NO;
                }
                if (KREMEMBERPSD) {
                    // 记住密码
                    KUSERPASSWORD = saveStr;
                }
                
                [self toMainPage];
                
            }
        } failure:^(NSError *error) {
            [_activitIndicatorView stopAnimating];
            
            [K_GlobalUtil HUDShowMessage:@"登录失败" addedToView:SharedAppDelegate.window];
        }];
        
    }
    
}

// 主页面
- (void)toMainPage {
    UIStoryboard *CRMStory = [UIStoryboard storyboardWithName:@"CRM" bundle:nil];
    KTabBarController *tabBar = [CRMStory instantiateViewControllerWithIdentifier:@"tabBar"];
    [UIApplication sharedApplication].keyWindow.rootViewController = tabBar;
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
