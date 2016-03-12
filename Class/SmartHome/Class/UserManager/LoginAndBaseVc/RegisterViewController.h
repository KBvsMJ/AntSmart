//
//  RegisterViewController.h
//  Project_Aidu
//
//  Created by macmini_01 on 14-11-20.
//  Copyright (c) 2014年 Vooda. All rights reserved.
//

#import "BaseViewController.h"
#import "SectionsViewController.h"
@protocol SecondViewControllerDelegate;
@interface RegisterViewController : UIViewController<
UIAlertViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
SecondViewControllerDelegate,
UITextFieldDelegate
>
{
    
    IBOutlet UIView *viewBackground;
    //手机号
    IBOutlet UITextField *txtPhoneNumber;
    //注册密码
    IBOutlet UITextField *txtPassWord;
    //手机验证码
    IBOutlet UITextField *txtPhoneCode;

    //获取手机验证码
    IBOutlet UIButton *btnGetPhoneCode;
    
    IBOutlet UIButton *btnSelect;

    
    //记录60秒倒计时
    int secondTime;
    //倒计时timer
    NSTimer *spackTimer;
    //显示倒计时
    UILabel * lblTime;
    UIImageView * imgTime;
    
}
@property(nonatomic,assign)BOOL isClick ;
//存贮后台返回数据
@property(nonatomic,strong)NSDictionary * fetcherDic;
@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) UITextField* areaCodeField;

//获取验证码
- (IBAction)cmd_btn_getCode:(id)sender;

//注册
- (IBAction)cmd_btn_register:(id)sender;

//阅读条款选择框
- (IBAction)cmd_btn_readSelect:(id)sender;

//阅读条款
- (IBAction)cmd_btn_readRule:(id)sender;

//返回到登录页面
- (IBAction)cmd_btn_back:(id)sender;

@end
