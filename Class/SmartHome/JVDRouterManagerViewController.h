//
//  JVDRouterManagerViewController.m
//  路由器管理的主界面
//
//  Created by yixingman on 2015-01-15.
//  Copyright (c) 2015 antbang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurveGraphController.h"
#import <STAlertView/STAlertView.h>
#import "MyReachability.h"

@class ZJLViewController;
@class YXMRelayViewController;
@class YXMOptimizeNetViewController;
@class YXMWiFiSetupViewController;
@class YXMWanSetupViewController;
@class YXMSpeedAdjustmentViewController;
@class YXMWiFiSwitchViewController;

@class MLTableAlert;
@interface JVDRouterManagerViewController : UIViewController<UIScrollViewDelegate>
{
    //当前网速
    UILabel *_networkSpeedLabel;
    //显示网速的单位
    UILabel *_kbsLabel;

    //更新网速的定时器
    NSTimer *_updateSpeedTimer;
    NSDate *pauseStart;
    NSDate *previousFireDate;
    //连接信息
    UILabel *_ssidLabel;
    //设备的数量
    UILabel *_deviceNumberLabel;
    //是否登录的标记
    UILabel *_loginStateLabel;
    //提示用户登录路由器
    UIView *_loginPromptView;
    //当前网络连接状态
    NSInteger _currentConnectState;
    
    //蹭网管理
    ZJLViewController *zjlCtrl;
    //万能中继
    YXMRelayViewController *relayNetCtrl;
    //网络优化
    YXMOptimizeNetViewController *optimizeNetCtrl;
    //WiFi设置
    YXMWiFiSetupViewController *wifiSetupCtrl;
    //穿墙提速
    YXMSpeedAdjustmentViewController *speedAdjustmentCtrl;
    //上网设置
    YXMWanSetupViewController *wanSetupmentCtrl;
    //wifi开关
    YXMWiFiSwitchViewController *wifiSwitchCtrl;
    //功能区滚动视图的页码
    UIPageControl *_myPageCtrl;
    //是否显示路由器基本信息的弹出框
    BOOL _isShowRouterBaseInfoWindow;
    //重新获取当前连接的SSID的定时器
    NSTimer *_updateSSIDTimer;
    
    //显示路由器的简要信息
    UIView *_routerFunctionGruideView;
    UILabel *_wanConnectStateLabel;
    UILabel *_speedLabel;
    
    //当前网络的可达状态
    NetworkStatus _currentNetworkStatus;
}
@property (atomic,strong) STAlertView *stAlertView;

@property (atomic,strong) STAlertView *stAlertView2;

/**
 *  显示路由器基本信息的弹出窗口
 */
@property (strong, nonatomic) MLTableAlert *tableAlertView;
@end
