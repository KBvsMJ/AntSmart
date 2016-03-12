//
//  webViewController.h
//
//
//  Created by yixingman on 12-8-29.
//  Copyright (c) 2012年 yixingman. All rights reserved.
//

#import "Config.h"
#import "NewsWebViewController.h"
#import "AppDelegate.h"
#import "JVFloatingDrawerViewController.h"



@interface NewsWebViewController ()
@end
@implementation NewsWebViewController




-(void)reloadWebviewurl:(NSString *)url andTitle:(NSString *)title
{
    //导航栏标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:17];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel setText:title];
    [self.navigationItem setTitleView:titleLabel];
    
    if (!webview) {
        webview  = [[UIWebView alloc] initWithFrame:CGRectMake( 0,  0,  self.view.frame.size.width , self.view.frame.size.height)];
        webview.scalesPageToFit = TRUE;
        [webview setUserInteractionEnabled: YES ];	 //是否支持交互
        [webview setDelegate:self];				 //委托
        [webview setOpaque:YES];					 //透明
        [self.view addSubview:webview];
    }
    
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}


-(void)webViewDidStartLoad:(UIWebView *)webView
{
    DLog(@"webView开始加载");
    [self startDejalBezelActivityView:@"页面加载中"];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    DLog(@"webView加载成功");
    [self stopDegalBezeActivityView];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    DLog(@"webView加载失败");
    [self stopDegalBezeActivityView];
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    //关闭按钮
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbar_small"] style:UIBarButtonItemStylePlain target:self action:@selector(closeNotiPage:)];
    [rightItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:rightItem];
}

/**
 *  关闭推送通知信息显示页面
 *
 *  @param sender 右上角回到主页按钮
 */
-(void)closeNotiPage:(UIBarButtonItem *)sender{
    [[AppDelegate globalDelegate] intoMain];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end


