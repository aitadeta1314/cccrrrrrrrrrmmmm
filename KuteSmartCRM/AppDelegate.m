//
//  AppDelegate.m
//  KuteSmartCRM
//
//  Created by kutesmart on 2017/5/6.
//  Copyright © 2017年 redcollar. All rights reserved.
//

#import "AppDelegate.h"
#import "RSAEncryptor.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "KTabBarController.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import <Bugly/Bugly.h>

@interface AppDelegate () <AMapLocationManagerDelegate>
/**
 定时器
 */
@property (nonatomic, strong) NSTimer *timer;
/**
 获取到的地理经纬度
 */
@property (nonatomic, strong) CLLocation *locationInfo;
/**
 定位管理者
 */
@property (nonatomic, strong) AMapLocationManager *locationManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [AMapServices sharedServices].apiKey = AMAP_API_key;
    [Bugly startWithAppId:@"2da1b89840"];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self loginInit];
    NSLog(@"phoneType:%@",KPHONETYPE);
    [self initLocationManager];
    return YES;
}

/**
 开启定位 定时器
 */
- (void)openTimer {
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
}

/**
 销毁定时器
 */
- (void)invalidateTimer {
    NSLog(@"timer invalidate");
    [self.timer invalidate];
}

- (void)timerAction:(NSTimer *)timer {
    NSLog(@"---timer action in appDelegate---");
    NSLog(@"---longitude:%f, latitude:%f", self.locationInfo.coordinate.longitude, self.locationInfo.coordinate.latitude);
//     NSLog(@"userID:%@,userName:%@", KUSERID, KUSERNAME);
//    NSLog(@"displayName:%@", KDISPLAYNAME);
    
    NSDictionary *dataDic = @{@"longitude":[NSString stringWithFormat:@"%f",self.locationInfo.coordinate.longitude],
                              @"latitude":[NSString stringWithFormat:@"%f", self.locationInfo.coordinate.latitude],
                              @"createTime":[processingTime dateStringWithDate:[NSDate date] andFormatString:@"yyyy-MM-dd HH:mm:ss"],
                              @"displayName":KDISPLAYNAME,
//                              @"displayName":@"葛丽芬",
//                              @"employeeNumber":@"100217"
                              @"employeeNumber":KUSERNAME
                              };
    [K_NetWorkClient uploadLocationCoordinates:dataDic
                                       success:^(id response) {
                                           NSLog(@"上传位置成功：%@", response);
    }
                                       failure:^(NSError *error) {
                                           NSLog(@"上传位置失败:%@", error);
    }];
}

- (void)initLocationManager {
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }
    //开始持续定位
    [self.locationManager startUpdatingLocation];
}

#pragma mark - AMapLocationManagerDelegate
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode {
    self.locationInfo = location;
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    
    if (reGeocode)
    {
        NSLog(@"reGeocode:%@", reGeocode);
    }
}

// 登录初始化
- (void)loginInit{

    if (KAUTOLOGIN && KLOGOUT == NO) {
        // 自动登录 并且 没有退出登录
        [self toMainPage];
//        [self openTimer];
    }
    else {
        // 没有自动登录  并且 退出登录的情况
        [self toLoginPage];
    }
}

- (void)toLoginPage {
    UIStoryboard *CRMStory = [UIStoryboard storyboardWithName:@"CRM" bundle:nil];
    LoginViewController *loginVC = [CRMStory instantiateViewControllerWithIdentifier:@"loginID"];
    
    self.window.rootViewController = loginVC;
}

// 主页面
- (void)toMainPage {
    UIStoryboard *CRMStory = [UIStoryboard storyboardWithName:@"CRM" bundle:nil];
    KTabBarController *tabBar = [CRMStory instantiateViewControllerWithIdentifier:@"tabBar"];
    [UIApplication sharedApplication].keyWindow.rootViewController = tabBar;
}

- (void)autoLoginRequest {
    NSString *encrytPasswordStr = [RSAEncryptor encryptString:[SAMKeychain passwordForService:ServiceName account:KUSERNAME] publicKey:KRSA_PUBLIC_KEY];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *params = @{@"login_username":KUSERNAME,@"login_password":encrytPasswordStr};
    [manager POST:KLOGINHTTP parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        // 登录状态
        NSString *loginStatus = dic[@"loginStatus"];
        NSLog(@"loginStatus:%@",loginStatus);
        
        if ([loginStatus isEqualToString:@"Y"]) {
            // 成功去主页面
            [self toMainPage];
        }
        else {
            // 失败则弹出登录
            [self toLoginPage];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

}

// 同步请求
- (void)autoLoginSync {
    NSURL *url = [NSURL URLWithString:KLOGINHTTP];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    NSString *encrytPasswordStr = [RSAEncryptor encryptString:KUSERPASSWORD publicKey:KRSA_PUBLIC_KEY];
    NSString *paramStr = [NSString stringWithFormat:@"login_username=%@&login_password=%@",KUSERNAME,encrytPasswordStr];
    NSData *data = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
    // 设置参数
    [request setHTTPBody:data];
    
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error) {
        NSLog(@"error:%@",[error localizedDescription]);
        
    }
    else {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"返回结果：%@",dic);
        // 登录状态
        NSString *loginStatus = dic[@"loginStatus"];
        NSLog(@"loginStatus:%@",loginStatus);
        
        if ([loginStatus isEqualToString:@"Y"]) {
            // 成功去主页面
            [self toMainPage];
        }
        else {
            // 失败则弹出登录
            [self toLoginPage];
        }
    }
    
}

/** 禁止横屏*/
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
