//
//  CustomActionSheet.h
//  KuteSmartCRM
//
//  Created by Fenly on 2018/6/24.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WN_CustomActionSheet;
@protocol CustomActionSheetDelegate <NSObject>

- (void)customActionSheet:(WN_CustomActionSheet *)actionSheet didSelecetWithButtonIndex:(NSInteger)buttonIndex;

@end

@interface WN_CustomActionSheet : UIView
@property (nonatomic, weak) id<CustomActionSheetDelegate> delegate;
- (void)showInView:(UIView *)view;
+ (instancetype)customActionSheet;
@end
