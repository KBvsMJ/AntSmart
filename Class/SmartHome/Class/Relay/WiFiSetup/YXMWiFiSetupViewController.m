//
//  YXMWiFiSetupViewController.m
//  SmartHome
//
//  Created by iroboteer on 15/4/8.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMWiFiSetupViewController.h"
#import "UIView+Shadow.h"
#import <iToast/iToast.h>
#import "MyTool.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "Config.h"
#import "IPHelpler.h"

#define WIFILIST_BASE_VIEW 300088
#define TAG_SSID_NAME_SELECT 300001
#define TAG_PASSWORD_SELECT 300002
#define TAG_PASSWORD_TEXTFIELD 300003 //无线密码
#define TAG_SSID_TEXTFIELD 300004 //无线账号

@interface YXMWiFiSetupViewController ()

@end

@implementation YXMWiFiSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WiFi设置";
    
    //选择想要中继的wifi名称
    CGFloat widthSelectSSIDButton = SCREEN_CGSIZE_WIDTH*(300.0/320.0);
    CGFloat xSelectSSIDButton = (SCREEN_CGSIZE_WIDTH-widthSelectSSIDButton)/2.0;
    UILabel *ssidNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(xSelectSSIDButton, 84, widthSelectSSIDButton, 44)];
    [ssidNameLabel.layer setBorderColor:[UIColor colorWithRed:0.467 green:0.784 blue:0.055 alpha:1.000].CGColor];
    [ssidNameLabel.layer setBorderWidth:1.0];
    [ssidNameLabel setUserInteractionEnabled:YES];
    [self.view addSubview:ssidNameLabel];
    UILabel *promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 44)];
    [promptLabel setText:@"无线名称"];
    [promptLabel setFont:[UIFont systemFontOfSize:12]];
    [promptLabel setTextAlignment:NSTextAlignmentCenter];
    [promptLabel makeInsetShadowWithRadius:0.5 Color:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] Directions:[NSArray arrayWithObjects:@"right", nil]];
    [ssidNameLabel addSubview:promptLabel];
    UITextField *ssidField = [[UITextField alloc]initWithFrame:CGRectMake(64, 0, ssidNameLabel.frame.size.width-64, 44)];
    [ssidField setTag:TAG_SSID_TEXTFIELD];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ssidField setText:[ud objectForKey:KEY_ROUTER_SSID]];
    [ssidField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [ssidField setDelegate:self];
    [ssidNameLabel addSubview:ssidField];
    UIButton *changeSSIDButtton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, ssidField.frame.size.width, ssidField.frame.size.height)];
    [changeSSIDButtton addTarget:self action:@selector(changeSSIDClick:) forControlEvents:UIControlEventTouchUpInside];
    [ssidField addSubview:changeSSIDButtton];

    
    //输入选择的wifi的信号的密码
    UILabel *passwordLabel = [[UILabel alloc]initWithFrame:CGRectMake(xSelectSSIDButton, ssidNameLabel.frame.size.height+ssidNameLabel.frame.origin.y+20, widthSelectSSIDButton, 44)];
    [passwordLabel setTag:TAG_PASSWORD_SELECT];
    [passwordLabel setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel setUserInteractionEnabled:YES];
    [passwordLabel.layer setBorderColor:[UIColor colorWithRed:0.463 green:0.780 blue:0.059 alpha:1.000].CGColor];
    [passwordLabel.layer setBorderWidth:1.0];
    [self.view addSubview:passwordLabel];
    UILabel *promptLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 44)];
    [promptLabel2 setText:@"无线密码"];
    [promptLabel2 makeInsetShadowWithRadius:0.5 Color:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] Directions:[NSArray arrayWithObjects:@"right", nil]];
    [promptLabel2 setTextAlignment:NSTextAlignmentCenter];
    [promptLabel2 setFont:[UIFont systemFontOfSize:12]];
    [passwordLabel addSubview:promptLabel2];
    
    UITextField *passwordField = [[UITextField alloc]initWithFrame:CGRectMake(64, 0, passwordLabel.frame.size.width-64, 44)];
    [passwordField setTag:TAG_PASSWORD_TEXTFIELD];
    [passwordField setText:[ud objectForKey:KEY_OF_WIFI_PASSWORD]];
    [passwordField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [passwordField setKeyboardType:UIKeyboardTypeEmailAddress];
    [passwordField setDelegate:self];
    [passwordLabel addSubview:passwordField];
    UIButton *changePasswordButtton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, passwordField.frame.size.width, passwordField.frame.size.height)];
    [changePasswordButtton addTarget:self action:@selector(changePasswordClick:) forControlEvents:UIControlEventTouchUpInside];
    [passwordField addSubview:changePasswordButtton];
    
    //确定开始配置按钮
