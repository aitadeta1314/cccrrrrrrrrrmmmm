//
//  MyNavViewController.m
//  KTSmartNewAL
//
//  Created by kutesmart on 2016/10/20.
//  Copyright © 2016年 HL. All rights reserved.
//

#import "MyNavViewController.h"

@interface MyNavViewController ()

@end

@implementation MyNavViewController

- (id)init {
    if (self = [super init]) {
        /** 定义左侧返回按钮*/
        UIButton *leftItemBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [leftItemBtn addTarget:self action:@selector(goLeft) forControlEvents:UIControlEventTouchUpInside];
        [leftItemBtn setImage:[UIImage imageNamed:@"nabar_left"] forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftItemBtn];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
        
    }
    return self;
}


- (void)goLeft {
    
    if ([self.navigationController popViewControllerAnimated:YES] == nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIButton * leftItemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
        [leftItemBtn addTarget:self action:@selector(goLeft) forControlEvents:UIControlEventTouchUpInside];
        [leftItemBtn setImage:[UIImage imageNamed:@"nabar_left"] forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftItemBtn];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
        self.navigationController.navigationBar.tintColor =[UIColor blackColor];
        
    }
    return self;
}



//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
