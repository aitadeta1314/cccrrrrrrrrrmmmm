//
//  K_SearchViewController.m
//  KuteSmartCRM
//
//  Created by Fenly on 2018/5/28.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_SearchViewController.h"

#define View_TOP  (iPhoneX ? 49 : 25)

@interface K_SearchViewController ()<UITextFieldDelegate>

/**
 搜索框
 */
@property (nonatomic, strong) UITextField *searchTF;
/**
 取消
 */
@property (nonatomic, strong) UIButton *cancel;

@end

@implementation K_SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    [self layoutSubViewsSelfdefineMethod];
}

- (void)layoutSubViewsSelfdefineMethod {
    
    self.cancel = [[UIButton alloc] initWithFrame:CGRectMake(kDeviceWidth - 40 - 10, View_TOP + 5, 40, 30)];
    [self.view addSubview:self.cancel];
    
    self.cancel.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.cancel setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancel setTitleColor:NavigationBarBGColor forState:UIControlStateNormal];
    [self.cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancel addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    
    /// 搜索框
    self.searchTF = [[UITextField alloc] initWithFrame:CGRectMake(10, View_TOP, kDeviceWidth - CGRectGetWidth(self.cancel.frame) - 30, 40)];
    [self.view addSubview:self.searchTF];
    
    self.searchTF.placeholder = @"搜索";
    self.searchTF.backgroundColor = FUIColorFromRGB(0xcdcdcd, 0.2);
    self.searchTF.returnKeyType = UIReturnKeySearch;
    self.searchTF.delegate = self;
    self.searchTF.layer.cornerRadius = 5;
    self.searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.searchTF.frame), CGRectGetHeight(self.searchTF.frame))];
    self.searchTF.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *leftImg1 = [[UIImageView alloc] initWithFrame:CGRectMake(12, 9, 22, 22)];
    [leftImg1 setImage:[UIImage imageNamed:@"search_leftIcon"]];
    [self.searchTF.leftView addSubview:leftImg1];
    
    [self.searchTF becomeFirstResponder];
}

- (void)cancelClick {
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];

}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"点击了搜索");
    
    
    
    [self.searchTF resignFirstResponder];
    return YES;
}



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
