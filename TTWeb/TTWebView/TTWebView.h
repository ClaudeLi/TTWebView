//
//  TTWebView.h
//  Tiaooo
//
//  Created by ClaudeLi on 2017/5/26.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTWebView;
@protocol TTWebViewDelegate <NSObject>

@optional

- (void)ttWebViewDidFinishedLoad:(TTWebView *)webView;

- (BOOL)ttWebViewDidClickLoadRequest:(NSURLRequest *)request;

- (void)ttWebViewUpdateNavigationItems:(TTWebView *)webView;

- (void)ttWebViewContentSize:(CGSize)contentSize;

@end

@interface TTWebView : UIView

@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, copy) NSString *HTMLString;

@property (nonatomic, weak) id<TTWebViewDelegate>delegate;

@property (nonatomic, assign) BOOL scrollEnabled;

@property (nonatomic, assign) BOOL isOpenGestures;

@property (nonatomic, strong) UIColor *webViewColor;

@property (nonatomic, readonly) CGSize contentSize;

@property (nonatomic, assign, readonly) BOOL canGoBack;

@property (nonatomic, copy, readonly) NSString *title;

- (void)removeObservers;

- (void)reload;

- (void)goBack;

- (void)stopLoading;

/**
 *  array that hold snapshots
 */
@property (nonatomic)NSMutableArray* snapShotsArray;

/**
 *  current snapshotview displaying on screen when start swiping
 */
@property (nonatomic)UIView* currentSnapShotView;

/**
 *  previous view
 */
@property (nonatomic)UIView* prevSnapShotView;

/**
 *  background alpha black view
 */
@property (nonatomic)UIView* swipingBackgoundView;

/**
 *  left pan ges
 */
@property (nonatomic)UIPanGestureRecognizer* swipePanGesture;

/**
 *  if is swiping now
 */
@property (nonatomic)BOOL isSwipingBack;

@end
