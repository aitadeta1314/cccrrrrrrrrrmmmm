//
//  K_PortalCell.h
//  KuteSmartCRM
//
//  Created by Fenly on 2017/5/16.
//  Copyright © 2017年 redcollar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "K_PortalModel.h"

@interface K_PortalCell : UICollectionViewCell
/** 图标*/
@property (weak, nonatomic) IBOutlet UIImageView *PortalImgView;
/** 标题*/
@property (weak, nonatomic) IBOutlet UILabel *PortalTitle;

/**
 *  模型
 */
@property (nonatomic, strong) SublistModel *model;

@end
