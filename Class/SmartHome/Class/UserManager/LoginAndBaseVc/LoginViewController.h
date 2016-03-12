//
//  LoginViewController.h
//  Project_Aidu
//
//  Created by macmini_01 on 14-11-15.
//  Copyright (c) 2014年 Vooda. All rights reserved.
//

#import "BaseViewController.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate>
{
    //底View
    IBOutlet UIView *viewBackground;
    
    IBOutlet UITextField *txtUserName;
    IBOutlet UITextField *txtPassWord;


    IBOutlet UIImageView *userNameBackground;
    
    IBOutlet UIImageView *passwordBackground;
    
    
    IBOutlet UIButton *registerButton;
    
    NSString *urlStr;
}
//存贮后台返回数据
@property(nonatomic,strong)NSDictionary * fetcherDic;
@property (weak, nonatomic) IBOutlet UIButton *weixinLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *sinaLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *qqLoginButton;

//正常登录
- (IBAction)cmd_btn_login:(id)sender;
//第三方登录
-(IBAction)cmd_btn_theThirdLogin:(id)sender;
//注册
- (IBAction)cmd_btn_register:(id)sender;
//忘记密码
- (IBAction)cmd_btn_forget:(id)sender;


@end
