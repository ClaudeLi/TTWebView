//
//  TTWKWebView.h
//  Tiaooo
//
//  Created by ClaudeLi on 2017/5/23.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class TTWKWebView;
@protocol TTWKWebViewDelegate <NSObject>

- (void)ttWKWebViewDidStartLoad:(TTWKWebView *)webView;
- (void)ttWKWebViewDidFailLoad:(TTWKWebView *)webView;
- (void)ttWKWebViewDidCommit:(TTWKWebView *)webView;
- (void)ttWKWebViewDidFinished:(TTWKWebView *)webView;
- (WKNavigationActionPolicy)ttWKWebViewStartLoadNavigationAction:(WKNavigationAction *)navigationAction;

- (void)ttWKWebViewDidLoadProgress:(CGFloat)progress;
- (void)ttWKWebViewContentSize:(CGSize)contentSize;

@end

@interface TTWKWebView : WKWebView

@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, copy) NSString *HTMLString;

@property (nonatomic, weak) id<TTWKWebViewDelegate>ttDelegate;

- (void)removeScriptsAndObservers;

@end
