//
//  K_PersonCell.h
//  KuteSmartCRM
//
//  Created by Fenly on 2018/5/18.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^callPhoneBlock)();

@interface K_PersonCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *phoneBtn;

- (void)cellInformationDictionary:(NSDictionary *)infoDic;

/**
 拨打电话block
 */
@property (nonatomic,copy) callPhoneBlock callPhoneBlock;

@end
