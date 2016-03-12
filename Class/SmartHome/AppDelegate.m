//
//  AppDelegate.m
//  iroboteer
//
//  Created by yixingman on 2015-01-11.
//  Copyright (c) 2015 iroboteer. All rights reserved.
//

#import "AppDelegate.h"
#import "JVFloatingDrawerViewController.h"
#import "JVFloatingDrawerSpringAnimator.h"
#import "APService.h"
#import "Config.h"
#import "IPHelpler.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "YXM_RouterAuthenticationModel.h"
#import "ConfigViewController.h"
#import "YXMShopIndexViewController.h"
#import "NewsWebViewController.h"
#import "YXMPushMsgTableViewController.h"
#import "MyTool.h"
#import "YXMDatabaseOperation.h"
#import <AFNetworking.h>


//判断当前系统语言的方法
#define CURR_LANG ([[NSLocale preferredLanguages] objectAtIndex:0])

static NSString * const kJVDrawersStoryboardName = @"Drawers";



static NSString * const kJVLeftDrawerStoryboardID = @"JVLeftDrawerViewControllerStoryboardID";
static NSString * const kJVRightDrawerStoryboardID = @"JVRightDrawerViewControllerStoryboardID";

static NSString * const kJVGitHubProjectPageViewControllerStoryboardID = @"JVGitHubProjectPageViewControllerStoryboardID";
static NSString * const kJVDrawerSettingsViewControllerStoryboardID = @"JVDrawerSettingsViewControllerStoryboardID";
static NSString * const kJVRouterManagerViewControllerStoryboardID = @"JVRouterManagerViewControllerStoryboardID";
static NSString * const kJVSmartDeviceManagerViewControllerStoryboardID = @"JVSmartDeviceManagerViewControllerStoryboardID";
static NSString * const kJVUserManagerViewControllerStoryboardID = @"JVUserManagerViewControllerStoryboardID";

@interface AppDelegate ()
{
    NewsWebViewController *webViewController;
}
@property (nonatomic, strong, readonly) UIStoryboard *drawersStoryboard;

@end

@implementation AppDelegate

@synthesize drawersStoryboard = _drawersStoryboard;

/**
 *  进入主程序
 */
-(void)intoMain{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@"intro_screen_viewed" forKey:@"intro_screen_viewed"];
    [UIView animateWithDuration:0.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    } completion:^(BOOL finished) {
        self.window.rootViewController = self.drawerViewController;
    }];
}

/**
 *  初始化应用基础数据
 */
-(void)initBaseData{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    //获取是否设置为审核模式
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:[NSString stringWithFormat:@"http://www.antbang.com/checkstate.php"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *sReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            DTLog(@"sReturnCode = %@",sReturnCode);
            if ([sReturnCode isEqualToString:@"YES"]) {
                [ud setObject:@"YES" forKey:@"checkstate"];
            }else{
                [ud setObject:@"NO" forKey:@"checkstate"];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [ud setObject:@"NO" forKey:@"checkstate"];
        }];
    }
    
    
    //路由器默认IP
    [ud setObject:@"http://192.168.0.1" forKey:URL_ROUTER_DOMAIN];
    //从手机的wifi信息中获取网关ip
    [ud setObject:[NSString stringWithFormat:@"%@",[IPHelpler getGatewayIPAddress]] forKey:URL_ROUTER_DOMAIN];
    //路由器登陆
    [ud setObject:@"/LoginCheck" forKey:URL_LOGIN_ROUTER];
    //获得当前连接到路由器的用户的流量统计列表
    [ud setObject:@"/goform/updateIptAccount" forKey:URL_GET_NET_SPEED];
    //显示当前dhcp列表URL_DHCP_LIST
    [ud setObject:@"/lan_dhcp_clients.asp" forKey:URL_DHCP_LIST];
    //通过路由扫描周围的WiFi列表
    [ud setObject:@"/goform/WDSScan" forKey:URL_WDSSCAN_WIFILIST];
    //获取路由器的基本信息
    [ud setObject:@"/system_status.asp" forKey:URL_ROUTER_BASEINFO];
    //通过mac地址禁用设备上网
    [ud setObject:@"/goform/SafeMacFilter" forKey:URL_DISABLE_DEVICE];
    //修改wifi密码
    [ud setObject:@"/goform/wirelessSetSecurity" forKey:URL_MODIFY_WIFI_PASSWORD];
    //修改wifi名称和获取无线基本信息
    [ud setObject:@"/goform/wirelessBasic" forKey:URL_MODIFY_WIFI_NAME];
    //获取无线基本信息
    [ud setObject:@"/goform/wirelessInitBasic" forKey:URL_GET_WIFI_BASE_SETUP_INFO];
    //设置无线中继
    [ud setObject:@"/goform/wirelessMode" forKey:URL_WIRELESS_EXTRA];
    //上网设置
    [ud setObject:@"/goform/AdvSetWan" forKey:URL_ADVSET_WAN];
    [ud synchronize];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //初始化基础数据
    [self initBaseData];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //配置界面
    [self configureDrawerViewController];
    //初始化语言设置
    [self initLanguage];
    //清除角标
    [UIApplication sharedApplication].applicationIconBadgeNumber =0;
    //当前wifi信息
    [self fetchSSIDInfo];
    //登陆到路由器
    YXM_RouterAuthenticationModel *routerAuth = [YXM_RouterAuthenticationModel sharedManager];
    [routerAuth loginRouter];
    //判断是否需要进入引导页面
    self.window.rootViewController = self.drawerViewController;
    
    //初始化推送
    [self initPushSDK:launchOptions];
    
    [self.window makeKeyAndVisible];
    return YES;
}


