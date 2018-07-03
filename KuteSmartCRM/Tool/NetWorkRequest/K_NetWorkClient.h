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

/// 获取工作台
+ (void)getWorkbenchListInfoSuccess:(void (^)(id responseObject))success
                            failure:(void (^)(NSError *error))failure;
#pragma mark - 通讯录接口
/// 通讯录
+ (void)getAddressBookWithOrgID:(NSString *)orgID
                        success:(void (^)(id responseObject))success
                        failure:(void (^)(NSError *error))failure;

/// 通讯录搜索
+ (void)searchAddressWithparameter:(NSString *)searchText
                           success:(void (^)(id responseObject))success
                           failure:(void (^)(NSError *error))failure;

#pragma mark - 轨迹巡更接口
/// 获取用户位置信息
+ (void)getUserLocationInfoSuccess:(void (^)(id responseObject))success
                           failure:(void (^)(NSError *error))failure;

/// 上传位置坐标信息
+ (void)uploadLocationCoordinates:(NSDictionary *)locaDic
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError *error))failure;

/// 查询某个人某个时间段位置信息
+ (void)searchSomeoneATimePeriodDateFrom:(NSString *)dateFrom
                                  dateTo:(NSString *)dateTo
                          employeeNumber:(NSString *)employeeNumber
                                 success:(void (^)(id response))success
                                 failure:(void (^)(NSError *error))failure;

/// 获取保安人员
+ (void)getSecurityPersonnelListSuccess:(void (^)(id response))success
                             failure:(void (^)(NSError *error))failure;

#pragma mark - 七牛token
/// 获取七牛token
+ (void)getQiniuTokenSuccess:(void (^)(id response))success
                     failure:(void (^)(NSError *error))failure;

#pragma mark - 修改密码
+ (void)modifyPasswordNewPassword:(NSString *)newPassword
                      oldPassword:(NSString *)oldPassword
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError *error))faliure;


@end
