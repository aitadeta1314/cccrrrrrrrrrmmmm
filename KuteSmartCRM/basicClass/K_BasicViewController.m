//
//  K_BasicViewController.m
//  KuteSmartCRM
//
//  Created by Fenly on 2017/5/27.
//  Copyright © 2017年 redcollar. All rights reserved.
//

#import "K_BasicViewController.h"

@interface K_BasicViewController ()

@end

@implementation K_BasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = NavigationBarBGColor;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
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
