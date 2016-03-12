//
//  AppDelegate.m
//  iroboteer
//
//  Created by yixingman on 2015-01-11.
//  Copyright (c) 2015 iroboteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import <SMS_SDK/SMS_SDK.h>


@class ConfigViewController;
@class JVFloatingDrawerViewController;
@class JVFloatingDrawerSpringAnimator;
@class YXMShopIndexViewController;
@class YXMPushMsgTableViewController;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) JVFloatingDrawerViewController *drawerViewController;
@property (nonatomic, strong) JVFloatingDrawerSpringAnimator *drawerAnimator;

@property (nonatomic, strong) UITableViewController *leftDrawerViewController;
@property (nonatomic, strong) UITableViewController *rightDrawerViewController;
@property (nonatomic, strong) UIViewController *githubViewController;
@property (nonatomic, strong) UIViewController *drawerSettingsViewController;
@property (nonatomic, strong) UIViewController *routerManagerViewController;
@property (nonatomic, strong) UIViewController *smartDeviceViewController;
@property (nonatomic, strong) UIViewController *loginViewController;

//插座配置视图相关
@property (nonatomic, strong) ConfigViewController *configViewCtrl;
@property (nonatomic, strong) UINavigationController *configNavCtrl;

//推荐购买相关的
@property (nonatomic,strong) YXMShopIndexViewController *shopViewCtrl;
@property (nonatomic,strong)  UINavigationController *shopNavCtrl;

//通知相关的
@property (nonatomic,strong) YXMPushMsgTableViewController *pushMsgTableViewCtrl;
@property (nonatomic,strong)  UINavigationController *pushMsgNavCtrl;


+ (AppDelegate *)globalDelegate;

- (void)toggleLeftDrawer:(id)sender animated:(BOOL)animated;
- (void)toggleRightDrawer:(id)sender animated:(BOOL)animated;
- (void)toggleNoneDrawer:(id)sender animated:(BOOL)animated;
//进入主程序
-(void)intoMain;
@end
