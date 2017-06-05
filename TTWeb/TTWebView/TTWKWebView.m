//
//  TTWKWebView.m
//  Tiaooo
//
//  Created by ClaudeLi on 2017/5/23.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import "TTWKWebView.h"
#import "TTWebObject.h"
#import "UIView+ViewController.h"

static void *TTWKWebBrowserContext = &TTWKWebBrowserContext;
static void *TTWKWebContentSizeContext = &TTWKWebContentSizeContext;

@interface TTWKWebView ()<WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate>

@property (nonatomic, strong) WKWebViewConfiguration *wkConfiguration;

@end

@implementation TTWKWebView

- (WKWebViewConfiguration *)wkConfiguration{
    if (!_wkConfiguration) {
        WKUserScript * cookieScript = [[WKUserScript alloc]
                                       initWithSource:[TTWebObject getWKWebViewJSString]
                                       injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        [userContentController addScriptMessageHandler:self name:TTWebFunctionCall];
        [userContentController addScriptMessageHandler:self name:TTWebUserInfoCall];
        [userContentController addScriptMessageHandler:self name:TTWebSystemInfoCall];
        [userContentController addScriptMessageHandler:self name:TTWebOpenLoginCall];
        [userContentController addUserScript:cookieScript];
        
        configuration.userContentController = userContentController;
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.minimumFontSize = 10;
        preferences.javaScriptEnabled = YES;
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        configuration.preferences = preferences;
        configuration.allowsInlineMediaPlayback=YES;
        _wkConfiguration = configuration;
        
    }
    return _wkConfiguration;
}

- (instancetype)init{
    self = [super initWithFrame:CGRectZero configuration:self.wkConfiguration];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame configuration:self.wkConfiguration];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (void)_initialize{
//    [self evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
//        NSLog(@"%@", result);
//    }];
//    [self evaluateJavaScript:[TTWebObject getWKWebViewJSString] completionHandler:^(id result, NSError *error) {
//        NSLog(@"%@", result);
//    }];
    self.UIDelegate = self;
    self.navigationDelegate = self;
    self.allowsBackForwardNavigationGestures = YES;
    self.clipsToBounds = YES;
    self.opaque = NO;
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:TTWKWebBrowserContext];
    [self.scrollView addObserver:self forKeyPath:TTWebViewContentSize options:0 context:TTWKWebContentSizeContext];
    [self sizeToFit];
}

- (void) setIsHide:(BOOL)IsHide
{
    for (UIView *_aView in [self subviews])
    {
        if ([_aView isKindOfClass:[UIScrollView class]])
        {
            [(UIScrollView *)_aView setShowsVerticalScrollIndicator:NO];
            //右侧的滚动条
            
            [(UIScrollView *)_aView setShowsHorizontalScrollIndicator:NO];
            //下侧的滚动条
            
            for (UIView *_inScrollview in _aView.subviews)
            {
                if ([_inScrollview isKindOfClass:[UIImageView class]])
                {
                    _inScrollview.hidden = YES;  //上下滚动出边界时的黑色的图片
                }
            }
        }
    }
}

- (void)setURLString:(NSString *)URLString{
    _URLString = URLString;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_URLString]];
    [self loadRequest:request];
}

- (void)setHTMLString:(NSString *)HTMLString{
    _HTMLString = HTMLString;
    [self loadHTMLString:_HTMLString baseURL:nil];
}

