//
//  ConfigViewController.h
//  WiFiSwitch2
//
//  Created by sunrun on 14-10-13.
//  Copyright (c) 2014年 sunrun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "smartConfig.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "MDRadialProgressLabel.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "AsyncSocket.h"

@class YXMAutoConfigPlugViewController;
@class YXMManualViewController;

@interface ConfigViewController : UIViewController<UITextFieldDelegate,AsyncSocketDelegate>{
    //插座图标
    UIImageView *_plugImageView;
    //图标是否亮
    BOOL _isLight;
    //手动输入路由器的wifi密码来配置设备
    YXMManualViewController *_manualConfigCtrl;
    //自动获取路由器的wifi密码来配置设备
    YXMAutoConfigPlugViewController *_autoConfigConfigCtrl;
}

@end
