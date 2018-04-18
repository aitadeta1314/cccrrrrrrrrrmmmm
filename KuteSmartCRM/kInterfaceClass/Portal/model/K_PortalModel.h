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
@property (nonatomic, strong) NSString *node_name;
/**
 *  array
 */
@property (nonatomic, strong) NSMutableArray<SublistModel> *sublist;

@end

@interface SublistModel : JSONModel
/**
 *  img url
 */
@property (nonatomic, strong) NSString *menu_icon;
/**
 *  name
 */
@property (nonatomic, strong) NSString *sub_node_name;
/**
 *  menu_url
 */
@property (nonatomic, strong) NSString *menu_url;

@end


