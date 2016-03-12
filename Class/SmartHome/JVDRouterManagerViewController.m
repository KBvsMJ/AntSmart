//
//  JVDrawerSettingsTableViewController.m
//  JVFloatingDrawer
//
//  Created by yixingman on 2015-01-15.
//  Copyright (c) 2015 antbang. All rights reserved.
//

#import "JVDRouterManagerViewController.h"
#import "AppDelegate.h"
#import "UIView+Shadow.h"
#import "APService.h"
//蹭网管理
#import "ZJLViewController.h"
//网络优化
#import "YXMOptimizeNetViewController.h"
//穿墙提速
#import "YXMSpeedAdjustmentViewController.h"
//万能中继
#import "YXMRelayViewController.h"
//WiFi设置
#import "YXMWiFiSetupViewController.h"
//上网设置
#import "YXMWanSetupViewController.h"
//wifi开关
#import "YXMWiFiSwitchViewController.h"

#import "CurveGraphController.h"
#import "IPHelpler.h"
#import "JVFloatingDrawerViewController.h"
#import "YXM_RouterAuthenticationModel.h"
#import "MyReachability.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "Config.h"
#import "MLTableAlert.h"
#import "TFHpple.h"
#import <iToast/iToast.h>
#import "MyTool.h"
#import "YXMDatabaseOperation.h"
#import "YXMMyRouterModel.h"
#import "YXMTrafficStatistics.h"


#define TAG_BUTTON_BASE 100000
#define TAG_FUNCTION_SCROLLVIEW 100020

@interface JVDRouterManagerViewController ()
{
    UIImageView *_disconnectView;
}
@end

@implementation JVDRouterManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    UIImageView *_backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_backgroundImageView setImage:[UIImage imageNamed:@"主页背景图"]];
    [self.view insertSubview:_backgroundImageView atIndex:0];
    [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"navbar_small"]];
    [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"399-list1"]];
    
    self.title = NSLocalizedString(@"routerManager", @"路由器管理");
    
    CGFloat selfViewHeight = (self.view.frame.size.height);
    
    //顶部登陆以及状态信息
    UIView *_topView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, (SCREEN_CGSIZE_HEIGHT-(self.view.frame.size.width/3.0)*2.0-64))];
    [_topView setUserInteractionEnabled:YES];
    
    //显示路由器的连接状态和网速
    [self createRouterFunctionGuideViewWithSupserView:_topView];
    //显示路由器的图标和路由器登录的状态以及路由器的SSID
    [self createRouterHeadAndLoginViewWithSuperView:_topView];

    [self.view addSubview:_topView];
    
    //功能区域的滚动视图
    //左右滑动的视图的页数
    NSInteger scrollPageNumber = 0;
    CGFloat width_base_view = self.view.frame.size.width/3.0;
    UIScrollView *baseScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, (selfViewHeight-(self.view.frame.size.width/3.0)*2.0), SCREEN_CGSIZE_WIDTH, width_base_view*2)];
    [baseScrollView setBackgroundColor:[UIColor colorWithRed:0.851 green:0.824 blue:0.749 alpha:1.000]];
    [baseScrollView setContentSize:CGSizeMake(SCREEN_CGSIZE_WIDTH * scrollPageNumber, width_base_view*2)];
    [baseScrollView setShowsHorizontalScrollIndicator:YES];
    [self.view addSubview:baseScrollView];
    
    
    NSArray *buttonTitleArray = [[NSArray alloc]initWithObjects:NSLocalizedString(@"zhongjiecengwang",@"终结蹭网"),NSLocalizedString(@"chuanqiangtisu",@"穿墙提速"),NSLocalizedString(@"WiFishezhi",@"WiFi设置"),NSLocalizedString(@"wannengzhongji",@"万能中继"),NSLocalizedString(@"wangluoyouhua",@"网络优化"),NSLocalizedString(@"shangwangshezhi",@"上网设置"),nil];
    NSArray *buttonIconArray = [[NSArray alloc]initWithObjects:@"终结蹭网",@"穿墙提速",@"WiFi设置",@"万能中继",@"网络优化",@"设置上网", nil];
    
    CGFloat height_base_view = width_base_view*0.95;
    CGFloat width_head_image = width_base_view;
    NSInteger button_index = 0;
    for (int i=0; i<3; i++) {
        for (int k=0; k<2; k++) {
            [baseScrollView addSubview:[self routerManagerFunctionButton:(i*width_base_view) andwbv:width_base_view andk:k andhbv:height_base_view andwhi:width_head_image andBia:buttonIconArray andBta:buttonTitleArray andbi:button_index andTag:TAG_BUTTON_BASE+button_index]];
            button_index ++;
        }
    }
    
    [baseScrollView setDelegate:self];
    [baseScrollView setPagingEnabled:YES];
    [baseScrollView setTag:TAG_FUNCTION_SCROLLVIEW];
    [self.view addSubview:baseScrollView];
    
    
