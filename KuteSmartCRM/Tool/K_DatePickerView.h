//
//  K_MapLocationViewController.h
//  KuteSmartCRM
//
//  Created by Fenly on 2018/5/11.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDatePickerViewDelegate <NSObject>
@optional
/**
 保存选择的时间
 */
- (void)saveClick:(NSString *)timer;

/**
 取消
 */
- (void)cancelClick;

@end

@interface K_DatePickerView : UIView

@property (copy, nonatomic) NSString *title;

/// 是否自动滑动 默认YES
@property (assign, nonatomic) BOOL isSlide;

/// 默认选中的时间
@property (copy, nonatomic) NSString *date;

/// 分钟间隔 默认1分钟
@property (assign, nonatomic) NSInteger minuteInterval;

@property (weak, nonatomic) id <KDatePickerViewDelegate> delegate;


/**
 显示picker
 */
- (void)show;

@end
