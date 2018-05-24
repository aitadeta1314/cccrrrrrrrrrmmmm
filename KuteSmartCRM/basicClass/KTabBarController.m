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
    
    /// 更改文字颜色
    NSMutableDictionary *selectedAtts=[NSMutableDictionary dictionary];
    selectedAtts[NSForegroundColorAttributeName] = NavigationBarBGColor;
    UITabBarItem * item = [self.tabBar.items objectAtIndex:0];
    item.badgeValue = @"0";
    item.badgeValue=  nil;
    for (UIViewController *viewC in self.viewControllers) {
        [viewC.tabBarItem setTitleTextAttributes:selectedAtts forState:UIControlStateSelected];
    }
    
    [self getSafetyListFromServer];
}

- (void)getSafetyListFromServer {
    
    /// 获取保安列表
    [K_NetWorkClient getSecurityPersonnelListSuccess:^(id response) {
        NSLog(@"response:%@", response);
        if ([response[@"code"] intValue] == 200) {
            NSArray *data = response[@"data"];
            for (NSString *number in data) {
                if ([number isEqualToString: KUSERNAME]) {
                    
                    /// 开启上传位置定时器
                    [SharedAppDelegate openTimer];
                    break;
                }
            }
        }
    } failure:^(NSError *error) {
        
    }];
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
