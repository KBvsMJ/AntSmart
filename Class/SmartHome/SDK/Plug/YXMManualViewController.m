//
//  YXMManualViewController.m
//  SmartHome
//
//  Created by iroboteer on 15/5/4.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMManualViewController.h"
#import "Config.h"
#import "UIView+Shadow.h"
#import <iToast/iToast.h>

#import "YXMDatabaseOperation.h"
#import <STAlertView/STAlertView.h>
#import "AppDelegate.h"
#import "JVFloatingDrawerViewController.h"

//路由器的SSID
#define TAG_SSID_TEXTFIELD 10099
//路由的无线密码
#define TAG_PASSWORD_TEXTFIELD 10100
//进度条总长度
#define INT_PROGRESS_BAR_TOTAL 61

@interface YXMManualViewController ()

@end

@implementation YXMManualViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"配置设备";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.translucent = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    //获取路由器的无线网络的SSID和无线密码的视图
    [self createAccountAndPwdView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * 获取路由器的无线网络的SSID和无线密码的视图
 */
-(void)createAccountAndPwdView{
    configBaseView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:configBaseView];
    CGFloat topOffsetHeight = 44.0f;
    //主提示
    mainPromptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, topOffsetHeight, self.view.frame.size.width, 44)];
    [mainPromptLabel setBackgroundColor:[UIColor clearColor]];
    [mainPromptLabel setText:[Config DPLocalizedString:@"manualconfigprompt"]];
    [mainPromptLabel setTextColor:[UIColor grayColor]];
    [mainPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [mainPromptLabel setFont:[UIFont systemFontOfSize:24 weight:20]];
    [mainPromptLabel setAdjustsFontSizeToFitWidth:YES];
    [configBaseView addSubview:mainPromptLabel];
    

    //配置的账号和密码
    CGRect accountPwdRect = CGRectMake(0, mainPromptLabel.frame.origin.y + mainPromptLabel.frame.size.height +30, SCREEN_CGSIZE_WIDTH,  SCREEN_CGSIZE_WIDTH/2.0f);
    _accountAndPwdView  = [[UIView alloc]initWithFrame:accountPwdRect];
    [configBaseView addSubview:_accountAndPwdView];
    //选择想要中继的wifi名称
    CGFloat widthSelectSSIDButton = SCREEN_CGSIZE_WIDTH*(300.0/320.0);
    CGFloat xSelectSSIDButton = (SCREEN_CGSIZE_WIDTH-widthSelectSSIDButton)/2.0;
    UILabel *ssidNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(xSelectSSIDButton, 0, widthSelectSSIDButton, 44)];
    [ssidNameLabel.layer setBorderColor:[UIColor colorWithRed:0.467 green:0.784 blue:0.055 alpha:1.000].CGColor];
    [ssidNameLabel.layer setBorderWidth:1.0];
    [ssidNameLabel setUserInteractionEnabled:YES];
    [_accountAndPwdView addSubview:ssidNameLabel];
    UILabel *promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 44)];
    [promptLabel setText:@"无线名称"];
    [promptLabel setFont:[UIFont systemFontOfSize:12]];
    [promptLabel setTextAlignment:NSTextAlignmentCenter];
    [promptLabel makeInsetShadowWithRadius:0.5 Color:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] Directions:[NSArray arrayWithObjects:@"right", nil]];
    [ssidNameLabel addSubview:promptLabel];
    _ssidTextField = [[UITextField alloc]initWithFrame:CGRectMake(64, 0, ssidNameLabel.frame.size.width-64, 44)];
    [_ssidTextField setTag:TAG_SSID_TEXTFIELD];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [_ssidTextField setText:[ud objectForKey:KEY_ROUTER_SSID]];
    [_ssidTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_ssidTextField setDelegate:self];
    [_ssidTextField setEnabled:NO];
    //获取wifi名
    if([self fetchSSIDInfo]){
        _ssidTextField.text = [((NSDictionary *)[self fetchSSIDInfo]) objectForKey:@"SSID"];
    }
    [ssidNameLabel addSubview:_ssidTextField];

    //输入选择的wifi的信号的密码
    UILabel *passwordLabel = [[UILabel alloc]initWithFrame:CGRectMake(xSelectSSIDButton, ssidNameLabel.frame.size.height+ssidNameLabel.frame.origin.y+20, widthSelectSSIDButton, 44)];
    [passwordLabel setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel setUserInteractionEnabled:YES];
    [passwordLabel.layer setBorderColor:[UIColor colorWithRed:0.463 green:0.780 blue:0.059 alpha:1.000].CGColor];
    [passwordLabel.layer setBorderWidth:1.0];
    [_accountAndPwdView addSubview:passwordLabel];
    UILabel *promptLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 44)];
    [promptLabel2 setText:@"无线密码"];
    [promptLabel2 makeInsetShadowWithRadius:0.5 Color:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] Directions:[NSArray arrayWithObjects:@"right", nil]];
    [promptLabel2 setTextAlignment:NSTextAlignmentCenter];
    [promptLabel2 setFont:[UIFont systemFontOfSize:12]];
    [passwordLabel addSubview:promptLabel2];
    
    _passwordTextField = [[UITextField alloc]initWithFrame:CGRectMake(64, 0, passwordLabel.frame.size.width-64, 44)];
    [_passwordTextField setTag:TAG_PASSWORD_TEXTFIELD];
    [_passwordTextField setText:[ud objectForKey:KEY_OF_WIFI_PASSWORD]];
    [_passwordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_passwordTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    [_passwordTextField setDelegate:self];
    [passwordLabel addSubview:_passwordTextField];
    
    //取消按钮
    CGFloat fCancelButtonX = SCREEN_CGSIZE_WIDTH/4.0f;
    CGFloat fButtonWidth = SCREEN_CGSIZE_WIDTH/4.0f;
    UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(fCancelButtonX, _accountAndPwdView.frame.origin.y + _accountAndPwdView.frame.size.height + 44, fButtonWidth, 40)];
    [cancelButton addTarget:self action:@selector(stopConfigButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton.layer setBorderColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000].CGColor];
    [cancelButton.layer setBorderWidth:0.6f];
    [cancelButton setTitleColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000] forState:UIControlStateNormal];
    [cancelButton setTitle:[Config DPLocalizedString:@"previousButtonTitle"] forState:UIControlStateNormal];
    [configBaseView addSubview:cancelButton];
    //配置按钮
    _startConfigButton = [[UIButton alloc]initWithFrame:CGRectMake(cancelButton.frame.origin.x+cancelButton.frame.size.width, cancelButton.frame.origin.y, fButtonWidth, cancelButton.frame.size.height)];
    [_startConfigButton addTarget:self action:@selector(startConfigButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_startConfigButton.layer setBorderColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000].CGColor];
    [_startConfigButton.layer setBorderWidth:0.6f];
    [_startConfigButton setTitleColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000] forState:UIControlStateNormal];
    [_startConfigButton setTitle:[Config DPLocalizedString:@"configButtonTitle"] forState:UIControlStateNormal];
    [configBaseView addSubview:_startConfigButton];
}


