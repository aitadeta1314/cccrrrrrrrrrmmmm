//
//  K_PersonCell.m
//  KuteSmartCRM
//
//  Created by Fenly on 2018/5/18.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_PersonCell.h"

@implementation K_PersonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)cellInformationDictionary:(NSDictionary *)infoDic {
    self.nameLabel.text = infoDic[@"name"];
    self.phoneNumber.text = infoDic[@"phoneNumber"];
    if ([infoDic[@"name"] isEqualToString:@"部门"]) {
        [self.phoneBtn removeFromSuperview];
    }
}

/**
 拨打电话

 @param sender 拨打电话按钮
 */
- (IBAction)phone:(UIButton *)sender {
    if (self.callPhoneBlock) {
        self.callPhoneBlock();
    }
}


@end
