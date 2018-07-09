//
//  K_PendingEventPinView.m
//  KuteSmartCRM
//
//  Created by Fenly on 2018/7/7.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_PendingEventPinView.h"
#import "CustomCalloutView.h"

#define kCalloutWidth   100.0
#define kCalloutHeight  80.0

@implementation K_PendingEventPinView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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
        UIImageView *redFlag = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        redFlag.image = [UIImage imageNamed:@"小红旗"];
        [self addSubview:redFlag];
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
            [eventClick setTitle:@"事件详情" forState:UIControlStateNormal];
            eventClick.titleLabel.font = [UIFont systemFontOfSize:13];
            [eventClick addTarget:self action:@selector(eventClick:) forControlEvents:UIControlEventTouchUpInside];
            [eventClick setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [eventClick setBackgroundColor: NavigationBarBGColor];
            eventClick.layer.cornerRadius = 3.f;
            eventClick.layer.masksToBounds = YES;
            [self.calloutView addSubview:eventClick];
            [eventClick mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.calloutView).offset(-15);
                make.centerX.equalTo(self.calloutView);
                make.height.mas_equalTo(30);
            }];
            
            UILabel *eventDescribe = [[UILabel alloc] init];
            [self.calloutView addSubview:eventDescribe];
            eventDescribe.textAlignment = NSTextAlignmentCenter;
            eventDescribe.numberOfLines = 0;
            eventDescribe.lineBreakMode = NSLineBreakByTruncatingTail;
            [eventDescribe setTextColor:UIColor.whiteColor];
            eventDescribe.font = [UIFont systemFontOfSize:13];
            eventDescribe.text = self.dataDic[@"textDescription"];
            [eventDescribe mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.calloutView);
                make.top.equalTo(self.calloutView).offset(5);
                make.bottom.mas_equalTo(eventClick.mas_top).offset(-5);
                make.width.mas_equalTo(kCalloutWidth-10);
            }];
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
    NSLog(@"点击了时间详情");
}

@end
