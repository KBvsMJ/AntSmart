//
//  LoginViewController.m
//  Project_Aidu
//
//  Created by macmini_01 on 14-11-15.
//  Copyright (c) 2014年 Vooda. All rights reserved.
//

#import "LoginViewController.h"

#import "RegisterViewController.h"
#import "ForgetPwdViewController.h"
#import "AppDelegate.h"

#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "JVFloatingDrawerViewController.h"

#import "Config.h"
@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize fetcherDic;

#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtUserName) {
        [txtPassWord becomeFirstResponder] ;
    }
    else
    {
        [txtPassWord resignFirstResponder];
    }
    [self userInterfaceAdapter];
    return YES;
}

//关闭键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtUserName resignFirstResponder];
    [txtPassWord resignFirstResponder];
    [self userInterfaceAdapter];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self userInterfaceAdapter];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"navbar_small"]];
    //密码隐藏
    txtPassWord.secureTextEntry = YES;
    txtUserName.delegate = self;
    txtPassWord.delegate = self;
    [txtPassWord resignFirstResponder];
    [txtUserName resignFirstResponder];
    txtUserName.tintColor = [UIColor greenColor];
    txtPassWord.tintColor = [UIColor greenColor];
    
    [self.qqLoginButton setHidden:YES];
    [self.weixinLoginButton setHidden:YES];
    [self.sinaLoginButton setHidden:YES];
    
    [self userInterfaceAdapter];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self userInterfaceAdapter];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self userInterfaceAdapter];
}

/**
 *  适配ui的尺寸
 */
-(void)userInterfaceAdapter{
    
    NSInteger spaceWidth = (SCREEN_CGSIZE_WIDTH-320);
    UIImageView *s = userNameBackground;
    if (s.frame.size.width+spaceWidth>SCREEN_CGSIZE_WIDTH) {
        spaceWidth = 0;
    }
    [s setFrame:CGRectMake(s.frame.origin.x, s.frame.origin.y, s.frame.size.width+spaceWidth, s.frame.size.height)];
    
    UIImageView *a = passwordBackground;
    [a setFrame:CGRectMake(a.frame.origin.x, a.frame.origin.y, a.frame.size.width+spaceWidth, a.frame.size.height)];
    
    UIButton *r = registerButton;
    [r setFrame:CGRectMake(r.frame.origin.x+spaceWidth, r.frame.origin.y, r.frame.size.width, r.frame.size.height)];
}

//登录相关的操作
-(void)loginFetcherAbout
{
  
}

//下载数据库文件
-(void)downloadDbFile
{

    
}
//正常登录
- (IBAction)cmd_btn_login:(id)sender
{
    [self loginInfoSubmit];
}
//第三方登录
-(IBAction)cmd_btn_theThirdLogin:(id)sender
{

    

}
-(void)loadProgressHUDView
{

}
//注册
- (IBAction)cmd_btn_register:(id)sender
{
    RegisterViewController * registerVc = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    [self.navigationController pushViewController:registerVc animated:YES];
}
//忘记密码
- (IBAction)cmd_btn_forget:(id)sender
{
    ForgetPwdViewController * forgetVc = [[ForgetPwdViewController alloc] initWithNibName:@"ForgetPwdViewController" bundle:nil];
    [self.navigationController pushViewController:forgetVc animated:YES];
}

- (IBAction)leftAction:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}
- (IBAction)rightAction:(id)sender {
    
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:[[AppDelegate globalDelegate] drawerSettingsViewController]];
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}



-(void)loginInfoSubmit{
    NSString *username = txtUserName.text;
    NSString *password = txtPassWord.text;
    if ([username length]<1||[username length]>18) {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"loginreturninfotitle", nil)
                                                      message:[Config DPLocalizedString:@"user_login_username_length_error"]
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                            otherButtonTitles:nil, nil];
        [alert show];
        return;
    }else{
        if ([password length]<1||[password length]>18) {
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"loginreturninfotitle", nil)
                                                          message:[Config DPLocalizedString:@"user_login_password_length_error"]
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    //发送登录的post请求
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = @{@"username": username,@"password": password};
    [manager POST:[NSString stringWithFormat:@"%@/usermanager.php?act=login",URL_DOMAIN] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *sRegReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"sRegReturnCode: %@", sRegReturnCode);
        NSString *echo = @"";
        NSInteger iRegReturnCode = [sRegReturnCode integerValue];
        if(iRegReturnCode > 0) {
            echo = @"登录成功";
            NSDictionary *userInfo = @{@"uid":sRegReturnCode,@"username":txtUserName.text};
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_LOGIN_STATE_CHANGE object:nil userInfo:userInfo];
            [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
            [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:[[AppDelegate globalDelegate] drawerSettingsViewController]];
            [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
            
        } else if(iRegReturnCode == -1) {
            echo = @"用户不存在,或者被删除";
        }else if(iRegReturnCode == -2){
            echo = @"密码错";
        }else{
            echo = @"未定义";
        }
        if (iRegReturnCode<1) {
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"loginreturninfotitle", nil)
                                                          message:echo
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                otherButtonTitles:nil, nil];
            [alert show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


@end
