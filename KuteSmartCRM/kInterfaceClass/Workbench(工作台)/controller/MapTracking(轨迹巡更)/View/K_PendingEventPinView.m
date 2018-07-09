//
//  K_PendingEventPinView.m
//  KuteSmartCRM
//
//  Created by Fenly on 2018/7/7.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_PendingEventPinView.h"
#import "CustomCalloutView.h"
#import "K_RecordEventInfoViewController.h"

#define kCalloutWidth   150.0
#define kCalloutHeight  120.0
@interface K_PendingEventPinView()

/**
 
 */
@property (nonatomic, strong) UIImageView *flag;

@end

@implementation K_PendingEventPinView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setUrgentStatus:(NSString *)urgentStatus {
    if ([urgentStatus isEqualToString:@"1"]) {
        self.flag.image = [UIImage imageNamed:@"小黄旗"];
    } else if ([urgentStatus isEqualToString:@"2"]) {
        self.flag.image = [UIImage imageNamed:@"小红旗"];
    } else {
        self.flag.image = [UIImage imageNamed:@"小绿旗"];
    }
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
        
        self.bounds = CGRectMake(0, 0, 30, 30);
        self.flag = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        
        [self addSubview:self.flag];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {

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

            
            UIButton *eventClick = [UIButton buttonWithType:UIButtonTypeCustom];
            if ([self.dataDic[@"displayName"] isEqualToString:KDISPLAYNAME]) {
                // 本人显示事件处理
                [eventClick setTitle:@"事件处理" forState:UIControlStateNormal];
            } else {
                // 非本人系显示事件详情
                [eventClick setTitle:@"事件详情" forState:UIControlStateNormal];
            }
            eventClick.titleLabel.font = [UIFont systemFontOfSize:13];
            [eventClick addTarget:self action:@selector(eventClick:) forControlEvents:UIControlEventTouchUpInside];
            [eventClick setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [eventClick setBackgroundColor: NavigationBarBGColor];
            eventClick.layer.cornerRadius = 3.f;
            eventClick.layer.masksToBounds = YES;
            [self.calloutView addSubview:eventClick];
            [eventClick mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.calloutView).offset(-13);
                make.centerX.equalTo(self.calloutView);
                make.height.mas_equalTo(30);
            }];
            
            UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, kCalloutWidth-10, 15)];
            [self.calloutView addSubview:name];
            [name setTextColor:UIColor.whiteColor];
            name.font = [UIFont systemFontOfSize:13];
            name.text = [NSString stringWithFormat:@"姓名:%@", self.dataDic[@"displayName"]];
            
            UILabel *timeTag = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(name.frame)+5, 35, 15)];
            [self.calloutView addSubview:timeTag];
            [timeTag setTextColor:UIColor.whiteColor];
            timeTag.font = [UIFont systemFontOfSize:13];
            timeTag.text = @"时间:";
            
            UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(timeTag.frame), CGRectGetMinY(timeTag.frame), 100, 32)];
            [self.calloutView addSubview:time];
            time.textAlignment = NSTextAlignmentCenter;
            [time setTextColor:UIColor.whiteColor];
            time.font = [UIFont systemFontOfSize:13];
            time.numberOfLines = 2;
            time.text = self.dataDic[@"createTime"];
            
            UILabel *urgency = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(time.frame)+2, CGRectGetWidth(time.frame), 15)];
            [self.calloutView addSubview:urgency];
            [urgency setTextColor:UIColor.whiteColor];
            urgency.font = [UIFont systemFontOfSize:13];
            NSString *status = nil;
            if ([self.dataDic[@"urgentStatus"] isEqualToString:@"1"]) {
                // 重要
                status = @"重要";
            } else if ([self.dataDic[@"urgentStatus"] isEqualToString:@"2"]) {
                // 紧急
                status = @"紧急";
            } else {
                // 正常
                status = @"正常";
            }
            urgency.text = [NSString stringWithFormat:@"紧急状态:%@", status];
            
        }
        [self addSubview:self.calloutView];
        
    } else {
        [self.calloutView removeFromSuperview];

//        CLLocationCoordinate2D coord = (CLLocationCoordinate2D){0, 0};
        
    }
    
    [super setSelected:selected animated:animated];
}

/// 事件详情点击
- (void)eventClick:(UIButton *)sender {
    NSLog(@"点击了事件详情");
    K_RecordEventInfoViewController *dispostEvent = [[K_RecordEventInfoViewController alloc] initWithNibName:@"K_RecordEventInfoViewController" bundle:nil];
    dispostEvent.isEventDispose = YES;
    dispostEvent.eventData = self.dataDic;
    [[self viewController].navigationController pushViewController:dispostEvent animated:YES];
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

@end