- (id)fetchSSIDInfo {
    
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    DLog(@"Supported interfaces: %@", ifs);
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        DLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    if ([info count]<1) {
        [ud setObject:@"非WiFi" forKey:NET_CONNECT_STATE];
    }
    return info;
}
/**
 *  初始化语言设置
 */
-(void)initLanguage{
    //判断语言初始化
    languageString = [[NSString alloc] init];
    NSUserDefaults *ud =   [NSUserDefaults standardUserDefaults];
    languageString =[ud objectForKey:LOCAL_LANGUAGE];
    NSString *systemLanguage = ([[NSLocale preferredLanguages] objectAtIndex:0]);
    //语言初始化设置 第一次如果我们设置的字段为空则根据系统的语言相对应赋值 这样通系统的本地国际化相同 但由于我们自定义了这样的字段我们可以一键切换语言
    if ([languageString  length]==0||[languageString isEqualToString:@""]||languageString ==nil) {
        if ([systemLanguage rangeOfString:@"zh-Hans"].location != NSNotFound) {
            languageString = @"zh-Hans";
        }else if ([systemLanguage rangeOfString:@"zh-Hant"].location != NSNotFound){
            languageString = @"zh-Hant";
        }else if ([systemLanguage rangeOfString:@"en"].location != NSNotFound){
            languageString = @"en";
        }
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application {}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {}

- (void)applicationWillTerminate:(UIApplication *)application {}

#pragma mark - Drawer View Controllers

- (JVFloatingDrawerViewController *)drawerViewController {
    if (!_drawerViewController) {
        _drawerViewController = [[JVFloatingDrawerViewController alloc] init];
    }
    
    return _drawerViewController;
}

#pragma mark Sides

- (UITableViewController *)leftDrawerViewController {
    if (!_leftDrawerViewController) {
        _leftDrawerViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kJVLeftDrawerStoryboardID];
    }
    
    return _leftDrawerViewController;
}

- (UITableViewController *)rightDrawerViewController {
    if (!_rightDrawerViewController) {
        _rightDrawerViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kJVRightDrawerStoryboardID];
    }
    
    return _rightDrawerViewController;
}

#pragma mark Center

- (UIViewController *)githubViewController {
    if (!_githubViewController) {
        _githubViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kJVGitHubProjectPageViewControllerStoryboardID];
    }
    
    return _githubViewController;
}

- (UIViewController *)routerManagerViewController {
    if (!_routerManagerViewController) {
        _routerManagerViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kJVRouterManagerViewControllerStoryboardID];
    }
    
    return _routerManagerViewController;
}


- (UIViewController *)smartDeviceViewController {
    if (!_smartDeviceViewController) {
        _smartDeviceViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kJVSmartDeviceManagerViewControllerStoryboardID];
    }
    
    return _smartDeviceViewController;
}

- (UIViewController *)drawerSettingsViewController {
    if (!_drawerSettingsViewController) {
        _drawerSettingsViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kJVDrawerSettingsViewControllerStoryboardID];
    }
    
    return _drawerSettingsViewController;
}

- (UIViewController *)loginViewController {
    
    if (!_loginViewController) {
        _loginViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kJVUserManagerViewControllerStoryboardID];
    }

    
    return _loginViewController;
}

- (JVFloatingDrawerSpringAnimator *)drawerAnimator {
    if (!_drawerAnimator) {
        _drawerAnimator = [[JVFloatingDrawerSpringAnimator alloc] init];
    }
    
    return _drawerAnimator;
}


