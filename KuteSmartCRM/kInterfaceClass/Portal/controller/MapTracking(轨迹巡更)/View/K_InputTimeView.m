//
//  K_InputTimeView.m
//  KuteSmartCRM
//
//  Created by Fenly on 2018/5/11.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_InputTimeView.h"

@implementation K_InputTimeView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
        self.backgroundColor = RGBA(76.5, 76.5, 76.5, 0.8);
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"K_InputTimeView" owner:self options:nil] lastObject];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    [self addSubview:view];
    self.sure.layer.cornerRadius = 5;
    self.sure.layer.masksToBounds = YES;
}

- (IBAction)sureClick:(UIButton *)sender {
    NSLog(@"beginTextField:%@",self.beginTextfield.text);
    NSLog(@"endTextField:%@",self.endTextfield.text);
}


@end
