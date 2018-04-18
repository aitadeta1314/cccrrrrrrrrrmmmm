//
//  K_PortalModel.m
//  KuteSmartCRM
//
//  Created by Fenly on 2017/5/16.
//  Copyright © 2017年 redcollar. All rights reserved.
//

#import "K_PortalModel.h"

@implementation K_PortalModel



@end

@implementation SublistModel

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                  @"node_name":@"sub_node_name"
                                                       }];
}

@end
