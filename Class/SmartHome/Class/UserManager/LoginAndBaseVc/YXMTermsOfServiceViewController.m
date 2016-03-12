//
//  YXMTermsOfServiceViewController.m
//  SmartHome
//
//  Created by iroboteer on 15/4/14.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMTermsOfServiceViewController.h"

@interface YXMTermsOfServiceViewController ()

@end

@implementation YXMTermsOfServiceViewController
static NSString * const kJVGithubProjectPage = @"http://usermanager.antbang.com/TermsOfService/TermsOfService.html";
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadWebpage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadWebpage {
    self.loginWebView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    self.loginWebView.delegate = self;
    [self.view addSubview:self.loginWebView];
    
    NSURL *webpageURL = [NSURL URLWithString:kJVGithubProjectPage];
    NSURLRequest *webpageRequest = [NSURLRequest requestWithURL:webpageURL];
    [self.loginWebView loadRequest:webpageRequest];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
