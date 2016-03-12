//
//  ConfigViewController.m
//  WiFiSwitch2
//
//  Created by sunrun on 14-10-13.
//  Copyright (c) 2014年 sunrun. All rights reserved.
//

#import "ConfigViewController.h"
#import "AppDelegate.h"
#import "Config.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "JVFloatingDrawerViewController.h"
#import "MyTool.h"
#import "YXMManualViewController.h"
#import "YXMAutoConfigPlugViewController.h"
#import "IPHelpler.h"


@interface ConfigViewController ()

@end

@implementation ConfigViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)showLeftPage:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}
- (void)showRightPage:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:[[AppDelegate globalDelegate] drawerSettingsViewController]];
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configNavigationBar];
    [self configPlugView];
    // 下一个界面的返回按钮
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"返回";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    [NSTimer scheduledTimerWithTimeInterval:.5f target:self selector:@selector(flickerPlugLight:) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRightPage:) name:@"closecurrentpage" object:nil];
}

/**
 *  定义插座配置视图
 */
-(void)configPlugView{
    UIScrollView *configBaseView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:configBaseView];
    
    CGFloat topOffsetHeight = 44.0f;
    //主提示
    UILabel *mainPromptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, topOffsetHeight, self.view.frame.size.width, 44)];
    [mainPromptLabel setBackgroundColor:[UIColor clearColor]];
    [mainPromptLabel setText:@"请将蚁插座接通电源"];
    [mainPromptLabel setTextColor:[UIColor grayColor]];
    [mainPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [mainPromptLabel setFont:[UIFont systemFontOfSize:24 weight:20]];
    [configBaseView addSubview:mainPromptLabel];
    //副提示
    UILabel *subPromptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, mainPromptLabel.frame.origin.y + mainPromptLabel.frame.size.height + 5, self.view.frame.size.width, 20)];
    [subPromptLabel setBackgroundColor:[UIColor clearColor]];
    [subPromptLabel setText:@"蓝灯快闪时点击下一步"];
    [subPromptLabel setTextColor:[UIColor grayColor]];
    [subPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [subPromptLabel setFont:[UIFont systemFontOfSize:16 weight:10]];
    [configBaseView addSubview:subPromptLabel];
    //插座图标
    CGFloat fPlugImageViewWidth = SCREEN_CGSIZE_WIDTH/2.0f;
    CGFloat fPlugImageViewX = (SCREEN_CGSIZE_WIDTH - fPlugImageViewWidth)/2.0f;
    _plugImageView = [[UIImageView alloc]initWithFrame:CGRectMake(fPlugImageViewX, subPromptLabel.frame.size.height+subPromptLabel.frame.origin.y + 20, fPlugImageViewWidth, fPlugImageViewWidth)];
    [_plugImageView setImage:[UIImage imageNamed:@"virtual_device"]];
    [configBaseView addSubview:_plugImageView];
    //取消按钮
    CGFloat fCancelButtonX = SCREEN_CGSIZE_WIDTH/4.0f;
    CGFloat fButtonWidth = SCREEN_CGSIZE_WIDTH/4.0f;
    UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(fCancelButtonX, _plugImageView.frame.origin.y + _plugImageView.frame.size.height + 44, fButtonWidth, 40)];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton.layer setBorderColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000].CGColor];
    [cancelButton.layer setBorderWidth:0.6f];
    [cancelButton setTitleColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000] forState:UIControlStateNormal];
    [cancelButton setTitle:[Config DPLocalizedString:@"cancel"] forState:UIControlStateNormal];
    [configBaseView addSubview:cancelButton];
    //下一步按钮
    UIButton *nextButton = [[UIButton alloc]initWithFrame:CGRectMake(cancelButton.frame.origin.x+cancelButton.frame.size.width, cancelButton.frame.origin.y, fButtonWidth, cancelButton.frame.size.height)];
    [nextButton addTarget:self action:@selector(nextButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton.layer setBorderColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000].CGColor];
    [nextButton.layer setBorderWidth:0.6f];
    [nextButton setTitleColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000] forState:UIControlStateNormal];
    [nextButton setTitle:[Config DPLocalizedString:@"nextButtonTitle"] forState:UIControlStateNormal];
    [configBaseView addSubview:nextButton];
}


