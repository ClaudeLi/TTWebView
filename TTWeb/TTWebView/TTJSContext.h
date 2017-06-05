//
//  TTJSContext.h
//  Tiaooo
//
//  Created by ClaudeLi on 16/11/3.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "TTWebObject.h"

@interface TTJSContext : NSObject

@property (nonatomic, strong) JSContext *jsContext;

- (instancetype)initWithWebView:(UIWebView *)webView;

- (void)setNativeActions;

@end
