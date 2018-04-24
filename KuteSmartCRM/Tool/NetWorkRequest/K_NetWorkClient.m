//
//  K_NetWorkClient.m
//  KuteSmartCRM
//
//  Created by Fenly on 2018/4/18.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_NetWorkClient.h"

@implementation K_NetWorkClient

+ (AFHTTPSessionManager *)sharedHTTPSessionManager {
    static AFHTTPSessionManager* mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURL* baseURL = [NSURL URLWithString:KHOST];
        mgr = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:configuration];
        mgr.requestSerializer = [AFJSONRequestSerializer serializer];
        // 设置缓存策略忽略本地缓存数据
        [mgr.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        mgr.responseSerializer = [AFJSONResponseSerializer serializer];
        [mgr.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        [mgr.requestSerializer setTimeoutInterval:12.0];
        [mgr.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        [mgr.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
        [mgr.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        objc_setAssociatedObject(mgr, "RETRY_COUNT_MAP_KEY", [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN);
        mgr.responseSerializer = [[AFJSONResponseSerializer alloc] init];
        NSMutableSet* set = [mgr.responseSerializer.acceptableContentTypes mutableCopy];
        [set addObject:@"text/plain"];
        [set addObject:@"text/html"];
        
        mgr.responseSerializer.acceptableContentTypes = set;
    });
    return mgr;
}

// 登录
+ (void)loginAPPWithUsername:(NSString *)username
                    password:(NSString *)password
                     success:(void (^)(id))success
                     failure:(void (^)(NSError *))failure {
    NSDictionary *params = @{
                             @"username":username,
                             @"password":password,
                             };
    [K_NetWorkClient requestWithMethod_ST:RequestMethodTypePost
                                      url:@"/user/login"
                                   params:params
                                  success:success
                                  failure:success];
}

// 通讯录
+ (void)getAddressBookWithOrgID:(NSString *)orgID
                        success:(void (^)(id))success
                        failure:(void (^)(NSError *error))failure {
    if(!orgID){
        orgID = @"00000000";
#warning orgID = @"00000000"含义需要弄清楚
    }
    [K_NetWorkClient requestWithMethod_ST:RequestMethodTypeGet
                                      url:[NSString stringWithFormat:@"/personnel/findHrryByOrg/%@", orgID]
                                   params:nil
                                  success:success
                                  failure:failure];
}

/// 工作台列表
+ (void)getWorkbenchListInfoSuccess:(void (^)(id))success
                            failure:(void (^)(NSError *))failure {
    [K_NetWorkClient requestWithMethod_ST:RequestMethodTypeGet
                                      url:[NSString stringWithFormat:@"/public/microapp/getAppList"]
                                   params:nil
                                  success:success
                                  failure:failure];
}

+ (NSURLSessionDataTask *)requestWithMethod_ST:(RequestMethodType)methodType
                                           url:(NSString*)url
                                        params:(id)params
                                       success:(void (^)(id response))success
                                       failure:(void (^)(NSError* err))failure
{
    
    AFHTTPSessionManager *manager = [self sharedHTTPSessionManager];
    NSString *token = KTOKEN;
    if (token) {
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    }
    if (KUSERNAME) {
        
        [manager.requestSerializer setValue:KUSERNAME forHTTPHeaderField:@"username"];
    }
    NSURLSessionDataTask *task;
    switch (methodType) {
        case RequestMethodTypeGet:
        {
            task = [manager GET:url
                     parameters:params
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            success(responseObject);
            }
                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            // 如果失败的话 有可能是网络问题，再者就是用户token失效
                            [K_NetWorkClient performCommonFailure:failure error:error];
            }];
        }
            break;
        case RequestMethodTypePost:
        {
            task = [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                success(responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [K_NetWorkClient performCommonFailure:failure error:error];
            }];
        }
            break;
        default:
            break;
    }
    
    return task;
}

/// 请求失败情况处理
+ (void)performCommonFailure:(void (^)(NSError* err))failure error:(NSError*)error {
    if (failure)
        failure(error);
    switch (error.code) {
        case kCFURLErrorNotConnectedToInternet:
            [K_GlobalUtil HUDShowMessage:@"未连接网络" addedToView:SharedAppDelegate.window];
            break;
        case kCFURLErrorTimedOut:
            [K_GlobalUtil HUDShowMessage:@"网络超时，请检查网络情况" addedToView:SharedAppDelegate.window];
            break;
        default:
        {
            NSString *errorStr = [NSString stringWithFormat:@"%@",error];
            if ([errorStr containsString:@"401"]) {
                UIStoryboard *CRMStory = [UIStoryboard storyboardWithName:@"CRM" bundle:nil];
                LoginViewController *loginVC = [CRMStory instantiateViewControllerWithIdentifier:@"loginID"];
                SharedAppDelegate.window.rootViewController = loginVC;
            }
        }
            break;
    }
}


@end
