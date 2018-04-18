//
//  UserInfoManager.m
//  KuteSmartCRM
//
//  Created by kutesmart on 2017/5/8.
//  Copyright © 2017年 redcollar. All rights reserved.
//

#import "UserInfoManager.h"
#import <sys/utsname.h>

static UserInfoManager *_userInfoManager = nil;

@implementation UserInfoManager

+ (UserInfoManager *)shareUserInfoManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _userInfoManager = [[super allocWithZone:NULL] init];
    });
    return _userInfoManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [UserInfoManager shareUserInfoManager];
}

/** 用户名*/
- (NSString *)theUserName {
    return [kUserDefaults objectForKey:@"THEUSERNAME"];
}

- (void)setTheUserName:(NSString *)theUserName {
    if (theUserName) {
        [kUserDefaults setObject:theUserName forKey:@"THEUSERNAME"];
    }
    else {
        [kUserDefaults removeObjectForKey:@"THEUSERNAME"];
    }
    [kUserDefaults synchronize];
}

/** 密码*/
- (NSString *)theUserPassword {
    return [kUserDefaults objectForKey:@"THEUSERPASSWORD"];
}

- (void)setTheUserPassword:(NSString *)theUserPassword {
    if (theUserPassword) {
        [kUserDefaults setObject:theUserPassword forKey:@"THEUSERPASSWORD"];
    }
    else {
        [kUserDefaults removeObjectForKey:@"THEUSERPASSWORD"];
    }
    [kUserDefaults synchronize];
}

/** 是否自动登录*/
- (BOOL)isAutoLogin {
    return [kUserDefaults boolForKey:@"ISAUTOLOGIN"];
}

- (void)setIsAutoLogin:(BOOL)isAutoLogin {
    
    if (isAutoLogin) {
        [kUserDefaults setBool:isAutoLogin forKey:@"ISAUTOLOGIN"];
    }
    else {
        [kUserDefaults removeObjectForKey:@"ISAUTOLOGIN"];
    }
    [kUserDefaults synchronize];
}

/** userID*/
- (NSString *)userID {
    return [kUserDefaults objectForKey:@"USERID"];
}

- (void)setUserID:(NSString *)userID {
    if (userID) {
        [kUserDefaults setObject:userID forKey:@"USERID"];
    }
    else {
        [kUserDefaults removeObjectForKey:@"USERID"];
    }
    [kUserDefaults synchronize];
}
/** TOKEN*/
- (NSString *)token {
    return [kUserDefaults objectForKey:@"TOKEN"];
}

- (void)setToken:(NSString *)token {
    if (token) {
        [kUserDefaults setObject:token forKey:@"TOKEN"];
    }
    else {
        [kUserDefaults removeObjectForKey:@"TOKEN"];
    }
    [kUserDefaults synchronize];
}

#pragma mark - personName
- (NSString *)personName {
    return [kUserDefaults objectForKey:@"PERSONNAME"];
}

- (void)setPersonName:(NSString *)personName {
    if (personName) {
        [kUserDefaults setObject:personName forKey:@"PERSONNAME"];
    }
    else {
        [kUserDefaults removeObjectForKey:@"PERSONNAME"];
    }
    [kUserDefaults synchronize];
}

#pragma mark - 是否记住密码
- (BOOL)isRememberPsd {
    return [kUserDefaults boolForKey:@"ISREMEMBERPSD"];
}

- (void)setIsRememberPsd:(BOOL)isRememberPsd {
    if (isRememberPsd) {
        [kUserDefaults setBool:isRememberPsd forKey:@"ISREMEMBERPSD"];
    }
    else {
        [kUserDefaults removeObjectForKey:@"ISREMEMBERPSD"];
    }
    [kUserDefaults synchronize];
}

#pragma mark - 是否退出登录
- (BOOL)isLogout {
    return [kUserDefaults boolForKey:@"ISLOGOUT"];
}

- (void)setIsLogout:(BOOL)isLogout {
    if (isLogout) {
        [kUserDefaults setBool:isLogout forKey:@"ISLOGOUT"];
    }
    else {
        [kUserDefaults removeObjectForKey:@"ISLOGOUT"];
    }
    [kUserDefaults synchronize];
}



#pragma mark - 获取手机型号
- (NSString *)phoneType {
    return [self iphoneType];
}

- (NSString *)iphoneType {
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    return platform;
    
}



@end
