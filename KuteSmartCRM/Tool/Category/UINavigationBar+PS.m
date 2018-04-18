//
//  UINavigationBar+PS.m
//  KuteSmartCRM
//
//  Created by Fenly on 2018/4/18.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "UINavigationBar+PS.h"
#import <objc/runtime.h>

@implementation UINavigationBar (PS)
#warning 用runtime给navigatinoBar添加了一个子控件overlayer
static char overlayerkey;

- (UIView*)overlayer
{
    return objc_getAssociatedObject(self, &overlayerkey);
}

- (void)setOverlayer:(UIView*)overlayer
{
    objc_setAssociatedObject(self, &overlayerkey, overlayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark --
/**
 *  给导航栏设置颜色
 */
- (void)ps_setBackgroundColor:(UIColor *)backgroundColor
{
    if (!self.overlayer)
    {
        
        [self setBackgroundImage:[UIImage new] forBarMetrics:(UIBarMetricsDefault)];
        
        self.overlayer = [[UIView alloc] initWithFrame:CGRectMake(0, -20, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + 20)];
        /*
         为什么Y要-20,H要+20呢?
         因为,overlayer要覆盖statusBar
         */
        self.overlayer.userInteractionEnabled = NO;
        self.overlayer.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self insertSubview:self.overlayer atIndex:0];
    }
    
    self.overlayer.backgroundColor = backgroundColor;
}

/**
 *  设置导航栏位置
 */
- (void)ps_setTranslationY:(CGFloat)translationY
{
    self.transform = CGAffineTransformMakeTranslation(0, translationY);
}

/**
 *  还原导航栏位置
 */
- (void)ps_setTransformIdentity
{
    self.transform = CGAffineTransformIdentity;
}

/**
 *  设置导航栏上子控件的透明度
 */
- (void)ps_setElementsAlpha:(CGFloat)alpha
{
    [[self valueForKey:@"_leftViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];
    
    [[self valueForKey:@"_rightViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];
    
    UIView *titleView = [self valueForKey:@"_titleView"];
    titleView.alpha = alpha;
    
    //    when viewController first load, the titleView maybe nil
    [[self subviews] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:NSClassFromString(@"UINavigationItemView")]) {
            obj.alpha = alpha;
            *stop = YES;
        }
    }];
}

/**
 *  重置导航栏
 */
- (void)ps_reset
{
    [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.overlayer removeFromSuperview];
    self.overlayer = nil;
}
@end

