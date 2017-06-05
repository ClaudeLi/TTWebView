//
//  TTWebObject.m
//  Tiaooo
//
//  Created by ClaudeLi on 2017/5/23.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import "TTWebObject.h"

NSString *const TTWebViewContentSize = @"contentSize";
NSString *const TT_isUIWeb_Key       = @"TT_isUIWeb_Key";

NSString *const TTWebFunctionCall   = @"TiaoooCall";
NSString *const TTWebUserInfoCall   = @"TiaoooUserInfoCall";
NSString *const TTWebSystemInfoCall = @"TiaoooSystemInfoCall";
NSString *const TTWebOpenLoginCall  = @"TiaoooOpenLoginCall";

/*
 // 与服务器约定好的对象.函数
    window.TTHybrid = {
        open: function (type, id) {},
        getUserData: function () {},
        getSystemData: function () {},
        openLogin: function (name) {},
        }
 */

static NSString *PromiseObject = @"TTHybrid"; // 约定的对象名

@implementation TTWebObject

+ (NSString *)getUIWebViewJSString{
    return [NSString stringWithFormat:
            @"\
            var %@ = {\
                open: function (type, id) {\
                    %@(type, id);\
                },\
                getUserData: function (funcName) {\
                    %@(funcName);\
                },\
                getSystemData: function (funcName) {\
                    %@(funcName);\
                },\
                openLogin: function (funcName) {\
                    %@(funcName);\
                },\
            }\
            ", PromiseObject, TTWebFunctionCall, TTWebUserInfoCall, TTWebSystemInfoCall, TTWebOpenLoginCall];
}

+ (NSString *)getWKWebViewJSString{
    return [NSString stringWithFormat:
            @"\
            var %@ = {\
                open: function (type, id) {\
                    window.webkit.messageHandlers.%@.postMessage({type:type, id:id});\
                },\
                getUserData: function (funcName) {\
                    window.webkit.messageHandlers.%@.postMessage(funcName);\
                },\
                getSystemData: function (funcName) {\
                    window.webkit.messageHandlers.%@.postMessage(funcName);\
                },\
                openLogin: function (funcName) {\
                    window.webkit.messageHandlers.%@.postMessage(funcName);\
                },\
            };\
            ", PromiseObject, TTWebFunctionCall, TTWebUserInfoCall, TTWebSystemInfoCall, TTWebOpenLoginCall];
}

+ (NSString *)getJSStringWithFuncName:(NSString *)name parameter:(NSString *)parameter{
    return [NSString stringWithFormat:@"%@.%@('%@')", PromiseObject, name, parameter];
}

+ (id)getSystemInfo{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    dict[@"platform"]           = @"ios";
    dict[@"appVersion"]         = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    dict[@"systemVersion"]      = [[UIDevice currentDevice] systemVersion];
    dict[@"uuid"]               = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return [self getJsonStringWith:dict];
}

+ (id)getUserInfo{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    dict[@"userName"]           = @"TEST001";
    dict[@"sex"]                = @"男";
    dict[@"uid"]                = @"123";
    dict[@"face"]               = @"http://pic.58pic.com/58pic/13/60/91/42P58PIChDU_1024.jpg";
    return  [self getJsonStringWith:dict];
}

+ (NSString *)getJsonStringWith:(id)object{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return @"";
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0, jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0, mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}


// 是否是白名单
BOOL isWhiteHost(NSURL *url){
    if ([url.host hasSuffix:@"tiaooo.com"] || [url.scheme hasPrefix:@"file"]) {
        return YES;
    }
    return NO;
}

@end
