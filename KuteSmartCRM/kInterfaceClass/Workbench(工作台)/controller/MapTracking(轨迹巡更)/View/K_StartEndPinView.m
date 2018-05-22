//
//  K_StartEndPinView.m
//  KuteSmartCRM
//
//  Created by Fenly on 2018/5/21.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_StartEndPinView.h"

@interface K_StartEndPinView()

/**
 
 */
@property (nonatomic, strong) UIImageView *picView;

@end

@implementation K_StartEndPinView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setImagename:(NSString *)imagename {
    self.picView.image = [UIImage imageNamed:imagename];
}

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bounds = CGRectMake(0, 0, 60, 90);
        self.picView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -3, 60, 60)];
        [self addSubview:self.picView];
        
    }
    
    return self;
}



@end
