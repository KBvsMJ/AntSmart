//
//  YXMManualViewController.h
//  SmartHome
//
//  Created by iroboteer on 15/5/4.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDO.h"

#import "smartConfig.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "MDRadialProgressLabel.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "AsyncSocket.h"


@class STAlertView;
@interface YXMManualViewController : UIViewController<UITextFieldDelegate,AsyncSocketDelegate>
{
    MDRadialProgressView *progressView;
    BOOL isProgress;
    int value;
    NSTimer *time;
    smartConfig *smart2;
    MDRadialProgressTheme *newTheme;
    
    
    //将字节命令转换为字典
    TDO *tdo;
    //配置之前的设备数量
    NSInteger _beforeDeviceCount;
    //配置之后的设备数量
    NSInteger _afterDeviceCount;
    //根视图
    UIScrollView *configBaseView;
    //主提示标签
    UILabel *mainPromptLabel;
    //ssid的文本框
    UITextField *_ssidTextField;
    //无线网络的密码的文本框
    UITextField *_passwordTextField;
    //开始配置按钮
    UIButton *_startConfigButton;
    //返回上一步的按钮
    UIButton *_backButton;
    //无线名称和无线密码的容器视图
    UIView *_accountAndPwdView;
}

//配置设备完成后的提示
@property (atomic,strong) STAlertView *findDeviceResultAlertView;
@end