//    NSArray *buttonTitleArray1 = [[NSArray alloc]initWithObjects:NSLocalizedString(@"WiFi开关",@"WiFi开关"),NSLocalizedString(@"更多功能",@"更多功能"),nil];
//    NSArray *buttonIconArray1 = [[NSArray alloc]initWithObjects:@"WiFi开关",@"更多", nil];
//
//    NSInteger button_index1 = 0;
//    for (int i=0; i<2; i++) {
//        for (int k=0; k<1; k++) {
//            [baseScrollView addSubview:[self routerManagerFunctionButton:(SCREEN_CGSIZE_WIDTH + i*width_base_view) andwbv:width_base_view andk:k andhbv:height_base_view andwhi:width_head_image andBia:buttonIconArray1 andBta:buttonTitleArray1 andbi:button_index1 andTag:TAG_BUTTON_BASE+button_index1+6]];
//            button_index1 ++;
//        }
//    }
//    
//    
//    _myPageCtrl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, selfViewHeight-20, SCREEN_CGSIZE_WIDTH, 20)];
//    [_myPageCtrl setNumberOfPages:2];
//    [_myPageCtrl setCurrentPage:0];
//    [_myPageCtrl setCurrentPageIndicatorTintColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000]];
//    [_myPageCtrl setPageIndicatorTintColor:[UIColor grayColor]];
//    [self.view addSubview:_myPageCtrl];
    

    
    UIImageView *line2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, baseScrollView.frame.size.width, 2)];
    [line2 setImage:[UIImage imageNamed:@"渐变线"]];
    [baseScrollView addSubview:line2];
    
    
   
    
    //登陆到路由器
    BOOL isLogin = [ud boolForKey:KEY_OF_ISLOGIN];
    if (!isLogin) {
        YXM_RouterAuthenticationModel *routerAuth = [YXM_RouterAuthenticationModel sharedManager];
        [routerAuth loginRouter];
    }

    // 下一个界面的返回按钮
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"返回";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
    
    //更新网速标签
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateSelectSpeed) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetSpeed:) name:NOTI_UPDATE_NET_SPEED object:nil];
    
    //监控网络的状态
    [self initReachability];
}


-(UIView *)routerManagerFunctionButton:(CGFloat)x andwbv:(CGFloat)width_base_view andk:(NSInteger)k andhbv:(CGFloat)height_base_view andwhi:(CGFloat)width_head_image andBia:(NSArray *)buttonIconArray1 andBta:(NSArray *)buttonTitleArray1 andbi:(NSInteger)button_index1 andTag:(NSInteger)tagi{
    UIView *baseView = [[UIView alloc]initWithFrame:CGRectMake(x, k*height_base_view, width_base_view, height_base_view)];
    CGFloat scale = 0.582;
    UIImageView *headImageView = [[UIImageView alloc]initWithFrame:CGRectMake((baseView.frame.size.width-width_head_image*scale)/2, (baseView.frame.size.width-width_head_image*scale)/4, width_head_image*scale, width_head_image*scale)];
    [headImageView setImage:[UIImage imageNamed:[buttonIconArray1 objectAtIndex:button_index1]]];
    
    [baseView addSubview:headImageView];
    
    CGFloat titleLabelHeight = (0.3)*width_base_view;
    UILabel *headLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, headImageView.frame.size.height+headImageView.frame.origin.y, baseView.frame.size.width, titleLabelHeight)];
    [headLabel setBackgroundColor:[UIColor clearColor]];
    [headLabel setText:[buttonTitleArray1 objectAtIndex:button_index1]];
    [headLabel setTextAlignment:NSTextAlignmentCenter];
    [headLabel setTextColor:[UIColor blackColor]];
    [headLabel setFont:[UIFont systemFontOfSize:16]];
    [headLabel setAdjustsFontSizeToFitWidth:YES];
    [baseView addSubview:headLabel];
    
    
    UIButton *b1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, baseView.frame.size.width, baseView.frame.size.height)];
    [b1 setBackgroundColor:[UIColor clearColor]];
    [b1 setTag:tagi];
    [b1 addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:b1];
    
    return baseView;
}

/**
 *  定时器每隔三秒调用此函数去从路由器获取当前总下行流量
 */
-(void)updateSelectSpeed{
    YXMTrafficStatistics *statistics = [[YXMTrafficStatistics alloc]init];
    [statistics getNetworkSpeed];
}

-(void)buttonEvent:(UIButton *)sender{
    DLog(@"%@",sender);
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL isLogin = [ud boolForKey:KEY_OF_ISLOGIN];
    if (!isLogin) {
        //登陆到路由器
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
            //如果密码错误的情况下
            if (![MyTool isPasswordValidate:[NSString stringWithFormat:@"%@",operation.response.URL]]) {
                [self loginRouterButtonClick:sender];
                return;
            }
            
            
            NSString *sLoginRouterReturnCode = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            DLog(@"sLoginRouterReturnCode: %@", sLoginRouterReturnCode);
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            if ([sLoginRouterReturnCode rangeOfString:@"ssid000 ="].location != NSNotFound) {
                
                NSString *ssidString = [MyTool getSSIDWithString:sLoginRouterReturnCode];
                [ud setObject:ssidString forKey:KEY_ROUTER_SSID];
                //wifi密码
                NSString *pwdString = [MyTool getWIFIPassword:sLoginRouterReturnCode];
                [ud setObject:pwdString forKey:KEY_OF_WIFI_PASSWORD];
                [ud setBool:YES forKey:KEY_OF_ISLOGIN];
                if ([sLoginRouterReturnCode rangeOfString:KEY_LOGIN_ERROR].location != NSNotFound) {
                    [ud setObject:@"未连接" forKey:NET_CONNECT_STATE];
                    [[[iToast makeText:NSLocalizedString(@"请先登录您的路由器", @"")]
                      setGravity:iToastGravityCenter] show:iToastTypeError];
                }else{
                    [ud setObject:@"已连接" forKey:NET_CONNECT_STATE];
                    //进入具体的某项功能页面
                    [self intoFunction:sender];
                }
            }else{
                [ud setBool:NO forKey:KEY_OF_ISLOGIN];
                [[[iToast makeText:NSLocalizedString(@"请先登录您的路由器", @"")]
                  setGravity:iToastGravityCenter] show:iToastTypeError];
            }
            [ud synchronize];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setBool:NO forKey:KEY_OF_ISLOGIN];
            [ud setObject:@"未连接" forKey:NET_CONNECT_STATE];
            [[[iToast makeText:NSLocalizedString(@"请先登录您的路由器", @"")]
              setGravity:iToastGravityCenter] show:iToastTypeError];
        }];
        
    }else{
        [self intoFunction:sender];
    }
    
    
}