-(UINavigationController *)configNavCtrl{
    if (!_configNavCtrl) {
        _configViewCtrl = [[ConfigViewController alloc]init];
        _configNavCtrl = [[UINavigationController alloc]initWithRootViewController:_configViewCtrl];
    }
    return _configNavCtrl;
}


-(UINavigationController *)shopNavCtrl{
    if (!_shopViewCtrl) {
        _shopViewCtrl = [[YXMShopIndexViewController alloc]init];
        _shopNavCtrl = [[UINavigationController alloc]initWithRootViewController:_shopViewCtrl];
    }
    return _shopNavCtrl;
}

-(UINavigationController *)pushMsgNavCtrl{
    if (!_pushMsgTableViewCtrl) {
        _pushMsgTableViewCtrl = [[YXMPushMsgTableViewController alloc]init];
        _pushMsgNavCtrl = [[UINavigationController alloc]initWithRootViewController:_pushMsgTableViewCtrl];
    }
    return _pushMsgNavCtrl;
}

- (UIStoryboard *)drawersStoryboard {
    if(!_drawersStoryboard) {
        _drawersStoryboard = [UIStoryboard storyboardWithName:kJVDrawersStoryboardName bundle:nil];
    }
    
    return _drawersStoryboard;
}


- (void)configureDrawerViewController {
    self.drawerViewController.leftViewController = self.leftDrawerViewController;
    self.drawerViewController.rightViewController = self.rightDrawerViewController;
    self.drawerViewController.centerViewController = self.drawerSettingsViewController;
    
    self.drawerViewController.animator = self.drawerAnimator;
    
    self.drawerViewController.backgroundImage = [UIImage imageNamed:@"sky.jpg"];
}

#pragma mark - Global Access Helper

+ (AppDelegate *)globalDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)toggleLeftDrawer:(id)sender animated:(BOOL)animated {
    [self.drawerViewController toggleDrawerWithSide:JVFloatingDrawerSideLeft animated:animated completion:nil];
}

- (void)toggleRightDrawer:(id)sender animated:(BOOL)animated {
    [self.drawerViewController toggleDrawerWithSide:JVFloatingDrawerSideRight animated:animated completion:nil];
}

- (void)toggleNoneDrawer:(id)sender animated:(BOOL)animated {
    [self.drawerViewController toggleDrawerWithSide:JVFloatingDrawerSideRight animated:animated completion:nil];
}


-(void)initPushSDK:(NSDictionary *)launchOptions{
    // Required
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
#else
    //categories 必须为nil
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
#endif
    // Required
    [APService setupWithOption:launchOptions];
    [APService setAlias:@"yixingman003" callbackSelector:@selector(pushAction) object:nil];
    [SMS_SDK registerApp:@"6b875353937c" withSecret:@"70feaa5b7a78f0fde2f7601ae92c5187"];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Required
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required
    [APService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    DTLog(@"%@",userInfo);
    if ([userInfo isKindOfClass:[NSDictionary class]]) {
        NSString *url = [userInfo objectForKey:@"url"];
        NSString *title = [userInfo objectForKey:@"title"];
        NSString *msgid = [userInfo objectForKey:@"msgid"];
        DTLog(@"url = %@",url);
        [self intoNews:url andTitle:title andMsgID:msgid];
    }
    // IOS 7 Support Required
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

-(void)pushAction{
    DLog(@"收到别名推送");
}

-(void)tagsAliasCallback:(int)iResCode
                    tags:(NSSet*)tags
                   alias:(NSString*)alias
{
    DLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}


//进入新闻类界面
-(void)intoNews:(NSString*)content_url andTitle:(NSString *)title andMsgID:(NSString *)msgid{
    //存储推送过来的数据
    YXMPushNotiModel *model = [[YXMPushNotiModel alloc]init];
    model.pushNotiID =  msgid;
    model.pushNotiIsRead = @"NO";
    model.pushNotiTitle = title;
    model.pushNotiURL = content_url;
    model.pushNoteReceiveDate = [NSDate date];
    YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
    [db openDatabase];
    [db savePushData:model];
    //进入web页面
    if (webViewController==nil) {
        webViewController=[[NewsWebViewController alloc]init];
        [webViewController reloadWebviewurl:content_url andTitle:title];
    }else
    {
        [webViewController reloadWebviewurl:content_url andTitle:title];
    }
    UINavigationController *navCtrl = [[UINavigationController alloc]initWithRootViewController:webViewController];
    //导航栏颜色
    [navCtrl.navigationBar setBarTintColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000]];
    [self.window setRootViewController:navCtrl];
}


@end
