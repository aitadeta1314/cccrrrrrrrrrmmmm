//
//  K_PortalModel.h
//  KuteSmartCRM
//
//  Created by Fenly on 2017/5/16.
//  Copyright © 2017年 redcollar. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SublistModel;


@interface K_PortalModel : JSONModel

/**
 *  分区名
 */
@property (nonatomic, strong) NSString <Optional>*appName;
/**
 *  array
 */
@property (nonatomic, strong) NSMutableArray<SublistModel> *subAppList;

@end

@interface SublistModel : JSONModel
/**
   img url
 */
@property (nonatomic, copy) NSString <Optional> *appIcon;
/**
   name
 */
@property (nonatomic, copy) NSString <Optional> *sub_appName;
/**
   menu_url
 */
@property (nonatomic, copy) NSString <Optional> *appUrl;
/**
 web or ative
 */
@property (nonatomic, copy) NSString <Optional> *appType;
/**
  url 参数
 */
@property (nonatomic,copy) NSString <Optional> *urlParams;

@end


