//
//  YXMAutoConfigPlugViewController.h
//  SmartHome
//
//  Created by iroboteer on 15/5/4.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "smartConfig.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "MDRadialProgressLabel.h"
#import "TDO.h"

@class STAlertView;

@interface YXMAutoConfigPlugViewController : UIViewController
{
    MDRadialProgressView *progressView;
    int value;
    NSTimer *time;
    smartConfig *smart;
    MDRadialProgressTheme *newTheme;
 
    //将字节命令转换为字典
    TDO *tdo;
    //配置之前的设备数量
    NSInteger _beforeDeviceCount;
    //配置之后的设备数量
    NSInteger _afterDeviceCount;
    UIScrollView *configBaseView;
    UILabel *mainPromptLabel;
}

//配置设备完成后的提示
@property (atomic,strong) STAlertView *findDeviceResultAlertView;
- (void)startConfig;
- (void)initConfigView;
@end