//    UIButton *configButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [configButton setFrame:CGRectMake(passwordLabel.frame.origin.x, passwordLabel.frame.size.height+passwordLabel.frame.origin.y+20, widthSelectSSIDButton, 44)];
//    [configButton addTarget:self action:@selector(saveSSIDorPwdConfig:) forControlEvents:UIControlEventTouchUpInside];
//    [configButton setTitle:@"保存设置" forState:UIControlStateNormal];
//    [configButton setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
//    [configButton.layer setBorderColor:[UIColor colorWithRed:0.455 green:0.761 blue:0.055 alpha:1.000].CGColor];
//    [configButton.layer setBorderWidth:1.0];
//    [self.view addSubview:configButton];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    UILabel *setupPromptLabel = [[UILabel alloc]initWithFrame:CGRectMake(passwordLabel.frame.origin.x, passwordLabel.frame.origin.y + passwordLabel.frame.size.height, passwordLabel.frame.size.width, 200)];
    [setupPromptLabel setText:@"1,无线网络的密码不能低于8位，较安全的密码应该为11位以上且为数字+大写字母+小写字母混合组成。 \n2,无线名称和密码同时只能修改某一项，修改后需手动重新连接到新的无线名或重新输入密码。"];
    [setupPromptLabel setFont:[UIFont systemFontOfSize:14]];
    [setupPromptLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [setupPromptLabel setNumberOfLines:10];
    [setupPromptLabel setTextAlignment:NSTextAlignmentNatural];
    [self.view addSubview:setupPromptLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

//#define TAG_PASSWORD_TEXTFIELD 300003 //无线密码
//#define TAG_SSID_TEXTFIELD 300004 //无线账号
-(void)saveSSIDorPwdConfig:(UIButton *)sender{
    //无线账号
    UITextField *ssidTextField = (UITextField*)[self.view viewWithTag:TAG_SSID_TEXTFIELD];
    NSString *ssidString = [ssidTextField text];
    if (([ssidString length]>25)||([ssidString length]<1)) {
        [[[iToast makeText:NSLocalizedString(@"无线网络的名称不能低于1位长于25位", @"")]
          setGravity:iToastGravityCenter] show:iToastTypeError];
        return;
    }
    //无线密码
    UITextField *pwdTextField = (UITextField*)[self.view viewWithTag:TAG_PASSWORD_TEXTFIELD];
    NSString *pwdString = [pwdTextField text];
    if ([pwdString length]<8) {
        [[[iToast makeText:NSLocalizedString(@"无线网络的密码不能低于8位", @"")]
          setGravity:iToastGravityCenter] show:iToastTypeError];
        return;
    }
    if ([pwdString length]>25) {
        [[[iToast makeText:NSLocalizedString(@"无线网络的密码不能长于25位", @"")]
          setGravity:iToastGravityCenter] show:iToastTypeError];
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *localSSIDString = [ud objectForKey:KEY_ROUTER_SSID];
    NSString *localPWDString = [ud objectForKey:KEY_OF_WIFI_PASSWORD];
    if (([ssidString isEqualToString:localSSIDString])&&([pwdString isEqualToString:localPWDString])) {
        [[[iToast makeText:NSLocalizedString(@"无任何更改,无需保存", @"")]
          setGravity:iToastGravityCenter] show:iToastTypeError];
        return;
    }
    
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  
    NSDictionary *parameters = @{@"Username":@"admin",@"checkEn": @"0",@"Password":pwdString};
    
    NSString *routerDomain = [IPHelpler getGatewayIPAddress];
    NSString *url_login_router = [ud objectForKey:URL_LOGIN_ROUTER];
    [manager POST:[NSString stringWithFormat:@"%@%@",routerDomain,url_login_router] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *sLoginRouterReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        DLog(@"sLoginRouterReturnCode: %@", sLoginRouterReturnCode);
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if ([sLoginRouterReturnCode rangeOfString:@"ssid000 ="].location != NSNotFound) {
            
            NSString *ssidString = [MyTool getSSIDWithString:sLoginRouterReturnCode];
            [ud setObject:ssidString forKey:KEY_ROUTER_SSID];
            //wifi密码
            NSString *pwdString = [MyTool getWIFIPassword:sLoginRouterReturnCode];
            [ud setObject:pwdString forKey:KEY_OF_WIFI_PASSWORD];
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
        
        //通知UI更新状态
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_LOGIN_ROUTER_STATE_CHANGE object:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Error: %@", error);
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setBool:NO forKey:KEY_OF_ISLOGIN];
        [ud setObject:@"未连接" forKey:NET_CONNECT_STATE];
    }];

}

/**
 *  更改密码动作的触发
 *
 *  @param sender 文本框上的按钮
 */
-(void)changePasswordClick:(UIButton *)sender{
    //无线密码
    UITextField *pwdTextField = (UITextField*)[self.view viewWithTag:TAG_PASSWORD_TEXTFIELD];
    NSString *oldpwdString = [pwdTextField text];
    self.stAlertView2 = [[STAlertView alloc]initWithTitle:[NSString stringWithFormat:@"请输入新的无线密码"] message:@"修改密码成功后需要到设置中忽略掉旧网络连接,重新输入密码才能连接到无线网络" textFieldHint:@"无线密码" textFieldValue:oldpwdString cancelButtonTitle:[Config DPLocalizedString:@"cancel"] otherButtonTitle:[Config DPLocalizedString:@"sure"] cancelButtonBlock:^{
        DLog(@"取消修改密码")
    } otherButtonBlock:^(NSString *result) {
        DLog(@"%@",result);
        NSString *pwdString = result;
        if ([pwdString length]<8) {
            [[[iToast makeText:NSLocalizedString(@"无线网络的密码不能低于8位", @"")]
              setGravity:iToastGravityCenter] show:iToastTypeError];
            return;
        }
        if ([pwdString length]>25) {
            [[[iToast makeText:NSLocalizedString(@"无线网络的密码不能长于25位", @"")]
              setGravity:iToastGravityCenter] show:iToastTypeError];
            return;
        }
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

        
        //,@"":@""
        NSDictionary *parameters = @{@"ssidIndex":@"0",@"security_mode": @"psk",@"cipher":@"aes",@"passphrase":pwdString,@"wpsenable":@"disabled",@"wpsMode":@"pbc",@"GO":@"wireless_security.asp"};
        DLog(@"parameters = %@",parameters);
        NSString *routerDomain = [IPHelpler getGatewayIPAddress];
        NSString *url_change_wifi_pwd = [ud objectForKey:URL_MODIFY_WIFI_PASSWORD];
        [manager POST:[NSString stringWithFormat:@"%@%@",routerDomain,url_change_wifi_pwd] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *sChangePwdReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            DLog(@"url = %@,sChangePwdReturnCode = %@",[operation response].URL,sChangePwdReturnCode);
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString *domain = [IPHelpler getGatewayIPAddress];
            NSString *url = [NSString stringWithFormat:@"%@/wireless_security.asp",domain];
            NSString *responseUrl = [NSString stringWithFormat:@"%@",[operation response].URL];
            if ([responseUrl isEqualToString:url]) {
                
                UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"密码已经修改为 %@ 需要到设置中忽略掉旧网络连接,重新输入密码才能连接到无线网络",pwdString] delegate:self cancelButtonTitle:[Config DPLocalizedString:@"sure"] otherButtonTitles:nil, nil];
                [alerView show];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"sChangePwderror = %@",error);
        }];
    }];
    [self.stAlertView2 show];
}

