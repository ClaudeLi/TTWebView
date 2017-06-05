
//
//  TTWebViewController.m
//  TTWeb
//
//  Created by ClaudeLi on 2017/6/5.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import "TTWebViewController.h"
#import "TTWebView.h"

@interface TTWebViewController ()<TTWebViewDelegate>

@property (nonatomic, strong) TTWebView *webView;

@end

@implementation TTWebViewController

- (TTWebView *)webView{
    if (!_webView) {
        _webView = [[TTWebView alloc] initWithFrame:CGRectZero];
        _webView.delegate = self;
        _webView.isOpenGestures = YES;
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (void)setURLString:(NSString *)URLString{
    _URLString = URLString;
    self.webView.URLString = _URLString;
}

- (void)setHTMLString:(NSString *)HTMLString{
    _HTMLString = HTMLString;
    self.webView.HTMLString = _HTMLString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)back{
    if (_webView.canGoBack) {
        [_webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark -- TTWebViewDelegate --
- (void)ttWebViewUpdateNavigationItems:(TTWebView *)webView{
    if (self.webView.canGoBack) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)ttWebViewDidFinishedLoad:(TTWebView *)webView{
    self.title = webView.title;
}

- (BOOL)ttWebViewDidClickLoadRequest:(NSURLRequest *)request{
    NSLog(@"%@", request);
    return YES;
}

-(void)ttWebViewContentSize:(CGSize)contentSize{
//    NSLog(@"%@", NSStringFromCGSize(contentSize));
}


- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    CGRect newFrame = self.view.bounds;
    newFrame.origin.y = 64;
    newFrame.size.height = self.view.bounds.size.height - newFrame.origin.y;
    _webView.frame = newFrame;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_webView stopLoading];
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
