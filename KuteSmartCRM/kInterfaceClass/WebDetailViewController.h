//
//  WebDetailViewController.h
//  KuteSmartCRM
//
//  Created by kutesmart on 2017/5/10.
//  Copyright © 2017年 redcollar. All rights reserved.
//

#import "K_BasicViewController.h"
#import <NJKWebViewProgress.h>
#import <NJKWebViewProgressView.h>

@interface WebDetailViewController : K_BasicViewController

/**
 * html
 */
@property (nonatomic,copy) NSString *htmlUrl;

@end