/**
 *  停止配置
 *
 *  @param sender
 */
-(void)stopConfigButtonClick:(UIButton *)sender{
    [time invalidate];
    [smart2 StopSmartConfig];
    progressView.progressCounter = 0;
    value = 0;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!smart2) {
        smart2 = [[smartConfig alloc]init];
    }
    CGRect accountPwdRect = CGRectMake(0, mainPromptLabel.frame.origin.y + mainPromptLabel.frame.size.height +30, SCREEN_CGSIZE_WIDTH,  SCREEN_CGSIZE_WIDTH/2.0f);
    [_accountAndPwdView setFrame:accountPwdRect];
    
    [progressView removeFromSuperview];
    CGRect progressRect = CGRectMake((SCREEN_CGSIZE_WIDTH - SCREEN_CGSIZE_WIDTH/2.0f)/2 + SCREEN_CGSIZE_WIDTH, mainPromptLabel.frame.origin.y + mainPromptLabel.frame.size.height +30, SCREEN_CGSIZE_WIDTH/2.0f, SCREEN_CGSIZE_WIDTH/2.0f);
    [self insertProgressView:configBaseView andFrame:progressRect];
    isProgress = NO;
    //切换提示文字
    [mainPromptLabel setText:[Config DPLocalizedString:@"manualconfigprompt"]];
    [_startConfigButton setTitle:[Config DPLocalizedString:@"configButtonTitle"] forState:UIControlStateNormal];
}

/**
 *  开始配置插座网络的处理方法
 */
- (void)startConfigNet{
    NSString *ssid = [[NSString alloc]initWithString:[_ssidTextField text]];
    NSString *pwd = [[NSString alloc]initWithString:[_passwordTextField text]];
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"isSend"];
    dispatch_async(dispatch_get_main_queue(), ^(){
        
    });
    [smart2 StartSmartConfigSetSSID:ssid andSetPassWord:pwd];
}


/**
 *  开始配置设备的网络
 *
 *  @param sender
 */