/**
 *  改变无线的名称
 *
 *  @param sender 触发按钮
 */
-(void)changeSSIDClick:(UIButton *)sender{
    UITextField *ssidTextField = (UITextField*)[self.view viewWithTag:TAG_SSID_TEXTFIELD];
    NSString *oldssidString = [ssidTextField text];
    self.stAlertView = [[STAlertView alloc]initWithTitle:[NSString stringWithFormat:@"请输入新的无线名称"] message:@"修改无线名称成功后需要到设置中忽略掉旧网络连接,重新连接到新的无线网络" textFieldHint:@"无线名称" textFieldValue:oldssidString cancelButtonTitle:[Config DPLocalizedString:@"cancel"] otherButtonTitle:[Config DPLocalizedString:@"sure"] cancelButtonBlock:^{
        DLog(@"取消修改")
    } otherButtonBlock:^(NSString *result) {
        DLog(@"%@",result);
        NSString *ssidString = result;
        if (([ssidString length]>25)||([ssidString length]<1)) {
            [[[iToast makeText:NSLocalizedString(@"无线网络的名称不能低于1位长于25位", @"")]
              setGravity:iToastGravityCenter] show:iToastTypeError];
            return;
        }
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

        //,@"":@""
        NSDictionary *parameters = @{@"ssid":ssidString,@"wirelessmode": @"9",@"broadcastssid":@"0",@"ap_isolate":@"0",@"channel":@"1",@"n_bandwidth":@"1",@"n_extcha":@"none",@"wmm_capable":@"on",@"apsd_capable":@"off",@"wl_power":@"HK",@"GO":@"wireless_basic.asp",@"en_wl":@"1",@"enablewireless":@"1"};
        DLog(@"parameters = %@",parameters);
        NSString *routerDomain = [IPHelpler getGatewayIPAddress];
        NSString *url_change_wifi_ssid = [ud objectForKey:URL_MODIFY_WIFI_NAME];
        [manager POST:[NSString stringWithFormat:@"%@%@",routerDomain,url_change_wifi_ssid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *sChangeSSIDReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            DLog(@"url = %@,sChangeSSIDReturnCode = %@",[operation response].URL,sChangeSSIDReturnCode);
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString *domain = [IPHelpler getGatewayIPAddress];
            NSString *url = [NSString stringWithFormat:@"%@/wireless_basic.asp",domain];
            NSString *responseUrl = [NSString stringWithFormat:@"%@",[operation response].URL];
            if ([responseUrl isEqualToString:url]) {
                
                UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"无线名称已经修改为 %@ 需要到设置中重新输入密码连接到新的无线网络",ssidString] delegate:self cancelButtonTitle:[Config DPLocalizedString:@"sure"] otherButtonTitles:nil, nil];
                [alerView show];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"sChangeSSIDerror = %@",error);
            UIAlertView *alerView2 = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"修改失败"] delegate:self cancelButtonTitle:[Config DPLocalizedString:@"sure"] otherButtonTitles:nil, nil];
            [alerView2 show];
        }];
    }];
    [self.stAlertView show];
}
@end