#pragma mark -
#pragma mark -- KVO & WKUIDelegate --
//KVO监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self) {
        if ([self.ttDelegate respondsToSelector:@selector(ttWKWebViewDidLoadProgress:)]) {
            [self.ttDelegate ttWKWebViewDidLoadProgress:self.estimatedProgress];
        }
    }else if ([keyPath isEqualToString:TTWebViewContentSize] && object == self.scrollView){
        if ([self.ttDelegate respondsToSelector:@selector(ttWKWebViewContentSize:)]) {
            [self.ttDelegate ttWKWebViewContentSize:self.scrollView.contentSize];
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// 页面开始加载时调用
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    if ([self.ttDelegate respondsToSelector:@selector(ttWKWebViewDidStartLoad:)]) {
        [self.ttDelegate ttWKWebViewDidStartLoad:self];
    }
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    if ([self.ttDelegate respondsToSelector:@selector(ttWKWebViewDidCommit:)]) {
        [self.ttDelegate ttWKWebViewDidCommit:self];
    }
}

// 页面加载完成之后调用
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    if ([self.ttDelegate respondsToSelector:@selector(ttWKWebViewDidFinished:)]) {
        [self.ttDelegate ttWKWebViewDidFinished:self];
    }
}

#pragma mark - update nav items
-(void)updateNavigationItems{
    self.userInteractionEnabled = YES;
    if (self.canGoBack) {
        self.viewController.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }else{
        self.viewController.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

// 页面加载失败时调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    if ([self.ttDelegate respondsToSelector:@selector(ttWKWebViewDidFailLoad:)]) {
        [self.ttDelegate ttWKWebViewDidFailLoad:self];
    }
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.targetFrame.mainFrame) {
        if ([self.ttDelegate respondsToSelector:@selector(ttWKWebViewStartLoadNavigationAction:)]) {
            decisionHandler([self.ttDelegate ttWKWebViewStartLoadNavigationAction:navigationAction]);
        }
    }
    // 允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    // 允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    return;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self.viewController presentViewController:alert animated:YES completion:NULL];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(true);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(false);
    }]];
    
    [self.viewController presentViewController:alert animated:YES completion:NULL];
}

#pragma mark -
#pragma mark -- WKScriptMessageHandler --
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if (_URLString && !isWhiteHost(self.URL)) {
        NSLog(@"非白名单域名");
        return;
    }
    //JS调用OC方法
    if ([message.name isEqualToString:TTWebFunctionCall]) {
        NSLog(@"%@", message.body);
        
    } else if ([message.name isEqualToString:TTWebUserInfoCall]){
        NSLog(@"获取用户信息->回调函数: %@('用户信息json字符串')", message.body);
        
        [self evaluateJavaScript:[TTWebObject getJSStringWithFuncName:message.body parameter:[TTWebObject getUserInfo]] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        }];
        
    } else if ([message.name isEqualToString:TTWebSystemInfoCall]){
        NSLog(@"获取系统信息->回调函数: %@('系统信息json字符串')", message.body);
        
        [self evaluateJavaScript:[TTWebObject getJSStringWithFuncName:message.body parameter:[TTWebObject getSystemInfo]] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        }];
        
    } else if ([message.name isEqualToString:TTWebOpenLoginCall]){
        NSLog(@"打开登录页面->登录成功回调函数: %@('用户信息json字符串')", message.body);
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"调用登录" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            // 假如这里是成功 执行回调
            [self evaluateJavaScript:[TTWebObject getJSStringWithFuncName:message.body parameter:[TTWebObject getUserInfo]] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            }];
        }]];
        [self.viewController presentViewController:alert animated:YES completion:nil];
        
    }else{
        NSLog(@"暂不支持 %@", message.body);
    }
}

- (void)removeScriptsAndObservers{
    [self.scrollView removeObserver:self forKeyPath:TTWebViewContentSize];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    if (_wkConfiguration) {
        [self.configuration.userContentController removeScriptMessageHandlerForName:TTWebFunctionCall];
        [self.configuration.userContentController removeScriptMessageHandlerForName:TTWebUserInfoCall];
        [self.configuration.userContentController removeScriptMessageHandlerForName:TTWebSystemInfoCall];
        [self.configuration.userContentController removeScriptMessageHandlerForName:TTWebOpenLoginCall];
    }
}

- (void)dealloc{
    NSLog(@"%s", __func__);
}

@end
