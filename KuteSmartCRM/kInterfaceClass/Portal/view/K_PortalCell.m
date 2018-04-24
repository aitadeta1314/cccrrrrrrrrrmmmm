//
//  K_PortalCell.m
//  KuteSmartCRM
//
//  Created by Fenly on 2017/5/16.
//  Copyright © 2017年 redcollar. All rights reserved.
//

#import "K_PortalCell.h"

@implementation K_PortalCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(SublistModel *)model {
    self.PortalTitle.text = model.sub_appName;
    [self.PortalImgView sd_setImageWithURL:[NSURL URLWithString:model.appIcon]];
    
}

@end
