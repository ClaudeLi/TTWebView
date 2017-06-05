//
//  TTWebObject.h
//  Tiaooo
//
//  Created by ClaudeLi on 2017/5/23.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// ios8
#define IOS8    ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0 ? YES : NO)

UIKIT_EXTERN NSString *const TTWebViewContentSize;  // contentSize
UIKIT_EXTERN NSString *const TT_isUIWeb_Key;        // 是否为UIWebView

UIKIT_EXTERN NSString *const TTWebFunctionCall;
UIKIT_EXTERN NSString *const TTWebUserInfoCall;
UIKIT_EXTERN NSString *const TTWebSystemInfoCall;
UIKIT_EXTERN NSString *const TTWebOpenLoginCall;


@interface TTWebObject : NSObject

+ (NSString *)getUIWebViewJSString;
+ (NSString *)getWKWebViewJSString;

+ (NSString *)getJSStringWithFuncName:(NSString *)name parameter:(NSString *)parameter;

+ (id)getSystemInfo;
+ (id)getUserInfo;

// 是否是白名单
BOOL isWhiteHost(NSURL *url);

@end
