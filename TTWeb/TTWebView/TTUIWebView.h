//
//  TTUIWebView.h
//  Tiaooo
//
//  Created by ClaudeLi on 2017/5/24.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTJSContext.h"

@class TTUIWebView;
@protocol TTUIWebViewDelegate <NSObject>

@optional

- (void)ttUIWebViewDidStartLoad:(TTUIWebView *)webView;
- (void)ttUIWebViewDidFailLoad:(TTUIWebView *)webView;
- (void)ttUIWebViewDidFinished:(TTUIWebView *)webView;

- (BOOL)ttUIWebViewRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;

- (void)ttUIWebViewDidLoadProgress:(CGFloat)progress;
- (void)ttUIWebViewContentSize:(CGSize)contentSize;

@end

@interface TTUIWebView : UIWebView

@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, copy) NSString *HTMLString;

@property (nonatomic, weak) id<TTUIWebViewDelegate>ttDelegate;

- (void)removeObservers;

@end