-(void)flickerPlugLight:(NSTimer *)timer{
    if (_isLight) {
        [_plugImageView setImage:[UIImage imageNamed:@"virtual_device_light"]];
        _isLight = NO;
    }else{
        [_plugImageView setImage:[UIImage imageNamed:@"virtual_device"]];
        _isLight = YES;
    }
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
                                 action:@selector(showLeftPage:)];
    [leftbarbtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftbarbtn;
    
    UIBarButtonItem *rightbarbtn = [[UIBarButtonItem alloc]
                                    initWithImage:[UIImage imageNamed:@"navbar_small"]
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(showRightPage:)];
    [rightbarbtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = rightbarbtn;
    
    //自定义导航栏文字的样式
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithWhite:0.984 alpha:1.000], NSForegroundColorAttributeName,[UIColor colorWithWhite:0.996 alpha:1.000], NSBackgroundColorAttributeName,[NSValue valueWithUIOffset:UIOffsetMake(0, 0)], NSBaselineOffsetAttributeName,[UIFont fontWithName:@"Arial-Bold" size:0.0], NSFontAttributeName,nil]];
    
    
    //导航栏颜色
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000]];
    self.title = @"配置插座";
    self.navigationController.navigationBar.translucent = NO;
}






-(void)nextButtonClick:(UIButton *)sender{
    [self getSSIDAndPassword];
}

-(void)getSSIDAndPassword{
    //如果未登录则进行登录操作
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *pwdString = [ud objectForKey:KEY_OF_ROUTER_PASSWORD];
    if ([pwdString length]<1) {
        pwdString = @"";
    }
    NSDictionary *parameters = @{@"Username":@"admin",@"checkEn": @"0",@"Password":pwdString};
    
    NSString *routerDomain = [IPHelpler getGatewayIPAddress];
    NSString *url_login_router = [ud objectForKey:URL_LOGIN_ROUTER];
    [manager POST:[NSString stringWithFormat:@"%@%@",routerDomain,url_login_router] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"operation.response.URL = %@",operation.response.URL);
        NSString *sLoginRouterReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        DLog(@"sLoginRouterReturnCode: %@", sLoginRouterReturnCode);
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if ([sLoginRouterReturnCode rangeOfString:@"ssid000 ="].location != NSNotFound) {
            //wifi名称
            NSString *ssidString = [MyTool getSSIDWithString:sLoginRouterReturnCode];
            //wifi密码
            NSString *pwdString = [MyTool getWIFIPassword:sLoginRouterReturnCode];
            [ud setObject:pwdString forKey:KEY_OF_WIFI_PASSWORD];
            [ud setObject:ssidString forKey:KEY_ROUTER_SSID];
            [ud setBool:YES forKey:KEY_OF_ISLOGIN];
            [ud synchronize];
            //进入自动配置插座的界面
            [self intoAutoConfigView];
        }else{
            [ud setBool:NO forKey:KEY_OF_ISLOGIN];
            [ud synchronize];
            //进入手动配置插座的界面
            [self intoManualConfigView];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Error: %@", error);
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@"未连接" forKey:NET_CONNECT_STATE];
        [ud synchronize];
        //进入手动配置插座的界面
        [self intoManualConfigView];
    }];
}


/**
 *  当成功获得无线的名称和密码的时候直接进入自动配置页面
 */
-(void)intoAutoConfigView{
    if (!_autoConfigConfigCtrl) {
        _autoConfigConfigCtrl = [[YXMAutoConfigPlugViewController alloc]init];
    }
    [_autoConfigConfigCtrl initConfigView];
    [self.navigationController pushViewController:_autoConfigConfigCtrl animated:YES];
}

/**
 *  进入手动配置的页面，需要用户输入当前wifi的密码之后点击配置
 */
-(void)intoManualConfigView{
    if (!_manualConfigCtrl) {
        _manualConfigCtrl = [[YXMManualViewController alloc]init];
    }
    [self.navigationController pushViewController:_manualConfigCtrl animated:YES];
}

-(void)cancelButtonClick:(UIButton *)sender{
    [self showRightPage:nil];
}

@end
