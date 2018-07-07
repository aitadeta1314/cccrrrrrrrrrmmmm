//
//  K_PendingEventPinView.m
//  KuteSmartCRM
//
//  Created by Fenly on 2018/7/7.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_PendingEventPinView.h"
#import "CustomCalloutView.h"

#define kCalloutWidth   60.0
#define kCalloutHeight  40.0

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
        
        self.bounds = CGRectMake(0, 0, 60, 60);
        UIImageView *redFlag = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
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
            [eventClick addTarget:self action:@selector(eventClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.calloutView addSubview:eventClick];
            
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
