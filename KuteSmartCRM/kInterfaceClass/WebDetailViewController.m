//
//  WebDetailViewController.m
//  KuteSmartCRM
//
//  Created by kutesmart on 2017/5/10.
//  Copyright © 2017年 redcollar. All rights reserved.
//

#import "WebDetailViewController.h"

@interface WebDetailViewController ()<UIWebViewDelegate,NJKWebViewProgressDelegate,UIGestureRecognizerDelegate>
/**
 *  进度条代理
 */
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;
/**
 *  进度条
 */
@property (nonatomic, strong) NJKWebViewProgressView *progressView;
/**
 *  webView
 */
@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) NSURLRequest *request;

/**
 *  返回按钮
 */
@property (nonatomic, strong) UIBarButtonItem *backItem;
//判断是否是HTTPS的
@property (nonatomic, assign) BOOL isAuthed;
/**
 *  关闭按钮
 */
@property (nonatomic, strong) UIBarButtonItem *closeItem;

@end

@implementation WebDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor yellowColor];
    [self addBackButton];
    [self configureForInterface];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.progressView removeFromSuperview];
}

/** 布局*/
- (void)configureForInterface {
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    // 添加进度条
    [self addProgressBar];
    
    self.progressProxy = [[NJKWebViewProgress alloc] init];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight)];
    self.webView.delegate = self.progressProxy;
    self.progressProxy.webViewProxyDelegate = self;
    self.progressProxy.progressDelegate = self;
    [self.view addSubview:self.webView];
    // 禁止弹跳
    for (id aView in [self.webView subviews]) {
        if ([[aView class] isSubclassOfClass:[UIScrollView class]]) {
            [(UIScrollView *)aView setShowsVerticalScrollIndicator:NO];
            [(UIScrollView *)aView setShowsHorizontalScrollIndicator:NO];
            ((UIScrollView *)aView).bounces = NO;
        }
        
    }
    [self loadHTML:self.htmlUrl];
    
}

- (void)loadHTML:(NSString *)htmlString {
    NSURL *url = [NSURL URLWithString:htmlString];
    if ([self.httpType isEqualToString:@"POST"]) {
        /// post 请求html
        NSMutableURLRequest *requestMutable = [NSMutableURLRequest requestWithURL:url];
        NSArray *component = [self.params componentsSeparatedByString:@","];
        NSString *body = nil;
        if ([self.htmlName isEqualToString:@"BPM"]) {
            
            for (NSString *subStr in component) {
                if ([subStr isEqualToString:@"_login_userName"]) {
                    body = [NSString stringWithFormat:@"_login_userName=%@", KUSERNAME];
                } else if ([subStr isEqualToString:@"_login_token"]) {
                    body = [NSString stringWithFormat:@"%@&_login_token=%@", body, KTOKEN];
                }
            }
        }
        NSLog(@"token:%@",KTOKEN);
        [requestMutable setHTTPMethod:@"POST"];
        
        // 在转码之前需要对特殊字符进行处理  否则会出现特殊字符变空的情况
        // @"#%<>[\\]^`{|}\"]+"  代表的意思是需要对这些特殊字符进行转码
        body = [body stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"#%<>[\\]^`{|}\"]+"].invertedSet];
        
        [requestMutable setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
        [self.webView loadRequest:requestMutable];
        
    } else {
        /// 默认get请求
        self.request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
        [self.webView loadRequest:self.request];
    }
    
}

/** 返回按钮*/
- (void)addLeftButton {
    self.navigationItem.leftBarButtonItem = self.backItem;
}

- (void)addProgressBar {
    CGFloat progressBarHeight = 3.0f;
    CGRect navigationBarBound = self.navigationController.navigationBar.bounds;
    self.progressView = [[NJKWebViewProgressView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(navigationBarBound)-progressBarHeight, kDeviceWidth, progressBarHeight)];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;// 自动调整自己的高度，自动调整与superView顶部的距离，保证与superView底部的距离不变；
    [self.navigationController.navigationBar addSubview:self.progressView];
}

#pragma mark - 初始化
- (UIBarButtonItem *)backItem {
    if (!_backItem) {
        
        _backItem = [[UIBarButtonItem alloc] init];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;// 左对齐
        btn.frame = CGRectMake(0, 0, 24, 24);
        _backItem.customView = btn;
    }
    
    return _backItem;
}

- (UIBarButtonItem *)closeItem {
    if (!_closeItem) {
        
        _closeItem = [[UIBarButtonItem alloc] init];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;// 左对齐
        btn.frame = CGRectMake(0, 0, 24, 24);
        _closeItem.customView = btn;
    }

    return _closeItem;
}

- (void)closeClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backClick {
    //判断是否有上一层H5页面
    if ([self.webView canGoBack]) {
        //如果有则返回
        [self.webView goBack];
        //同时设置返回按钮和关闭按钮为导航栏左边的按钮
        self.navigationItem.leftBarButtonItems = @[self.backItem, self.closeItem];
    } else {
        [self closeClick];
    }
}

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    [self.progressView setProgress:progress animated:YES];
    self.navigationItem.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
