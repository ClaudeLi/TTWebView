//
//  TTWebView.m
//  Tiaooo
//
//  Created by ClaudeLi on 2017/5/26.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import "TTWebView.h"
#import "TTWebView+SwipePanGesture.h"
#import "TTUIWebView.h"
#ifdef IOS8
#import "TTWKWebView.h"
#endif

@interface TTWebView ()<TTWKWebViewDelegate, TTUIWebViewDelegate>{
    BOOL _isUIWebView;
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic)       CGSize contentSize;

@property (nonatomic, strong) UIProgressView *progressView;   // 进度
@property (nonatomic, strong) UILabel        *provideLabel;   // 提供者

@property (nonatomic, strong) TTUIWebView *uiWebView;

@property (nonatomic, strong) TTWKWebView *wkWebView;

@end

@implementation TTWebView

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
    if (IOS8) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:TT_isUIWeb_Key]) {
            self.uiWebView.backgroundColor = [UIColor grayColor];
        }else{
            self.wkWebView.backgroundColor = [UIColor grayColor];
        }
    }else{
        self.uiWebView.backgroundColor = [UIColor grayColor];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (_isUIWebView) {
        _uiWebView.frame = self.bounds;
    }else{
        _wkWebView.frame = self.bounds;
    }
}

- (void)setWebViewColor:(UIColor *)webViewColor{
    _webViewColor = webViewColor;
    if (_isUIWebView) {
        _uiWebView.backgroundColor = _webViewColor;
    }else{
        _wkWebView.backgroundColor = _webViewColor;
    }
}

- (void)setIsOpenGestures:(BOOL)isOpenGestures{
    _isOpenGestures = isOpenGestures;
    if (_isOpenGestures) {
        if (!_swipePanGesture) {
            [self addGestureRecognizer:self.swipePanGesture];
        }
    }else{
        if (_swipePanGesture) {
            [self removeGestureRecognizer:_swipePanGesture];
            _swipePanGesture = nil;
        }
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled{
    _scrollEnabled = scrollEnabled;
    if (_isUIWebView) {
        _uiWebView.scrollView.scrollEnabled = _scrollEnabled;
    }else{
        _uiWebView.scrollView.scrollEnabled = _scrollEnabled;
    }
}

- (void)setURLString:(NSString *)URLString{
    _URLString = URLString;
    if (_isUIWebView) {
        _uiWebView.URLString = _URLString;
    }else{
        _wkWebView.URLString = _URLString;
    }
}

- (void)setHTMLString:(NSString *)HTMLString{
    _HTMLString = HTMLString;
    if (_isUIWebView) {
        _uiWebView.HTMLString = _HTMLString;
    }else{
        _wkWebView.HTMLString = _HTMLString;
    }
}

- (BOOL)canGoBack{
    if (_isUIWebView) {
        return _uiWebView.canGoBack;
    }
    return _wkWebView.canGoBack;
}

- (void)reload{
    if (_isUIWebView) {
        [_uiWebView reload];
    }else{
        [_wkWebView reload];
    }
}

- (void)goBack{
    if (_isUIWebView) {
        [_uiWebView goBack];
    }else{
        [_wkWebView goBack];
    }
}

- (void)stopLoading{
    if (_isUIWebView) {
        [_uiWebView stopLoading];
    }else{
        [_wkWebView stopLoading];
    }
}

-(void)updatePopGestureRecognizer{
    if ([self.delegate respondsToSelector:@selector(ttWebViewUpdateNavigationItems:)]) {
        [self.delegate ttWebViewUpdateNavigationItems:self];
    }
}

- (void)setProgress:(CGFloat)progress{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setAlpha:1.0f];
        BOOL animated = progress > self.progressView.progress;
        [self.progressView setProgress:progress animated:animated];
        if(progress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
                if (_provideLabel.hidden) {
                    _provideLabel.hidden = NO;
                }
            }];
        }
    });
}

#pragma mark - 
#pragma mark -- TTWKWebViewDelegate --
- (void)ttWKWebViewDidStartLoad:(TTWKWebView *)webView{
}

- (void)ttWKWebViewDidFailLoad:(TTWKWebView *)webView{
}

- (void)ttWKWebViewDidCommit:(TTWKWebView *)webView{
    [self updatePopGestureRecognizer];
}

- (void)ttWKWebViewDidFinished:(TTWKWebView *)webView{
    self.title = webView.title;
    if ([self.delegate respondsToSelector:@selector(ttWebViewDidFinishedLoad:)]) {
        [self.delegate ttWebViewDidFinishedLoad:self];
    }
    [self updatePopGestureRecognizer];
}

- (WKNavigationActionPolicy)ttWKWebViewStartLoadNavigationAction:(WKNavigationAction *)navigationAction{
    NSURLRequest *request = navigationAction.request;
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        if ([self.delegate respondsToSelector:@selector(ttWebViewDidClickLoadRequest:)]) {
            if (![self.delegate ttWebViewDidClickLoadRequest:request]) {
                return WKNavigationActionPolicyCancel;
            }
        }
    }
    if (([request.URL.scheme hasPrefix:@"http"] || [request.URL.scheme hasPrefix:@"file"]) && ((navigationAction.navigationType == WKNavigationTypeLinkActivated || navigationAction.navigationType == WKNavigationTypeOther)) && [[request.URL description] length] && [request.mainDocumentURL isEqual:request.URL]) {
        if (request.URL.host) {
            self.provideLabel.text = [NSString stringWithFormat:@"网页由 %@ 提供", request.URL.host];
            [self pushCurrentSnapshotViewWithRequest:request];
        }
    }
    return WKNavigationActionPolicyAllow;
}