-(void)intoFunction:(UIButton *)sender{
    @try {
        NSInteger functionIndex = sender.tag - TAG_BUTTON_BASE;
        switch (functionIndex) {
            case 0:
            {
                //蹭网管理
                if (!zjlCtrl) {
                    zjlCtrl = [[ZJLViewController alloc] init];
                }
                [zjlCtrl reloadTableView];
                [self.navigationController pushViewController:zjlCtrl animated:YES];
                
            }
                break;
            case 3:
            {
                //万能中继
                if (!relayNetCtrl) {
                    relayNetCtrl = [[YXMRelayViewController alloc]init];
                }
                [self.navigationController pushViewController:relayNetCtrl animated:YES];
            }
                break;
            case 4:
            {
                //网络优化
                if (!optimizeNetCtrl) {
                    optimizeNetCtrl = [[YXMOptimizeNetViewController alloc]init];
                }
                [self.navigationController pushViewController:optimizeNetCtrl animated:YES];
            }
                break;
            case 2:
            {
                //WiFi设置
                if (!wifiSetupCtrl) {
                    wifiSetupCtrl = [[YXMWiFiSetupViewController alloc]init];
                }
                
                [self.navigationController pushViewController:wifiSetupCtrl animated:YES];
            }
                break;
            case 1:
            {
                //穿墙提速
                if (!speedAdjustmentCtrl) {
                    speedAdjustmentCtrl = [[YXMSpeedAdjustmentViewController alloc]init];
                }
                
                [self.navigationController pushViewController:speedAdjustmentCtrl animated:YES];
            }
                break;
            case 5:
            {
                //上网设置
                if (!wanSetupmentCtrl) {
                    wanSetupmentCtrl = [[YXMWanSetupViewController alloc]init];
                }
                [self.navigationController pushViewController:wanSetupmentCtrl animated:YES];
            }
                break;
            case 6:
            {
                //上网设置
                if (!wifiSwitchCtrl) {
                    wifiSwitchCtrl = [[YXMWiFiSwitchViewController alloc]init];
                }
                [self.navigationController pushViewController:wifiSwitchCtrl animated:YES];
            }
                break;
                
            default:
            {
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"开发中,敬请期待！" delegate:self cancelButtonTitle:[Config DPLocalizedString:@"sure"] otherButtonTitles:nil, nil];
                [alert show];
            }
                break;
        }
    }
    @catch (NSException *exception) {
        DTLog(@"%@",exception);
    }
    @finally {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showLeftPage:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}
- (IBAction)showRightPage:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:[[AppDelegate globalDelegate] drawerSettingsViewController]];
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}



/**
 *  创建网速显示标签视图
 *
 *  @param superView 父视图
 */
-(void)createNetworkSpeed:(UIView *)superView{
    //当前网速
    NSString *networkSpeed = @"0.0";
    UIFont *speedLableFont = [UIFont fontWithName:@"HiraKakuProN-W3" size:50];
    CGSize networkSpeedSize = [networkSpeed sizeWithAttributes:@{NSFontAttributeName:speedLableFont}];
    CGFloat networkSpeedWidth = networkSpeedSize.width;
    _networkSpeedLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 25, networkSpeedWidth, 80)];
    [_networkSpeedLabel setFont:speedLableFont];
    [_networkSpeedLabel setText:networkSpeed];
    [_networkSpeedLabel setTextColor:[UIColor whiteColor]];
    [superView addSubview:_networkSpeedLabel];
    
    
    UILabel *kbsLabel = [[UILabel alloc]initWithFrame:CGRectMake(networkSpeedWidth+10, _networkSpeedLabel.frame.origin.y+_networkSpeedLabel.frame.size.height-30, 40, 10)];
    [kbsLabel setTextColor:[UIColor lightGrayColor]];
    [kbsLabel setFont:[UIFont systemFontOfSize:8]];
    [kbsLabel setText:@"KB/S"];
    [superView addSubview:kbsLabel];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [APService startLogPageView:@"路由器管理"];
    if (!_updateSSIDTimer) {
        _updateSSIDTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(readRouterSSID) userInfo:nil repeats:YES];
    }
    [self resumeTimer];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [APService stopLogPageView:@"路由器管理"];
    [self pauseTimer];
}

/**
 *  创建一个登录提示与和登录按钮的视图
 *
 *  @param superView 父视图
 *
 *  @return 登录提示与和登录按钮的视图
 */
