//
//  HASmallCollectionViewController.h
//  应用程序的主界面
//1、显示登录信息和登录的入口，
//2、显示路由器简要信息和进入路由器管理的入口
//3、显示最近常用的设备
//
//  Created by yixingman on 11/03/15.
//  Copyright (c) 2015 yixingman. All rights reserved.
//

@import UIKit;

#import "HAPaperCollectionViewController.h"
#import "CurveGraphController.h"
#import "JVDrawerSettingsTableViewController.h"
#import <UIImageView+WebCache.h>
#import "MyReachability.h"

@class YXMUserManagerViewController;
@class YXMPlugNetCtrlCenter;
@interface HASmallCollectionViewController : HAPaperCollectionViewController
{
    UIButton *_headButton;
    NSMutableArray *_cellArray;
    NSMutableArray *_deviceDataArray;
    UIView *_topView;
    YXMUserManagerViewController *_usermanagerCtrl;
    
    CurveGraphController *_curveGraphCtrl;
    CGRect graphRect;
    //更新网速的定时器
    NSTimer *_updateSpeedTimer;
    NSDate *pauseStart;
    NSDate *previousFireDate;
    
    UIImageView *_backgroundImageView;
    UIImageView *_loginBackgroundImageView;
    UIView *_functionGuideView;
    CGFloat heightOfFunctionView;
    CGFloat HeightOfFunctionViewSpace;
    CGFloat heightOfDeviceListTitleView;
    UIView *_routerFunctionGruideView;
    UIView *_addNewDeviceFunctionGuideView;
    UIView *_sceneModelFunctionGuideView;
    
    UILabel *_wanConnectStateLabel;
    //当前网速
    UILabel *_networkSpeedLabel;
    UILabel *_kbsLabel;
    UILabel *_speedLabel;
    
    UIImageView *_headImageView;
    UILabel *_loginLabel;
    UIButton *_exitButton;
    
    YXMPlugNetCtrlCenter *_net;
    //当前网络的可达状态
    NetworkStatus _currentNetworkStatus;
}
@property (atomic, getter=isFullscreen) BOOL fullscreen;

-(void)refreshCollection;
@end