- (void)ttWKWebViewDidLoadProgress:(CGFloat)progress{
    [self setProgress:progress];
}

- (void)ttWKWebViewContentSize:(CGSize)contentSize{
    self.contentSize = contentSize;
    if ([self.delegate respondsToSelector:@selector(ttWebViewContentSize:)]) {
        [self.delegate ttWebViewContentSize:contentSize];
    }
}

#pragma mark -
#pragma mark -- TTUIWebViewDelegate --
- (void)ttUIWebViewDidStartLoad:(TTUIWebView *)webView{
}

- (void)ttUIWebViewDidFailLoad:(TTUIWebView *)webView{
}

- (void)ttUIWebViewDidFinished:(TTUIWebView *)webView{
    if (webView.request.URL.host) {
        self.provideLabel.text = [NSString stringWithFormat:@"网页由 %@ 提供", webView.request.URL.host];
    }
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ([self.delegate respondsToSelector:@selector(ttWebViewDidFinishedLoad:)]) {
        [self.delegate ttWebViewDidFinishedLoad:self];
    }
    [self updatePopGestureRecognizer];
}

- (BOOL)ttUIWebViewRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if ([self.delegate respondsToSelector:@selector(ttWebViewDidClickLoadRequest:)]) {
            if (![self.delegate ttWebViewDidClickLoadRequest:request]) {
                return NO;
            }
        }
    }
    if (([request.URL.scheme hasPrefix:@"http"] || [request.URL.scheme hasPrefix:@"file"]) && ((navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeOther)) && [[request.URL description] length] && [request.mainDocumentURL isEqual:request.URL]) {
        if (request.URL.host) {
            self.provideLabel.text = [NSString stringWithFormat:@"网页由 %@ 提供", request.URL.host];
            [self pushCurrentSnapshotViewWithRequest:request];
        }
    }
    return YES;
}

- (void)ttUIWebViewDidLoadProgress:(CGFloat)progress{
    [self setProgress:progress];
}

- (void)ttUIWebViewContentSize:(CGSize)contentSize{
    self.contentSize = contentSize;
    if ([self.delegate respondsToSelector:@selector(ttWebViewContentSize:)]) {
        [self.delegate ttWebViewContentSize:contentSize];
    }
}

#pragma mark --
#pragma mark -- 懒加载 --
- (TTUIWebView *)uiWebView{
    if (!_uiWebView) {
        _uiWebView = [[TTUIWebView alloc] initWithFrame:CGRectZero];
        _uiWebView.ttDelegate = self;
        _isUIWebView = YES;
        [self addSubview:_uiWebView];
    }
    return _uiWebView;
}

- (TTWKWebView *)wkWebView{
    if (!_wkWebView) {
        _wkWebView = [[TTWKWebView alloc] initWithFrame:CGRectZero];
        _wkWebView.ttDelegate = self;
        _isUIWebView = NO;
        [self addSubview:_wkWebView];
    }
    return _wkWebView;
}

- (UILabel *)provideLabel{
    if (!_provideLabel) {
        _provideLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _provideLabel.textColor = [UIColor blackColor];
        _provideLabel.font = [UIFont systemFontOfSize:12];
        _provideLabel.textAlignment = NSTextAlignmentCenter;
        _provideLabel.hidden = YES;
        _provideLabel.frame = CGRectMake(0, 0, self.bounds.size.width, 30);
        if (_isUIWebView) {
            [_uiWebView insertSubview:_provideLabel atIndex:0];
        }else{
            [_wkWebView insertSubview:_provideLabel atIndex:0];
        }
    }
    return _provideLabel;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(0, 0, self.bounds.size.width, 1);
        // 设置进度条的色彩
        [_progressView setTrackTintColor:[UIColor clearColor]];
        _progressView.progressTintColor = [UIColor greenColor];
        [self addSubview:_progressView];
    }
    return _progressView;
}

-(UIView*)swipingBackgoundView{
    if (!_swipingBackgoundView) {
        _swipingBackgoundView = [[UIView alloc] initWithFrame:self.bounds];
        _swipingBackgoundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _swipingBackgoundView;
}

-(NSMutableArray*)snapShotsArray{
    if (!_snapShotsArray) {
        _snapShotsArray = [NSMutableArray array];
    }
    return _snapShotsArray;
}

-(UIPanGestureRecognizer*)swipePanGesture{
    if (!_swipePanGesture) {
        _swipePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipePanGestureHandler:)];
    }
    return _swipePanGesture;
}

-(void)swipePanGestureHandler:(UIPanGestureRecognizer*)panGesture{
    CGPoint translation = [panGesture translationInView:self];
    CGPoint location = [panGesture locationInView:self];
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (location.x <= 200 && translation.x >= 0) {  //开始动画
            [self startPopSnapshotView];
        }
    }else if (panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateEnded){
        [self endPopSnapShotView];
    }else if (panGesture.state == UIGestureRecognizerStateChanged){
        [self popSnapShotViewWithPanGestureDistance:translation.x];
    }
}

- (void)removeObservers{
    if (_isUIWebView) {
        if (_uiWebView) {
            [_uiWebView removeObservers];
            [_uiWebView removeFromSuperview];
            _uiWebView = nil;
        }
    }else{
        if (_wkWebView) {
            [_wkWebView removeScriptsAndObservers];
            [_wkWebView removeFromSuperview];
            _wkWebView = nil;
        }
    }
}

-(void)dealloc{
    NSLog(@"%s", __func__);
    [self removeObservers];
}

@end
