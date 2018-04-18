//
//  UserInfoManager.h
//  KuteSmartCRM
//
//  Created by kutesmart on 2017/5/8.
//  Copyright © 2017年 redcollar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoManager : NSObject

/**
 *  用户名
 */
@property (nonatomic, strong) NSString *theUserName;
/**
 *  密码
 */
@property (nonatomic, strong) NSString *theUserPassword;
/**
 * 自动登录
 */
@property (nonatomic, assign) BOOL isAutoLogin;
/**
 *  user_id
 */
@property (nonatomic, strong) NSString *userID;
/**
 *  TOKEN
 */
@property (nonatomic, strong) NSString *token;

/**
 *  姓名
 */
@property (nonatomic, strong) NSString *personName;
/**
 *  是否记住密码
 */
@property (nonatomic, assign) BOOL isRememberPsd;
/**
 *  是否已退出登录 NO为未点击退出登录 YES为点击退出登录
 */
@property (nonatomic, assign) BOOL isLogout;
/**
 * 手机型号
 */
@property (nonatomic, assign) NSString *phoneType;

/** 用户单例*/
+ (UserInfoManager *)shareUserInfoManager;


#define KUSERNAME     [UserInfoManager shareUserInfoManager].theUserName
#define KUSERPASSWORD [UserInfoManager shareUserInfoManager].theUserPassword
#define KAUTOLOGIN    [UserInfoManager shareUserInfoManager].isAutoLogin
#define KUSERID       [UserInfoManager shareUserInfoManager].userID
//#define KPERSONNAME   [UserInfoManager shareUserInfoManager].personName
#define KREMEMBERPSD  [UserInfoManager shareUserInfoManager].isRememberPsd
#define KLOGOUT       [UserInfoManager shareUserInfoManager].isLogout
#define KPHONETYPE    [UserInfoManager shareUserInfoManager].phoneType
#define KTOKEN       [UserInfoManager shareUserInfoManager].token

@end
