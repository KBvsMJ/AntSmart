//
//  ForgetPwdViewController.h
//  Project_Aidu
//
//  Created by macmini_01 on 15-1-29.
//  Copyright (c) 2015年 Vooda. All rights reserved.
//

#import "BaseViewController.h"
#import "VerifyViewController.h"
#import "SectionsViewController.h"

@interface ForgetPwdViewController : UIViewController<UIAlertViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
SecondViewControllerDelegate,
UITextFieldDelegate
>
{
    IBOutlet UIView *viewBackground;
    //手机号
    IBOutlet UITextField *txtPhoneNumber;
    //新密码
    IBOutlet UITextField *txtPassWord;
    //旧密码
    IBOutlet UITextField *txtOldWord;
    //确认新密码
    IBOutlet UITextField *txtNewPwd;
    //手机验证码
    IBOutlet UITextField *txtPhoneCode;
    
    //获取手机验证码
    IBOutlet UIButton *btnGetPhoneCode;
    

    
    //记录60秒倒计时
    int secondTime;
    //倒计时timer
    NSTimer *spackTimer;
    //显示倒计时
    UILabel * lblTime;
    UIImageView * imgTime;

}
//存贮后台返回数据
@property(nonatomic,strong)NSDictionary * fetcherDic;
@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) UITextField* areaCodeField;
//获取验证码
- (IBAction)cmd_btn_getCode:(id)sender;

//确认
- (IBAction)cmd_btn_register:(id)sender;

//返回到登录页面
- (IBAction)cmd_btn_back:(id)sender;

@end