-(void)createLoginView:(UIView *)superView{
    _loginPromptView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, superView.frame.size.width, superView.frame.size.height)];
    [_loginPromptView setBackgroundColor:[UIColor colorWithRed:0.467 green:0.784 blue:0.055 alpha:1]];
    UILabel *promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _loginPromptView.frame.size.width, _loginPromptView.frame.size.height/3.0)];
    [promptLabel setTextAlignment:NSTextAlignmentCenter];
    [promptLabel setText:[Config DPLocalizedString:@"router_login_prompt"]];
    [promptLabel setTextColor:[UIColor whiteColor]];
    [promptLabel setFont:[UIFont systemFontOfSize:12]];
    [_loginPromptView addSubview:promptLabel];
    
    //点击登录按钮
    UIButton *loginButton = [[UIButton alloc]initWithFrame:CGRectMake(_loginPromptView.frame.size.width/2-(((90.0/320.0)*_loginPromptView.frame.size.width)/2.0), promptLabel.frame.size.height+promptLabel.frame.origin.y, (90.0/320.0)*_loginPromptView.frame.size.width, _loginPromptView.frame.size.height*0.5)];
    [loginButton setTitle:[Config DPLocalizedString:@"router_immediately_login"] forState:UIControlStateNormal];
    [loginButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [loginButton.layer setBorderWidth:1];
    [loginButton addTarget:self action:@selector(loginRouterButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_loginPromptView addSubview:loginButton];
    [_loginPromptView setHidden:YES];
    [superView addSubview:_loginPromptView];
}


-(void)routerInfoButtonClick:(UIButton *)sender{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL isLogin = [ud boolForKey:KEY_OF_ISLOGIN];
    if (isLogin) {
        [_loginPromptView setHidden:YES];
        //读取路由器的基本信息
        [self readRouterBaseInfo];
    }else{
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
            }else{
                [ud setBool:NO forKey:KEY_OF_ISLOGIN];
            }
            
            if ([sLoginRouterReturnCode rangeOfString:KEY_LOGIN_ERROR].location != NSNotFound) {
                [ud setObject:@"未连接" forKey:NET_CONNECT_STATE];
            }else{
                [ud setObject:@"已连接" forKey:NET_CONNECT_STATE];
            }
            
            [ud synchronize];
            _isShowRouterBaseInfoWindow = YES;
            [self readRouterBaseInfo];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setObject:@"未连接" forKey:NET_CONNECT_STATE];
        }];
    }
}

/**
 *  登录路由器的事件
 *
 *  @param sender 登录按钮
 */
-(void)loginRouterButtonClick:(UIButton *)sender{
    NSString *ssidString = [IPHelpler getDeviceSSID];
    NSString *promptTitle = [NSString stringWithFormat:@"请输入路由器管理登录密码"];
    NSString *messageString = nil;
    if (ssidString) {
        messageString = [NSString stringWithFormat:@"已连接到%@",ssidString];
    }else{
        messageString = [NSString stringWithFormat:@"未连接到任何路由器"];
        promptTitle = @"";
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL isLogin = [ud boolForKey:KEY_OF_ISLOGIN];
    if (_currentConnectState == ReachableViaWWAN) {
        [[[iToast makeText:NSLocalizedString(@"请先连接到路由器的WIFI", @"")]
          setGravity:iToastGravityCenter] show:iToastTypeError];
    }else{
        if (!isLogin) {
            self.stAlertView2 = [[STAlertView alloc]initWithTitle:promptTitle message:messageString textFieldHint:@"路由器管理密码" textFieldValue:@"" cancelButtonTitle:[Config DPLocalizedString:@"cancel"] otherButtonTitle:[Config DPLocalizedString:@"sure"] cancelButtonBlock:^{
                DLog(@"取消登录")
            } otherButtonBlock:^(NSString *result) {
                DLog(@"%@",result);
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
                manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                NSString *pwdString = result;
                NSDictionary *parameters = @{@"Username":@"admin",@"checkEn": @"0",@"Password":pwdString};
                DLog(@"parameters = %@",parameters);
                NSString *routerDomain = [IPHelpler getGatewayIPAddress];
                NSString *url_login_router = [ud objectForKey:URL_LOGIN_ROUTER];
                [manager POST:[NSString stringWithFormat:@"%@%@",routerDomain,url_login_router] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    //1、判断登陆密码是否正确,如果登陆密码错误需要进行提示处理
                    NSString *responseURL = [NSString stringWithFormat:@"%@",operation.response.URL];
                    if (![MyTool isPasswordValidate:responseURL]) {
                        //密码错误的情况
                        [[[iToast makeText:NSLocalizedString(@"路由器登陆密码错误", @"")]
                          setGravity:iToastGravityCenter] show:iToastTypeError];
                    }else{
                        NSString *sLoginRouterReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                        DLog(@"sLoginRouterReturnCode111: %@", sLoginRouterReturnCode);
                        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                        
                        if ([sLoginRouterReturnCode rangeOfString:@"ssid000 ="].location != NSNotFound) {
                            //登录成功--------------------
                            //获取路由器的SSID
                            NSString *ssidString = [MyTool getSSIDWithString:sLoginRouterReturnCode];
                            [ud setObject:ssidString forKey:KEY_ROUTER_SSID];
                            //设置登录成功标志位为YES
                            [ud setBool:YES forKey:KEY_OF_ISLOGIN];
                            //隐藏登录提示界面
                            [_loginPromptView setHidden:YES];
                            //存储登录名和密码
                            [self saveRouterAccountAndPassword:parameters];
                            //当前登录的无线的名称
                            [_ssidLabel setHidden:NO];
                        }else{
                            //登录失败--------------------
                            //当前登录的无线的名称
                            [_ssidLabel setHidden:YES];
                            //显示登录提示页面
                            [_loginPromptView setHidden:NO];
                            //设置登录成功标示位为NO
                            [ud setBool:NO forKey:KEY_OF_ISLOGIN];
                            //移除路由器SSID在本地的缓存
                            [ud removeObjectForKey:KEY_ROUTER_SSID];
                        }
                        
                        if ([sLoginRouterReturnCode rangeOfString:KEY_LOGIN_ERROR].location != NSNotFound) {
                            [ud setObject:@"未连接" forKey:NET_CONNECT_STATE];
                        }else{
                            [ud setObject:@"已连接" forKey:NET_CONNECT_STATE];
                        }
                        
                        [ud synchronize];
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    DLog(@"Error: %@", error);
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    [ud setObject:@"未连接" forKey:NET_CONNECT_STATE];
                    [_loginPromptView setHidden:NO];
                }];
                
            }];
            [self.stAlertView2 show];
        }
    }
}

/**
 *  存储路由器的登录名和密码
 */
-(void)saveRouterAccountAndPassword:(NSDictionary *)routerAcountDict{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:routerAcountDict[@"Username"] forKey:KEY_OF_ROUTER_ACCOUNT];
    [ud setObject:routerAcountDict[@"Password"] forKey:KEY_OF_ROUTER_PASSWORD];
    [ud synchronize];
}


