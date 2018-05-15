//
//  KTabBarController.m
//  KuteSmartCRM
//
//  Created by kutesmart on 2017/5/13.
//  Copyright © 2017年 redcollar. All rights reserved.
//

#import "KTabBarController.h"

@interface KTabBarController ()

@end

@implementation KTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    
//    NSMutableDictionary *atts=[NSMutableDictionary dictionary];
//    atts[NSFontAttributeName]=[UIFont systemFontOfSize:12];
//    atts[NSForegroundColorAttributeName]=[UIColor darkGrayColor];
    /// 更改文字颜色
    NSMutableDictionary *selectedAtts=[NSMutableDictionary dictionary];
//    selectedAtts[NSFontAttributeName]=[UIFont systemFontOfSize:12];
    selectedAtts[NSForegroundColorAttributeName] = NavigationBarBGColor;
    
    for (UIViewController *viewC in self.viewControllers) {
        [viewC.tabBarItem setTitleTextAttributes:selectedAtts forState:UIControlStateSelected];
    }
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
