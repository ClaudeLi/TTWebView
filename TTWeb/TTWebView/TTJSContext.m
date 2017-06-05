//
//  TTJSContext.m
//  Tiaooo
//
//  Created by ClaudeLi on 16/11/3.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "TTJSContext.h"
#import "UIView+ViewController.h"

@interface TTJSContext ()<UIAlertViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation TTJSContext

- (instancetype)initWithWebView:(UIWebView *)webView{
    self = [super init];
    if (self) {
        _webView = webView;
        self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        [self.jsContext evaluateScript:[TTWebObject getUIWebViewJSString]];
    }
    return self;
}

- (void)setNativeActions{
    __weak __typeof(&*self)weakSelf = self;
    self.jsContext[TTWebFunctionCall] = ^(NSString *type, NSString *data) {
        NSLog(@"type = %@, data = %@", type, data);
        
    };
    
    self.jsContext[TTWebUserInfoCall] = ^(NSString *funcName){
        NSLog(@"获取用户信息->回调函数: %@('用户信息json字符串')", funcName);
        
        [weakSelf.jsContext evaluateScript:[TTWebObject getJSStringWithFuncName:funcName parameter:[TTWebObject getUserInfo]]];
        
    };
    
    self.jsContext[TTWebSystemInfoCall] = ^(NSString *funcName){
        NSLog(@"获取系统信息->回调函数: %@('系统信息json字符串')", funcName);
        
        [weakSelf.jsContext evaluateScript:[TTWebObject getJSStringWithFuncName:funcName parameter:[TTWebObject getSystemInfo]]];
        
    };
    
    self.jsContext[TTWebOpenLoginCall] = ^(NSString *funcName){
        NSLog(@"打开登录页面->登录成功回调函数: %@('用户信息json字符串')", funcName);
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"调用登录" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                // 假如这里是成功 执行回调
                [weakSelf.jsContext evaluateScript:[TTWebObject getJSStringWithFuncName:funcName parameter:[TTWebObject getUserInfo]]];
            }]];
            [weakSelf.webView.viewController presentViewController:alert animated:YES completion:nil];
        }
    };
}

@end
