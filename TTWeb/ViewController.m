//
//  ViewController.m
//  TTWeb
//
//  Created by ClaudeLi on 2017/6/5.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import "ViewController.h"
#import "TTWebObject.h"
#import "TTWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)gotoWebView:(id)sender {
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"test" ofType:@"html"];
    NSURL *URL = [NSURL fileURLWithPath:filePath];
    [self gotoWebWithURLString:URL.absoluteString];
}

- (IBAction)gotoWebView2:(id)sender {
    [self gotoWebWithURLString:@"http://www.baidu.com"];
}

- (void)gotoWebWithURLString:(NSString *)string{
    TTWebViewController *web = [[TTWebViewController alloc] init];
    web.URLString = string;
    [self.navigationController pushViewController:web animated:YES];
}

- (IBAction)switchWeb:(id)sender {
    if (IOS8){
        BOOL oldIsUIWeb = [[NSUserDefaults standardUserDefaults] boolForKey:TT_isUIWeb_Key];
        [[NSUserDefaults standardUserDefaults] setBool:!oldIsUIWeb forKey:TT_isUIWeb_Key];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Switch to %@", oldIsUIWeb?@"WKWebView":@"UIWebView"] message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
