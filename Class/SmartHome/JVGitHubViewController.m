//
//  JVCenterViewController.m
//  JVFloatingDrawer
//
//  Created by yixingman on 2015-01-15.
//  Copyright (c) 2015 antbang. All rights reserved.
//

#import "JVGitHubViewController.h"
#import "AppDelegate.h"
#import "JVFloatingDrawerViewController.h"

@interface JVGitHubViewController ()

@property (strong, nonatomic) UIWebView *webview;

@end

@implementation JVGitHubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"guanyu", @"关于");
    [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"navbar_small"]];
    [self loadWebpage];
}

- (void)loadWebpage {
    
    self.webview = [[UIWebView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.webview];
    
    
    NSString* strLanguage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
    NSString *aboutHtmlPath;
    if ([strLanguage isEqualToString:@"zh-Hans"]) {
        aboutHtmlPath = [[NSBundle mainBundle]pathForResource:@"about" ofType:@"html"];
    }else{
        aboutHtmlPath = [[NSBundle mainBundle]pathForResource:@"about" ofType:@"html"];
    }
    
    NSString *htmlString = [NSString stringWithContentsOfFile:aboutHtmlPath encoding:NSUTF8StringEncoding error:nil];
    if (htmlString) {
        [self.webview loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    }

}

#pragma mark - Actions

- (IBAction)actionToggleLeftDrawer:(id)sender {
    
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (IBAction)actionToggleRightDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:[[AppDelegate globalDelegate] drawerSettingsViewController]];
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

@end
