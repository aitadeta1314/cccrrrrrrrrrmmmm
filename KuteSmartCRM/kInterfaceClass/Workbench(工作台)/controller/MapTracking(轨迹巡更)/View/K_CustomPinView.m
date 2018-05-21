//
//  K_CustomPinView.m
//  KuteSmartCRM
//
//  Created by Fenly on 2018/5/10.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_CustomPinView.h"
#import "CustomCalloutView.h"
#import "DisPlayViewController.h"
#import "K_DatePickerView.h"
#import "K_InputTimeView.h"

#define PinWidth 50.f
#define PinHeight 70.f

#define kCalloutWidth   200.0
#define kCalloutHeight  160.0

@interface K_CustomPinView()<UITextFieldDelegate, KDatePickerViewDelegate>

/**
 时间选择器
 */
@property (nonatomic, strong) K_DatePickerView *dateView;
/**
 时间段view
 */
@property (nonatomic, strong) K_InputTimeView *timeView;
/**
 beginTextField选中弹出timePicker
 */
@property (nonatomic, assign) BOOL beginTFSelected;
/**
 人员头像
 */
@property (nonatomic, strong) UIImageView *portraitImageView;
/**
 人员名字
 */
@property (nonatomic, strong) UILabel *nameLabel;


@end

@implementation K_CustomPinView

- (NSString *)name {
    return self.nameLabel.text;
}

- (void)setName:(NSString *)name {
    self.nameLabel.text = name;
}

//- (NSString *)portraitUrl {
//    return self.portraitImageView.image
//}

- (void)setPortraitUrl:(NSString *)portraitUrl {
//    [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:portraitUrl] placeholderImage:[UIImage imageNamed:@""]];
    self.portraitImageView.image = [UIImage imageNamed:@"警察"];
}

- (void)setSelected:(BOOL)selected {
    self.beginTFSelected = NO;
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (self.selected == selected) {
        return;
    }
    /// 能够知道点击的大头针坐标位置
    NSLog(@"setSelected:animated: -----  ----- latitude:%f, longitude:%f", self.annotation.coordinate.latitude, self.annotation.coordinate.longitude);
    if (selected) {
        if (!self.calloutView) {
            /* 气泡 */
            self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
            
            self.timeView = [[K_InputTimeView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
            self.timeView.beginTextfield.delegate = self;
            self.timeView.endTextfield.delegate = self;
            [self.timeView.sure addTarget:self action:@selector(sure:) forControlEvents:UIControlEventTouchUpInside];
            [self.calloutView addSubview:self.timeView];

        }
        [self addSubview:self.calloutView];
        /// 调用block  防止在输入查询信息的时候remove大头针
        if (self.clickCustomPinView) {
            self.clickCustomPinView(self.annotation.coordinate, self.name);
        }
    } else {
        [self.calloutView removeFromSuperview];
        [self cancelClick];
        CLLocationCoordinate2D coord = (CLLocationCoordinate2D){0, 0};
        if (self.clickCustomPinView) {
            self.clickCustomPinView(coord, @"");
        }
    }
    
    [super setSelected:selected animated:animated];
}

#pragma mark - 确定按钮
/**
 确定按钮点击

 @param sender 确定按钮
 */
- (void)sure:(UIButton *)sender {
    
    if (![self.timeView.beginTextfield.text isValidString] || ![self.timeView.endTextfield.text isValidString]) {
        [K_GlobalUtil HUDShowMessage:@"请输入有效的时间" addedToView:SharedAppDelegate.window];
        return;
    }
    
    [self cancelClick];
    
    weakObjc(self);
    [K_NetWorkClient searchSomeoneATimePeriodDateFrom:[NSString stringWithFormat:@"%@:00", self.timeView.beginTextfield.text]
                                               dateTo:[NSString stringWithFormat:@"%@:00", self.timeView.endTextfield.text]
                                       employeeNumber:self.employeeNumber
                                              success:^(id response) {
                                                    NSLog(@"查询成功");
                                                    NSLog(@"response:%@", response);
                                                  
                                                  if ([response[@"code"] integerValue] == 200) {
                                                      NSArray *coordArray = response[@"data"];
                                                      AMapRouteRecord *record = [[AMapRouteRecord alloc] init];
                                                      for (NSDictionary *dic in coordArray) {
                                                          NSString *longitude = dic[@"longitude"];
                                                          NSString *latitude = dic[@"latitude"];
                                                          CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
                                                          [record addLocation:location];
                                                      }
                                                      DisplayViewController *display = [[DisplayViewController alloc] init];
                                                      [display setRecord:record];
                                                      [[weakself viewController].navigationController pushViewController:display animated:YES];
                                                  }
                                                  
    }
                                                failure:^(NSError *error) {
                                                    NSLog(@"查询时间段失败");
                                                    NSLog(@"error:%@", error);
    }];
}

- (UIViewController *)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inside = [super pointInside:point withEvent:event];
    /* Points that lie outside the receiver’s bounds are never reported as hits,
     even if they actually lie within one of the receiver’s subviews.
     This can occur if the current view’s clipsToBounds property is set to NO and the affected subview extends beyond the view’s bounds.
     */
    if (!inside && self.selected)
    {
        inside = [self.calloutView pointInside:[self convertPoint:point toView:self.calloutView] withEvent:event];
    }
    
    return inside;
}


- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bounds = CGRectMake(0, 0, PinWidth, PinHeight);
        self.portraitImageView = [[UIImageView alloc] init];
        [self addSubview:self.portraitImageView];
        [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.mas_equalTo(PinWidth);
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        [self addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.mas_equalTo(PinHeight-PinWidth);
        }];
        self.nameLabel.backgroundColor = UIColor.clearColor;
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.font = [UIFont systemFontOfSize:15.f];
        
    }
    return self;
}

//时间---->时间戳
- (NSString *)transTotimeSp:(NSString *)time{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]]; //设置本地时区
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *date = [dateFormatter dateFromString:time];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];//时间戳
    return timeSp;
}


#pragma mark - KDatePickerViewDelegate
/**
 保存
 
 @param timer 保存
 */
- (void)saveClick:(NSString *)timer {
    if (self.beginTFSelected) {
        
        self.timeView.beginTextfield.text = timer;
    } else {
        self.timeView.endTextfield.text = timer;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.dateView.frame = CGRectMake(0, kDeviceHeight, kDeviceWidth, 300);
        self.dateView = nil;
    }];
}

/**
 取消
 */
- (void)cancelClick {
    [UIView animateWithDuration:0.3 animations:^{
        self.dateView.frame = CGRectMake(0, kDeviceHeight, kDeviceWidth, 300);
        
        self.dateView = nil;
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.dateView == nil) {
        K_DatePickerView *dateView = [[K_DatePickerView alloc] initWithFrame:CGRectMake(0, kDeviceHeight, kDeviceWidth, 300)];
        dateView.delegate = self;
        dateView.title = @"请选择时间";
        [SharedAppDelegate.window addSubview:dateView];
        self.dateView = dateView;
    }
    if (textField == self.timeView.beginTextfield) {
        self.beginTFSelected = YES;
    } else {
        self.beginTFSelected = NO;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.dateView.frame = CGRectMake(0, kDeviceHeight - 300, kDeviceWidth, 300);
        [self.dateView show];
    }];
    
    
    return NO;
}



@end
