//
//  TTUIWebView.m
//  Tiaooo
//
//  Created by ClaudeLi on 2017/5/24.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import "TTUIWebView.h"
#import "UIWebView+TS_JavaScriptContext.h"
#import "NJKWebViewProgress.h"

static void *TTUIWebContentSizeContext = &TTUIWebContentSizeContext;

@interface TTUIWebView ()<UIWebViewDelegate, NJKWebViewProgressDelegate>{
    TTJSContext *_jsContext;
    NSURL       *_URL;
}

@property (nonatomic, copy)   NSString              *filePath;

@property (nonatomic, strong) NJKWebViewProgress    *progressProxy;

@end

@implementation TTUIWebView

-(NJKWebViewProgress *)progressProxy{
    if (!_progressProxy) {
        _progressProxy = [[NJKWebViewProgress alloc] init];
        self.delegate = _progressProxy;
    }
    return _progressProxy;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (void)_initialize{
    self.scalesPageToFit = YES;
    self.progressProxy.webViewProxyDelegate = self;
    self.progressProxy.progressDelegate = self;
    [self.scrollView addObserver:self forKeyPath:TTWebViewContentSize options:0 context:TTUIWebContentSizeContext];
}

- (void)setURLString:(NSString *)URLString{
    _URLString = URLString;
    _URL = [NSURL URLWithString:_URLString];
    NSURLRequest * request = [NSURLRequest requestWithURL:_URL];
    [self loadRequest:request];
}

- (void)setHTMLString:(NSString *)HTMLString{
    _HTMLString = HTMLString;
    
    NSError *error = nil;
    [_HTMLString  writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"error = %@", error);
        [self loadHTMLString:_HTMLString baseURL:nil];
    }else{
        _URL = [NSURL fileURLWithPath:_filePath];
        NSURLRequest * request = [NSURLRequest requestWithURL:_URL];
        [self loadRequest:request];
    }
}

- (NSString *)filePath{
    if (!_filePath) {
        _filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tiaooo.html"];
    }
    return _filePath;
}

- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext*) ctx{
    if (_URLString && !isWhiteHost(_URL)) {
        NSLog(@"非白名单域名");
        return;
    }
    _jsContext = [[TTJSContext alloc] initWithWebView:webView];
    [_jsContext setNativeActions];
}

#pragma mark -
#pragma mark -- UIWebViewDelegate --
- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress{
    if (_URL) {
        if ([self.ttDelegate respondsToSelector:@selector(ttUIWebViewDidLoadProgress:)]) {
            [self.ttDelegate ttUIWebViewDidLoadProgress:progress];
        }
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    if ([self.ttDelegate respondsToSelector:@selector(ttUIWebViewDidStartLoad:)]) {
        [self.ttDelegate ttUIWebViewDidStartLoad:self];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if ([self.ttDelegate respondsToSelector:@selector(ttUIWebViewDidFinished:)]) {
        [self.ttDelegate ttUIWebViewDidFinished:self];
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if ([self.ttDelegate respondsToSelector:@selector(ttUIWebViewDidFailLoad:)]) {
        [self.ttDelegate ttUIWebViewDidFailLoad:self];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([self.ttDelegate respondsToSelector:@selector(ttUIWebViewRequest:navigationType:)]) {
        [self.ttDelegate ttUIWebViewRequest:request navigationType:navigationType];
    }
    return YES;
}

#pragma mark -
#pragma mark -- KVO --
//KVO监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:TTWebViewContentSize] && object == self.scrollView){
        if ([self.ttDelegate respondsToSelector:@selector(ttUIWebViewContentSize:)]) {
            [self.ttDelegate ttUIWebViewContentSize:self.scrollView.contentSize];
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)removeObservers{
    [self.scrollView removeObserver:self forKeyPath:TTWebViewContentSize];
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}


@end
