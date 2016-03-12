//
//  YXMShopIndexViewController.m
//  SmartHome
//
//  Created by iroboteer on 6/4/15.
//  Copyright (c) 2015 iroboteer. All rights reserved.
//

#import "YXMShopIndexViewController.h"
#import "AppDelegate.h"
#import "JVFloatingDrawerViewController.h"

@interface YXMShopIndexViewController ()

@property (strong, nonatomic) UIWebView *webview;

@end

@implementation YXMShopIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configNavigationBar];
    [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"navbar_small"]];
    [self loadWebpage];
}

- (void)loadWebpage {
    self.webview = [[UIWebView alloc]initWithFrame:self.view.bounds];
    [self.webview setDelegate:self];
    [self.view addSubview:self.webview];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mybsm.m.tmall.com"]]];
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [self startDejalBezelActivityView:@"加载中"];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopDegalBezeActivityView];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self stopDegalBezeActivityView];
}

#pragma mark - Actions

- (void)actionToggleLeftDrawer:(id)sender {
    
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (void)actionToggleRightDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:[[AppDelegate globalDelegate] drawerSettingsViewController]];
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

/**
 *  定义导航栏的文字、颜色、按钮
 */
-(void)configNavigationBar{
    //设置视图背景色，视图的背景色默认为透明
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIBarButtonItem *leftbarbtn=[[UIBarButtonItem alloc]
                                 initWithImage:[UIImage imageNamed:@"399-list1"]
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(actionToggleLeftDrawer:)];
    [leftbarbtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftbarbtn;
    
    UIBarButtonItem *rightbarbtn = [[UIBarButtonItem alloc]
                                    initWithImage:[UIImage imageNamed:@"navbar_small"]
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(actionToggleRightDrawer:)];
    [rightbarbtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = rightbarbtn;
    
    //自定义导航栏文字的样式
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithWhite:0.984 alpha:1.000], NSForegroundColorAttributeName,[UIColor colorWithWhite:0.996 alpha:1.000], NSBackgroundColorAttributeName,[NSValue valueWithUIOffset:UIOffsetMake(0, 0)], NSBaselineOffsetAttributeName,[UIFont fontWithName:@"Arial-Bold" size:0.0], NSFontAttributeName,nil]];
    
    
    //导航栏颜色
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000]];
    self.title = @"智能设备商城";
    self.navigationController.navigationBar.translucent = NO;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
