//
//  K_NetWorkClient.h
//  KuteSmartCRM
//
//  Created by Fenly on 2018/4/18.
//  Copyright © 2018年 redcollar. All rights reserved.
//  网络请求类

#import <Foundation/Foundation.h>
#import "LoginViewController.h"

typedef NS_ENUM(NSInteger, RequestMethodType){
    RequestMethodTypePost = 1,
    RequestMethodTypeGet = 2,
    RequestMethodTypeDelete
};

@interface K_NetWorkClient : NSObject

/// 登录
+ (void)loginAPPWithUsername:(NSString *)username
                    password:(NSString *)password
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError *error))failure;

/// 通讯录
+ (void)getAddressBookWithOrgID:(NSString *)orgID
                        success:(void (^)(id responseObject))success
                        failure:(void (^)(NSError *error))failure;
/// 获取工作台
+ (void)getWorkbenchListInfoSuccess:(void (^)(id responseObject))success
                            failure:(void (^)(NSError *error))failure;
@end