/**
 *  读取路由器的基本信息
 *
 *  @return 返回路由器基本信息的字典
 */
-(void)readRouterBaseInfo{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *routerDomain = [IPHelpler getGatewayIPAddress];
    NSString *url_router_base_info = [ud objectForKey:URL_ROUTER_BASEINFO];
    [manager GET:[NSString stringWithFormat:@"%@%@",routerDomain,url_router_base_info] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *routerBaseInfoDictionary = [[NSMutableDictionary alloc]init];
        
        NSString *sGetRouterBaseInfoReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        DLog(@"sGetRouterBaseInfoReturnCode = %@",sGetRouterBaseInfoReturnCode);
        
        NSInteger baseInfoStartIndex = [sGetRouterBaseInfoReturnCode rangeOfString:@"cableDSL"].location;
        if (baseInfoStartIndex!=NSNotFound) {
            NSString *subBaseInfoString = [sGetRouterBaseInfoReturnCode substringFromIndex:baseInfoStartIndex];
            DLog(@"%@",subBaseInfoString);
            NSInteger baseInfoEndIndex = [subBaseInfoString rangeOfString:@"function"].location;
            subBaseInfoString = [subBaseInfoString substringToIndex:baseInfoEndIndex];
            subBaseInfoString = [subBaseInfoString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            subBaseInfoString = [subBaseInfoString stringByReplacingOccurrencesOfString:@"\n\t" withString:@""];
            subBaseInfoString = [subBaseInfoString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            subBaseInfoString = [subBaseInfoString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            
            NSArray *baseInfoArray = [subBaseInfoString componentsSeparatedByString:@","];
//            DTLog(@"baseInfoArray = %@",baseInfoArray);
            for (NSString *oneInfo in baseInfoArray) {
                NSArray *oneInfoArray = [oneInfo componentsSeparatedByString:@"="];
                NSString *keyString = [oneInfoArray objectAtIndex:0];
                //过滤空白字符串
                NSCharacterSet *whitespace =[NSCharacterSet whitespaceAndNewlineCharacterSet];
                keyString =[keyString stringByTrimmingCharactersInSet:whitespace];
                NSString *valueString = [oneInfoArray objectAtIndex:1];
                valueString =[valueString stringByTrimmingCharactersInSet:whitespace];
                valueString = [valueString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                valueString = [valueString stringByReplacingOccurrencesOfString:@";wl_mode" withString:@""];
                NSString *temp = keyString;
                if (![[Config DPLocalizedString:temp] isEqualToString:keyString]) {
                    if ([valueString length]>1) {
                        [routerBaseInfoDictionary setObject:valueString forKey:keyString];
                    }
                }
            }
            
            //将路由器基本信息存储到数据库
            YXMMyRouterModel *myRouter = [[YXMMyRouterModel alloc]init];
            NSString *lan_mac = [routerBaseInfoDictionary objectForKey:@"lan_mac"];
            [myRouter setMrouter_id:lan_mac];
            if (lan_mac) {
                [[NSUserDefaults standardUserDefaults] setObject:lan_mac forKey:@"lan_mac"];
            }
            
            [myRouter setMrouter_dns1:[routerBaseInfoDictionary objectForKey:@"dns1"]];
            [myRouter setMrouter_name:@"Router"];
            [myRouter setMrouter_lan_ip:[routerBaseInfoDictionary objectForKey:@"lan_ip"]];
            [myRouter setMrouter_wan_ip:[routerBaseInfoDictionary objectForKey:@"wanIP"]];
            [myRouter setMrouter_geteway:[routerBaseInfoDictionary objectForKey:@"gateWay"]];
            NSString *router_lan_mac = [routerBaseInfoDictionary objectForKey:@"lan_mac"];
            [myRouter setMrouter_lan_mac:router_lan_mac];
            [[NSUserDefaults standardUserDefaults] setObject:router_lan_mac forKey:@"lan_mac"];
            [myRouter setMrouter_lan_mask:[routerBaseInfoDictionary objectForKey:@"lan_mask"]];
            [myRouter setMrouter_wan_mac:[routerBaseInfoDictionary objectForKey:@"wan_mac"]];
            [myRouter setMrouter_hardware_version:[routerBaseInfoDictionary objectForKey:@"hw_ver"]];
            [myRouter setMrouter_software_version:[routerBaseInfoDictionary objectForKey:@"run_code_ver"]];
            
            YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
            [db openDatabase];
            [db saveMyRouterWithObj:myRouter];
        }else{
            DLog(@"未找到");
        }
        if (_isShowRouterBaseInfoWindow) {
            [self showTableAlertWithDict:routerBaseInfoDictionary];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:[NSString stringWithFormat:@"%@",[IPHelpler getGatewayIPAddress]] forKey:URL_ROUTER_DOMAIN];
    }];
}


/**
 *  显示路由器详细信息的弹出表格视图
 *
 *  @param dataDict 路由器详细信息的数据
 */
-(void)showTableAlertWithDict:(NSDictionary *)dataDict{
    _isShowRouterBaseInfoWindow = NO;
    if (!dataDict) {
        return;
    }
    NSArray *allkeysArray = [dataDict allKeys];
    if ([allkeysArray count]<1) {
        return;
    }
    if ((!self.tableAlertView)||self.tableAlertView.isHidden) {
        self.tableAlertView = [MLTableAlert tableAlertWithTitle:@"详细信息" cancelButtonTitle:@"关闭" numberOfRows:^NSInteger (NSInteger section)
                               {
                                   return [allkeysArray count];
                               }
                                                       andCells:^UITableViewCell* (MLTableAlert *anAlert, NSIndexPath *indexPath)
                               {
                                   static NSString *CellIdentifier = @"CellIdentifier";
                                   UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
                                   if (cell == nil)
                                       cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                                   
                                   NSString *temp = [allkeysArray objectAtIndex:indexPath.row];
                                   DLog(@"key=%@",[NSString stringWithFormat:@"%@",[Config DPLocalizedString:temp]]);
                                   cell.textLabel.text = [NSString stringWithFormat:@"%@",[Config DPLocalizedString:temp]];
                                   NSString *detailString = [dataDict objectForKey:[allkeysArray objectAtIndex:indexPath.row]];
                                   if ([[allkeysArray objectAtIndex:indexPath.row] isEqualToString:@"conntime"]) {
                                       NSInteger conntime = [detailString integerValue];
                                       NSInteger second = 0;
                                       NSInteger minutes = 0;
                                       NSInteger hour = 0;
                                       if (conntime>59) {
                                           minutes = conntime/60;
                                           second = conntime%60;
                                       }
                                       if (minutes>59) {
                                           hour = minutes/60;
                                           minutes = minutes%60;
                                       }
                                       detailString = [NSString stringWithFormat:@"%d时%d分%d秒",(int)hour,(int)minutes,(int)second];
                                   }
                                   
                                   cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",detailString];
                                   
                                   return cell;
                               }];
        
        // Setting custom alert height
        self.tableAlertView.height = SCREEN_CGSIZE_HEIGHT*0.618;
        
        // configure actions to perform
        [self.tableAlertView configureSelectionBlock:^(NSIndexPath *selectedIndex){
            [self.tableAlertView setHidden:YES];
        } andCompletionBlock:^{
            [self.tableAlertView setHidden:YES];
        }];
        
        // show the alert
        [self.tableAlertView show];
    }
    
}



-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _myPageCtrl.currentPage = scrollView.contentOffset.x / SCREEN_CGSIZE_WIDTH;
}


-(void)readRouterSSID{
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
            [_loginStateLabel setText:[NSString stringWithFormat:@"%@",[Config DPLocalizedString:@"router_already_login"]]];
            [_ssidLabel setText:[NSString stringWithFormat:@"%@",ssidString]];
            //读取路由器的基本信息
            _isShowRouterBaseInfoWindow = NO;
            [self readRouterBaseInfo];
            if (ssidString) {
                [_loginPromptView setHidden:YES];
            }
        }else{
            [_loginPromptView setHidden:NO];
            [_loginStateLabel setText:[NSString stringWithFormat:@"%@",[Config DPLocalizedString:@"router_no_login"]]];
            [_ssidLabel setText:[NSString stringWithFormat:@"%@",[Config DPLocalizedString:@"router_login_prompt"]]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Error: %@", error);
        [_loginPromptView setHidden:NO];
        [_loginStateLabel setText:[NSString stringWithFormat:@"%@",[Config DPLocalizedString:@"router_no_login"]]];
        [_ssidLabel setText:[NSString stringWithFormat:@"%@",[Config DPLocalizedString:@"router_login_prompt"]]];
    }];
}




-(void)pauseTimer{
    
    if (![_updateSSIDTimer isValid]) {
        return ;
    }
    
    [_updateSSIDTimer setFireDate:[NSDate distantFuture]]; //如果给我一个期限，我希望是4001-01-01 00:00:00 +0000
    
    
}


-(void)resumeTimer{
    
    if (![_updateSSIDTimer isValid]) {
        return ;
    }
    
    //[self setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    [_updateSSIDTimer setFireDate:[NSDate date]];
    
}


/**
 *  创建路由器功能模块引导按钮
 */
-(void)createRouterFunctionGuideViewWithSupserView:(UIView *)superView{
    CGFloat myViewHeight = 55;
    _routerFunctionGruideView = [[UIView alloc]initWithFrame:CGRectMake(20, superView.frame.size.height- myViewHeight-20, SCREEN_CGSIZE_WIDTH-40, myViewHeight)];
    [_routerFunctionGruideView setBackgroundColor:[UIColor colorWithRed:0.541 green:0.800 blue:0.208 alpha:1]];
    [_routerFunctionGruideView setAlpha:1];
    [superView addSubview:_routerFunctionGruideView];
    
    CGFloat widthOfTotalView = _routerFunctionGruideView.frame.size.width;
    CGFloat widthOfOneView = widthOfTotalView/2-3;
    
    //连接状态
    UIView *wanConnectStateView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, widthOfOneView, _routerFunctionGruideView.frame.size.height)];
    
    //互联网连接的图标
    UIImageView *icon1ImageView = [[UIImageView alloc]initWithFrame:CGRectMake(wanConnectStateView.frame.size.width/2.0-wanConnectStateView.frame.size.height/1.5-20, (wanConnectStateView.frame.size.height-(wanConnectStateView.frame.size.height/1.5))/2, wanConnectStateView.frame.size.height/1.5, wanConnectStateView.frame.size.height/1.5)];
    [icon1ImageView setImage:[UIImage imageNamed:@"连接状态图标"]];
    [wanConnectStateView addSubview:icon1ImageView];
    //互联网连接的提示文字
    UILabel *wanConnectTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(wanConnectStateView.frame.size.width/2-20, 0, wanConnectStateView.frame.size.width - (wanConnectStateView.frame.size.width/2-20), wanConnectStateView.frame.size.height/2)];
    [wanConnectTitleLabel setText:@"互联网连接"];
    [wanConnectTitleLabel setTextColor:[UIColor whiteColor]];
    [wanConnectTitleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [wanConnectTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [wanConnectStateView addSubview:wanConnectTitleLabel];
    _wanConnectStateLabel = [[UILabel alloc]initWithFrame:CGRectMake(wanConnectTitleLabel.frame.origin.x, wanConnectTitleLabel.frame.size.height+wanConnectTitleLabel.frame.origin.y-3, wanConnectTitleLabel.frame.size.width, 20)];
    [_wanConnectStateLabel setTextAlignment:NSTextAlignmentCenter];
    [_wanConnectStateLabel setTextColor:[UIColor blackColor]];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [_wanConnectStateLabel setText:@"未连接"];
    [_wanConnectStateLabel setTextColor:[UIColor blackColor]];
    if ([ud objectForKey:NET_CONNECT_STATE]) {
        [_wanConnectStateLabel setText:[ud objectForKey:NET_CONNECT_STATE]];
    }
    [_wanConnectStateLabel setFont:[UIFont systemFontOfSize:14]];
    [wanConnectStateView addSubview:_wanConnectStateLabel];
    [_routerFunctionGruideView addSubview:wanConnectStateView];
    
    UIView *splitline1 = [[UIView alloc]initWithFrame:CGRectMake(wanConnectStateView.frame.size.width+wanConnectStateView.frame.origin.x, 5, 1, _routerFunctionGruideView.frame.size.height-10)];
    UIImageView *splitline1ImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 1, splitline1.frame.size.height)];
    [splitline1ImageView setImage:[UIImage imageNamed:@"白色线"]];
    [splitline1 addSubview:splitline1ImageView];
    [_routerFunctionGruideView addSubview:splitline1];
    //当前速度
    
    UIView *currentSpeedView = [[UIView alloc]initWithFrame:CGRectMake((splitline1.frame.size.width+splitline1.frame.origin.x), 0, widthOfOneView, _routerFunctionGruideView.frame.size.height)];
    UIImageView *icon2ImageView = [[UIImageView alloc]initWithFrame:CGRectMake(currentSpeedView.frame.size.width/2.0-currentSpeedView.frame.size.height/1.5-10, (currentSpeedView.frame.size.height-(currentSpeedView.frame.size.height/1.5))/2, currentSpeedView.frame.size.height/1.5, currentSpeedView.frame.size.height/1.5)];
    [icon2ImageView setImage:[UIImage imageNamed:@"当前速度"]];
    [currentSpeedView addSubview:icon2ImageView];
    
    UILabel *currentSpeedTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(currentSpeedView.frame.size.width/2-10, 0, currentSpeedView.frame.size.width/2, currentSpeedView.frame.size.height/2)];
    [currentSpeedTitleLabel setText:@"当前速度"];
    [currentSpeedTitleLabel setTextColor:[UIColor whiteColor]];
    [currentSpeedTitleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [currentSpeedTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [currentSpeedView addSubview:currentSpeedTitleLabel];
    _speedLabel = [[UILabel alloc]initWithFrame:CGRectMake(currentSpeedTitleLabel.frame.origin.x, currentSpeedTitleLabel.frame.size.height+currentSpeedTitleLabel.frame.origin.y-3, currentSpeedTitleLabel.frame.size.width, 20)];
    [_speedLabel setText:@"--"];
    [_speedLabel setTextAlignment:NSTextAlignmentCenter];
    [_speedLabel setTextColor:[UIColor blackColor]];
    [_speedLabel setFont:[UIFont systemFontOfSize:14]];
    [currentSpeedView addSubview:_speedLabel];
    
    
    [_routerFunctionGruideView addSubview:currentSpeedView];
    
    [self createLoginView:_routerFunctionGruideView];
}


/**
 *  更新通知传递过来的数据到网速显示标签视图
 *
 *  @param noti 网速更新通知
 */
-(void)updateNetSpeed:(NSNotification *)noti{
    NSDictionary *userinfo = [noti userInfo];
    CGFloat netSpeedFloat = [[userinfo objectForKey:@"totalNetSpeed"] floatValue];
    NSString *speedLabelString = [[NSString alloc]initWithFormat:@"%0.0lfKB/S",netSpeedFloat];
    if (netSpeedFloat>1023) {
        speedLabelString = [[NSString alloc]initWithFormat:@"%0.0lfMB/S",netSpeedFloat/1024];
    }
    [_speedLabel setText:speedLabelString];
}


-(void)createRouterHeadAndLoginViewWithSuperView:(UIView *)superView{
    UIView *routerView = [[UIView alloc]initWithFrame:CGRectMake(20, 0, SCREEN_CGSIZE_WIDTH-40, superView.frame.size.height- _routerFunctionGruideView.frame.size.height - 40)];
    [routerView setBackgroundColor:[UIColor clearColor]];

    [superView addSubview:routerView];
    
    /**
     * 路由器图标
     */
    UIView *routerHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, routerView.frame.size.width/2.0f, routerView.frame.size.height)];
    CGFloat headWidthScale = 0.8;
    UIImageView *routerHeadImage = [[UIImageView alloc]initWithFrame:CGRectMake(routerHeadView.frame.size.width-routerHeadView.frame.size.width*headWidthScale, (routerHeadView.frame.size.height-routerHeadView.frame.size.width*headWidthScale)/2.0f, routerHeadView.frame.size.width*headWidthScale, routerHeadView.frame.size.width*headWidthScale)];
    [routerHeadImage setImage:[UIImage imageNamed:@"路由器已登录"]];
    [routerHeadView addSubview:routerHeadImage];
    [routerView addSubview:routerHeadView];
    
    
    //路由器的登录状态和路由器的名称
    UIView *stateAndRouterNameView = [[UIView alloc]initWithFrame:CGRectMake(routerView.frame.size.width/2.0f, 0, routerView.frame.size.width/2.0f, routerView.frame.size.height)];
    [routerView addSubview:stateAndRouterNameView];
    UIView *loginStateView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, stateAndRouterNameView.frame.size.width, stateAndRouterNameView.frame.size.height/2.0f)];
    _loginStateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, loginStateView.frame.size.height-30, loginStateView.frame.size.width-10, 30)];
    [_loginStateLabel setText:[Config DPLocalizedString:@"router_no_login"]];
    [_loginStateLabel setFont:[UIFont boldSystemFontOfSize:24]];
    [_loginStateLabel setTextColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000]];
    [loginStateView addSubview:_loginStateLabel];
     [stateAndRouterNameView addSubview:loginStateView];
    
    UIView *ssidView = [[UIView alloc]initWithFrame:CGRectMake(0, stateAndRouterNameView.frame.size.height/2.0f, stateAndRouterNameView.frame.size.width, stateAndRouterNameView.frame.size.height/2.0f)];
     [stateAndRouterNameView addSubview:ssidView];
    _ssidLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, ssidView.frame.size.width-10, 20)];
    [_ssidLabel setTextColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000]];
    [_ssidLabel setFont:[UIFont systemFontOfSize:14]];
    [_ssidLabel setText:[Config DPLocalizedString:@"router_login_prompt"]];
    [_ssidLabel setAdjustsFontSizeToFitWidth:YES];
    [ssidView addSubview:_ssidLabel];
    
   
}


/**
 *  初始化网络状态监听组件
 */
-(void)initReachability{
    //网络状态的改变
    MyReachability * reach = [MyReachability reachabilityWithHostname:@"www.baidu.com"];
    
    reach.reachableBlock = ^(MyReachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _wanConnectStateLabel.text = [Config DPLocalizedString:reachability.currentReachabilityString];
            //当网络处于手机移动网络状态下时将网速设置为--
            if (reachability.currentReachabilityStatus == ReachableViaWWAN) {
                [_speedLabel setText:@"--"];
                [_loginPromptView setHidden:NO];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KEY_OF_ISLOGIN];
            }
            _currentNetworkStatus = reachability.currentReachabilityStatus;
        });
    };
    
    reach.unreachableBlock = ^(MyReachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //当网络处于未连接状态时候将网速设置为0KB,连接状态提示文字也作出相应变更
            _wanConnectStateLabel.text = [Config DPLocalizedString:reachability.currentReachabilityString];
            [_speedLabel setText:@"0Kb/s"];
            _currentNetworkStatus = reachability.currentReachabilityStatus;
            [_loginPromptView setHidden:NO];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KEY_OF_ISLOGIN];
        });
    };
    
    [reach startNotifier];
}

@end
