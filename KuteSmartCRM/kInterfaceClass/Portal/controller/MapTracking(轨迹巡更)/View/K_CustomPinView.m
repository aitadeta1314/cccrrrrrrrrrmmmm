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

#define PinWidth 50.f
#define PinHeight 70.f

#define kCalloutWidth   100.0
#define kCalloutHeight  50.0

@interface K_CustomPinView()

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
    self.portraitImageView.image = [UIImage imageNamed:@"emoji-test"];
}

- (void)setSelected:(BOOL)selected {
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (self.selected == selected) {
        return;
    }
    
    if (selected) {
        if (!self.calloutView) {
            /* 气泡 */
            self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.frame = CGRectMake(0, 5, 100, 30);
            [btn setTitle:@"巡更轨迹" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            btn.backgroundColor = [UIColor clearColor];
            [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];

            [self.calloutView addSubview:btn];

//            UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 100, 30)];
//            name.backgroundColor = [UIColor clearColor];
//            name.textColor = [UIColor whiteColor];
//            name.textAlignment = NSTextAlignmentCenter;
//            name.text = @"巡更轨迹";
//            [self.calloutView addSubview:name];
        }
        [self addSubview:self.calloutView];
    } else {
        [self.calloutView removeFromSuperview];
    }
    
    [super setSelected:selected animated:animated];
}

- (void)btnAction:(UIButton *)sender {
//    NSLog(@"轨迹巡更");
    DisplayViewController *display = [[DisplayViewController alloc] init];
    [[self viewController].navigationController pushViewController:display animated:YES];
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


@end