-(void)startConfigButtonClick:(UIButton *)sender{
    @try {
        if (!isProgress) {
            
            NSString *ssid = [[NSString alloc]initWithString:[_ssidTextField text]];
            NSString *pwd = [[NSString alloc]initWithString:[_passwordTextField text]];
            DTLog(@"ssid = %@,pwd = %@",ssid,pwd);
            if ([pwd length]<8||[pwd length]>64) {
                [[[iToast makeText:[Config DPLocalizedString:@"wifipasswordlengtherror"]]
                  setGravity:iToastGravityCenter] show:iToastTypeError];
                return;
            }
            if ([ssid length]<1) {
                [[[iToast makeText:[Config DPLocalizedString:@"wifissidlengtherror"]]
                  setGravity:iToastGravityCenter] show:iToastTypeError];
                return;
            }
            isProgress = YES;
            //查询当前配置成功的设备有多少个
            YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
            [db openDatabase];
            _beforeDeviceCount = [db readDeviceCount];
            
            //启动配置方法
            [NSThread detachNewThreadSelector:@selector(startConfigNet) toTarget:self withObject:nil];
            
            //从输入密码的视图切换到进度条视图
            CGRect oriangeRect = _accountAndPwdView.frame;
            [UIView animateWithDuration:.5f animations:^{
                [_accountAndPwdView setFrame:CGRectMake(oriangeRect.origin.x-oriangeRect.size.width, oriangeRect.origin.y, oriangeRect.size.width, oriangeRect.size.height)];
            } completion:^(BOOL finished) {
                CGRect progressRect = CGRectMake((SCREEN_CGSIZE_WIDTH - SCREEN_CGSIZE_WIDTH/2.0f)/2, mainPromptLabel.frame.origin.y + mainPromptLabel.frame.size.height +30, SCREEN_CGSIZE_WIDTH/2.0f, SCREEN_CGSIZE_WIDTH/2.0f);
                [self insertProgressView:configBaseView andFrame:progressRect];
                //定时刷新进度条
                time = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(changeView) userInfo:nil repeats:YES];
            }];
            //切换提示文字
            [mainPromptLabel setText:[Config DPLocalizedString:@"manualconfigingprompt"]];
            [_startConfigButton setTitle:[Config DPLocalizedString:@"configing"] forState:UIControlStateNormal];
        }
    }
    @catch (NSException *exception) {
        DTLog(@"%@",exception);
    }
    @finally {
        
    }
}

/**
 *  插入进度条
 *
 *  @param superView 进度条视图的父视图
 *  @param rect      进度条的rect
 */
-(void)insertProgressView:(UIView *)superView andFrame:(CGRect)rect{
    value = 0;
    //配置的进度条
    //进度条样式可以自定义。。这里我们引用了一个第三方类。只作为显示。对配置无影响
    newTheme = [[MDRadialProgressTheme alloc] init];
    newTheme.completedColor = [UIColor colorWithRed:19/255.0 green:193/255.0 blue:255/255.0 alpha:1];
    newTheme.incompletedColor = [UIColor whiteColor];
    newTheme.centerColor = [UIColor clearColor];
    newTheme.sliceDividerHidden = YES;
    newTheme.labelColor = [UIColor colorWithRed:111/255.0 green:124/255.0 blue:111/255.0 alpha:1];
    newTheme.labelShadowColor = [UIColor whiteColor];
    newTheme.font = [UIFont systemFontOfSize:16.0f];
    progressView = [[MDRadialProgressView alloc] initWithFrame:rect andTheme:newTheme];
    progressView.progressTotal = INT_PROGRESS_BAR_TOTAL;
    progressView.progressCounter = 0;
    [superView addSubview:progressView];
}


/**
 *  通过一个定时器来循环调用此方法来达到进度条前进的效果
 */
- (void)changeView{
    value ++;
    if (value > INT_PROGRESS_BAR_TOTAL) {
        //停止计时器
        [time invalidate];
        value = 0;
        [smart2 StopSmartConfig];
        //配置完毕，发现设备
        [self configSuccessAndFindLocalDevice];
    }else{
        progressView.progressCounter = value;
    }
}

/**
 * 当配置插座成功后启动发现设备的程序
 */
-(void)configSuccessAndFindLocalDevice{
    //读取配置成功后设备的数量
    YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
    [db openDatabase];
    _afterDeviceCount = [db readDeviceCount];
    DTLog(@"after = %d,before = %d",(int)_afterDeviceCount,(int)_beforeDeviceCount);
    int newDeviceCount = (int)(_beforeDeviceCount - _afterDeviceCount);
    self.findDeviceResultAlertView = [[STAlertView alloc]initWithTitle:[NSString stringWithFormat:@"配置设备完毕"] message:[NSString stringWithFormat:@"本地已存在%d个设备,新加入%d个设备,如果设备未配置成功则重置设备后再试一次。",(int)_afterDeviceCount,newDeviceCount] cancelButtonTitle:nil otherButtonTitle:[Config DPLocalizedString:@"sure"] cancelButtonBlock:^{
        DTLog(@"取消登录");
        [self closeCurrentPage:nil];
    } otherButtonBlock:^(NSString *result) {
        DTLog(@"%@",result);
        
    }];
    [self.findDeviceResultAlertView show];
}

/**
 *  关闭当前自动配置页面
 *
 *  @param sender 关闭按钮
 */
- (void)closeCurrentPage:(id)sender {
    [time invalidate];
    [smart2 StopSmartConfig];
    progressView.progressCounter = 0;
    value = 0;
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closecurrentpage" object:nil];
}

#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _passwordTextField) {
        [_passwordTextField resignFirstResponder];
    }
    return YES;
}

//关闭键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_passwordTextField resignFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_passwordTextField resignFirstResponder];
}


- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) { break; }
    }
    return info;
}

@end
