//
//  HASmallCollectionViewController.m
//  主界面-
// 【登陆按钮以及登陆状态标签】
// 【设备搜索按钮】
// 【已添加设备的缩略图】
//
//
//  Created by Heberti Almeida on 11/02/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

#import "HASmallCollectionViewController.h"
#import "HACollectionViewLargeLayout.h"
#import "HACollectionViewSmallLayout.h"
#import "HACollectionViewLargeLayout.h"
#import "HATransitionLayout.h"
#import "HATransitionController.h"
#import "HADeviceCollectionViewCell.h"
#import "AppDelegate.h"
#import "JVFloatingDrawerViewController.h"
#import "YXMUserManagerViewController.h"
#import "UIView+Shadow.h"
#import "YXMTimerModel.h"
#import "APService.h"
#import "CurveGraphController.h"
#import "YXM_RouterAuthenticationModel.h"
#import "YXMTrafficStatistics.h"
#import "Config.h"
#import "IPDashedLineView.h"
#import "IPDashedBorderedView.h"
#import "YXMPlugNetCtrlCenter.h"
#import "YXMDatabaseOperation.h"
#import <iToast/iToast.h>
#import <AFNetworking.h>


#define CELL_ID @"CELL_ID"

@interface HASmallCollectionViewController ()<CellStateChangeDelegate>

@property (nonatomic, assign) NSInteger slide;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIImageView *topImage;
@property (nonatomic, strong) UIImageView *reflected;
@property (nonatomic, strong) NSArray *galleryImages;
@property (nonatomic, strong) HACollectionViewLargeLayout *largeLayout;
@property (nonatomic, strong) HACollectionViewSmallLayout *smallLayout;

@property (nonatomic, getter=isTransitioning) BOOL transitioning;

@end

@implementation HASmallCollectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    //插座网络相关
    [self launchNetComponent];
    //登陆后更新用户头像和帐号
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:NOTI_LOGIN_STATE_CHANGE object:nil];
    //初始化数据
    [self initData];
    
    //初始化主页面
    [self initMainPage];
    
    //获得网络流量统计页面
    YXMTrafficStatistics *statistics = [[YXMTrafficStatistics alloc]init];
    [statistics getNetworkSpeed];
    
    //每隔三秒获取下行流量的定时器
    _updateSpeedTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateSelectSpeed) userInfo:nil repeats:YES];

    //设备缩略图布局变更通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCollectionViewLayout:) name:NOTI_CHANGE_LAYOUT object:nil];
    //更新网速标签
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetSpeed:) name:NOTI_UPDATE_NET_SPEED object:nil];
    //网络可达性
    [self initReachability];
    //新设备加入的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeviceList:) name:NOTI_NEW_DEVICE_INSERT object:nil];
    //更新设备的名称
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeviceName:) name:NOTI_CHANGE_DEVICE_NICKNAME object:nil];
}

/**
 *  初始化主页面
 */
-(void)initMainPage{
    _smallLayout = [[HACollectionViewSmallLayout alloc] init];
    _largeLayout = [[HACollectionViewLargeLayout alloc] init];
    //创建背景界面
    [self createBackground];
    //创建登录视图
    [self createLoginView];
    //创建功能引导视图
    [self createFunctionGuideView];
    //对collection进行初始化
    self.collectionView.collectionViewLayout = _smallLayout;
    self.collectionView.clipsToBounds = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
}

/**
 *  初始化网络状态监听组件
 */
-(void)initReachability{
    //网络状态的改变
    MyReachability * reach = [MyReachability reachabilityWithHostname:@"www.baidu.com"];
    
    reach.reachableBlock = ^(MyReachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _wanConnectStateLabel.text = [Config DPLocalizedString:reachability.currentReachabilityString];
            //当网络处于手机移动网络状态下时将网速设置为--
            if (reachability.currentReachabilityStatus == ReachableViaWWAN) {
                [_speedLabel setText:@"--"];
            }
            _currentNetworkStatus = reachability.currentReachabilityStatus;
        });
    };
    
    reach.unreachableBlock = ^(MyReachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //当网络处于未连接状态时候将网速设置为0KB,连接状态提示文字也作出相应变更
            _wanConnectStateLabel.text = [Config DPLocalizedString:reachability.currentReachabilityString];
            [_speedLabel setText:@"0Kb/s"];
            _currentNetworkStatus = reachability.currentReachabilityStatus;
        });
    };
    
    [reach startNotifier];
}


/**
 * 初始化数据
 */
-(void)initData{
    {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
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
    //存储控制面板也就是collection的cell
    if (!_cellArray) {
        _cellArray = [[NSMutableArray alloc]init];
    }
    _deviceDataArray = [[NSMutableArray alloc]init];
    
    NSArray *deviceNameArray = [[NSArray alloc]initWithObjects:@"模拟设备",@"模拟设备1",@"模拟设备2",@"模拟设备3", nil];
    NSArray *deviceMacArray = [[NSArray alloc]initWithObjects:@"7c:dd:90:7e:f1:45",@"7C:DD:90:7E:F0:46",@"7C:DD:90:7E:F0:47",@"7C:DD:90:7E:F0:48", nil];
    NSArray *deviceIPArray = [[NSArray alloc]initWithObjects:@"192.168.0.200",@"192.168.0.201",@"192.168.0.202",@"192.168.0.203",@"192.168.0.204", nil];
    YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
    [db openDatabase];
    for (int i=0; i<[deviceNameArray count]; i++) {
        YXMDeviceInfoModel *data = [[YXMDeviceInfoModel alloc]init];
        //设备编号
        NSString *device_mac = [deviceMacArray objectAtIndex:i];
        [data setDevice_id:device_mac];
        //设备的头像
        [data setDevice_head:@"virtual_device"];
        //Type 设备类型 0插座 int
        NSString *device_type_s = @"0";
        NSInteger device_type_i = [device_type_s integerValue];
        [data setDevice_type:device_type_i];
        //设备的名称
        [data setDevice_name:[NSString stringWithFormat:@"%@",[deviceNameArray objectAtIndex:i]]];
        //设备的开关状态
        NSString *device_state_s = @"0";
        NSInteger device_state_i = [device_state_s integerValue];
        [data setDevice_state:device_state_i];
        //设备的网络状态
        [data setDevice_net_state:EnumDeviceNetStateLocalOffline];
        //设备的索引,建议使用数据库中的索引
        [data setDevice_selectIndex:0];
        //设备的ip地址
        [data setDevice_local_ip:[deviceIPArray objectAtIndex:i]];
        //设备的mac地址
        [data setDevice_mac_address:device_mac];
        //曾经控制过设备的人数
        NSString *device_TotalNumber_s = @"1";
        NSInteger device_TotalNumber_i = [device_TotalNumber_s integerValue];
        [data setDevice_type:device_TotalNumber_i];
        //当前有权限控制设备的人数
        NSString *device_Authority_s = @"1";
        NSInteger device_Authority_i = [device_Authority_s integerValue];
        [data setDevice_Authority:device_Authority_i];
        data.device_timerlist = [[NSMutableArray alloc]init];
        for (int j=0; j<3; j++) {
            YXMTimerModel *oTimer = [[YXMTimerModel alloc]init];
            [oTimer setTimer_name:[NSString stringWithFormat:@"定时名称%d",j]];
            [oTimer setTimer_id:[NSString stringWithFormat:@"%d%d",i,j]];
            [oTimer setTimer_period:@"0,1,2,3,4,5"];
            [oTimer setTimer_isactive:YES];
            [oTimer setTimer_start_hour:@"15"];
            [oTimer setTimer_start_minutes:@"18"];
            [oTimer setTimer_start_isuse:@"YES"];
            [oTimer setTimer_close_hour:@"16"];
            [oTimer setTimer_close_minutes:@"19"];
            [oTimer setTimer_close_isuse:@"YES"];
            [data.device_timerlist addObject:oTimer];
        }
        /**
         *  判断内存的设备集合中是否存在广播接收到的设备信息，如果没有则加入内存集合中；
         */
        BOOL isExist = NO;
        for (YXMDeviceInfoModel *tempData in _deviceDataArray) {
            if ([tempData.device_id isEqualToString:device_mac]) {
                isExist = YES;
            }
        }
        if (!isExist) {
            [_deviceDataArray addObject:data];
            [db savePlugDeviceWithModelData:data];
        }

    }
    
}


/**
 *  读取最新的设备信息
 */
-(void)readLastDeviceInfo{
    return;
    @try {
        YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
        [db openDatabase];
        NSArray *plugDataArray = [db readAllPlugData];
        
        [_deviceDataArray setArray:plugDataArray];
        [self.collectionView reloadData];
    }
    @catch (NSException *exception) {
        DTLog(@"%@",exception);
    }
    @finally {
        
    }
}

/**
 *  创建主界面的背景视图
 */
-(void)createBackground{
    _backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_backgroundImageView setImage:[UIImage imageNamed:@"主页背景图"]];
    [self.view insertSubview:_backgroundImageView atIndex:0];
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_CGSIZE_WIDTH, SCREEN_CGSIZE_HEIGHT - (_smallLayout.itemSize.height-_smallLayout.sectionInset.bottom) - 64)];
    [self.view addSubview:_topView];
    UILabel *deviecPromptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,_topView.frame.size.height-20, SCREEN_CGSIZE_WIDTH, 20)];
    [deviecPromptLabel setBackgroundColor:[UIColor clearColor]];
    [deviecPromptLabel setText:@"管理智能设备"];
    [deviecPromptLabel setFont:[UIFont systemFontOfSize:12]];
    [deviecPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [deviecPromptLabel setTextColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000]];
    [_topView addSubview:deviecPromptLabel];
}

/**
 *  创建登录视图
 */
-(void)createLoginView{
    _loginBackgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_CGSIZE_WIDTH, SCREEN_CGSIZE_HEIGHT*0.13)];
    [_loginBackgroundImageView setImage:[UIImage imageNamed:@"登陆引导界面背景"]];
    [_topView addSubview:_loginBackgroundImageView];
    [_loginBackgroundImageView setUserInteractionEnabled:YES];
    
    CGFloat heightOfUserHeadImageView = _loginBackgroundImageView.frame.size.height/2;
    _headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(heightOfUserHeadImageView/2, heightOfUserHeadImageView/2, heightOfUserHeadImageView, heightOfUserHeadImageView)];
    [_headImageView setImage:[UIImage imageNamed:@"招呼--按钮"]];
    [_loginBackgroundImageView addSubview:_headImageView];
    [_headImageView setUserInteractionEnabled:YES];
    
    _loginLabel = [[UILabel alloc]initWithFrame:CGRectMake(_headImageView.frame.origin.x+_headImageView.frame.size.width + 10, _headImageView.frame.origin.y, _loginBackgroundImageView.frame.size.width/2, heightOfUserHeadImageView)];
    [_loginLabel setText:@" 请登陆享受更多精彩！"];
    [_loginLabel setBackgroundColor:[UIColor clearColor]];
    [_loginLabel setTextColor:[UIColor whiteColor]];
    [_loginLabel setFont:[UIFont systemFontOfSize:14]];
    [_loginLabel.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_loginLabel.layer setBorderWidth:1];
    [_loginBackgroundImageView addSubview:_loginLabel];
    [_loginLabel setUserInteractionEnabled:YES];
    
    
    UIButton *loginButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _loginBackgroundImageView.frame.size.width, _loginBackgroundImageView.frame.size.height)];
    [loginButton addTarget:self action:@selector(loginButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_loginBackgroundImageView addSubview:loginButton];
    
    //退出登录按钮
    _exitButton = [[UIButton alloc]initWithFrame:CGRectMake(_loginBackgroundImageView.frame.size.width-54, 25, 44, 30)];
    [_exitButton setTitle:NSLocalizedString(@"exitLoginButtonTitle", @"退出") forState:UIControlStateNormal];
    [_exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_exitButton addTarget:self action:@selector(exitLoginButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_loginBackgroundImageView addSubview:_exitButton];
    [_exitButton setHidden:YES];
    
    //加载用户信息
    [self loadUserBaseInfo];
}

/**
 *  创建功能引导视图
 */
-(void)createFunctionGuideView{
    _functionGuideView = [[UIView alloc]initWithFrame:CGRectMake(0, _loginBackgroundImageView.frame.origin.y + _loginBackgroundImageView.frame.size.height, _topView.frame.size.width, _topView.frame.size.height-_loginBackgroundImageView.frame.size.height)];
    [_topView addSubview:_functionGuideView];
    
    
    HeightOfFunctionViewSpace = 8;
    heightOfDeviceListTitleView = 20;
    heightOfFunctionView = (_functionGuideView.frame.size.height-(HeightOfFunctionViewSpace*3)-heightOfDeviceListTitleView)/3;
    //进入路由器引导按钮
    [self createRouterFunctionGuideView];
    //添加新设备功能引导按钮
    [self createAddNewDeviceFunctionGuideView];
    //场景设置功能引导按钮
    [self createSceneModelFunctionGuideView];
}

/**
 *  创建路由器功能模块引导按钮
 */
-(void)createRouterFunctionGuideView{
    _routerFunctionGruideView = [[UIView alloc]initWithFrame:CGRectMake(20, HeightOfFunctionViewSpace, SCREEN_CGSIZE_WIDTH-40, heightOfFunctionView)];
    [_routerFunctionGruideView setBackgroundColor:[UIColor colorWithRed:0.541 green:0.800 blue:0.208 alpha:1]];
    [_routerFunctionGruideView setAlpha:1];
    [_functionGuideView addSubview:_routerFunctionGruideView];
    
    CGFloat heightOfHeadImageView = _routerFunctionGruideView.frame.size.height/1.5;
    CGFloat yOfHeadImageView = (_routerFunctionGruideView.frame.size.height-heightOfHeadImageView)/2;
    UIImageView *headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(yOfHeadImageView, yOfHeadImageView, heightOfHeadImageView, heightOfHeadImageView)];
    [headImageView setImage:[UIImage imageNamed:@"路由器管理头像1"]];
    [_routerFunctionGruideView addSubview:headImageView];
    
    CGFloat heightOfPlusImageView = _routerFunctionGruideView.frame.size.height/3;
    CGFloat yOfPlusImageView = (_routerFunctionGruideView.frame.size.height-heightOfPlusImageView)/2;
    CGFloat xOfPlusImageView = _routerFunctionGruideView.frame.size.width - heightOfPlusImageView*2;
    UIImageView *plusImageView = [[UIImageView alloc]initWithFrame:CGRectMake(xOfPlusImageView, yOfPlusImageView, heightOfPlusImageView, heightOfPlusImageView)];
    [plusImageView setImage:[UIImage imageNamed:@"加号按钮"]];
    [_routerFunctionGruideView addSubview:plusImageView];
    
    CGFloat widthOfTotalView = _routerFunctionGruideView.frame.size.width-(headImageView.frame.size.width+headImageView.frame.origin.x)-(_routerFunctionGruideView.frame.size.width-plusImageView.frame.origin.x);
    CGFloat widthOfOneView = widthOfTotalView/3-3;
    //连接状态
    UIView *wanConnectStateView = [[UIView alloc]initWithFrame:CGRectMake((headImageView.frame.size.width+headImageView.frame.origin.x), 0, widthOfOneView, _routerFunctionGruideView.frame.size.height)];
    UILabel *wanConnectTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, wanConnectStateView.frame.size.width, wanConnectStateView.frame.size.height/4)];
    [wanConnectTitleLabel setText:@"互联网连接"];
    [wanConnectTitleLabel setTextColor:[UIColor whiteColor]];
    [wanConnectTitleLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [wanConnectTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [wanConnectStateView addSubview:wanConnectTitleLabel];
    _wanConnectStateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, wanConnectTitleLabel.frame.size.height+wanConnectTitleLabel.frame.origin.y-3, wanConnectTitleLabel.frame.size.width, wanConnectTitleLabel.frame.size.height)];
    [_wanConnectStateLabel setTextAlignment:NSTextAlignmentCenter];
    [_wanConnectStateLabel setTextColor:[UIColor whiteColor]];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [_wanConnectStateLabel setText:@"未连接"];
    [_wanConnectStateLabel setTextColor:[UIColor blackColor]];
    if ([ud objectForKey:NET_CONNECT_STATE]) {
        [_wanConnectStateLabel setText:[ud objectForKey:NET_CONNECT_STATE]];
    }
    [_wanConnectStateLabel setFont:[UIFont systemFontOfSize:8]];
    [wanConnectStateView addSubview:_wanConnectStateLabel];
    [_routerFunctionGruideView addSubview:wanConnectStateView];
    UIImageView *icon1ImageView = [[UIImageView alloc]initWithFrame:CGRectMake((wanConnectStateView.frame.size.width-wanConnectStateView.frame.size.height/3)/2, _wanConnectStateLabel.frame.size.height+_wanConnectStateLabel.frame.origin.y, wanConnectStateView.frame.size.height/3, wanConnectStateView.frame.size.height/3)];
    [icon1ImageView setImage:[UIImage imageNamed:@"连接状态图标"]];
    [wanConnectStateView addSubview:icon1ImageView];
    
    UIView *splitline1 = [[UIView alloc]initWithFrame:CGRectMake(wanConnectStateView.frame.size.width+wanConnectStateView.frame.origin.x, 5, 1, _routerFunctionGruideView.frame.size.height-10)];
    UIImageView *splitline1ImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 1, splitline1.frame.size.height)];
    [splitline1ImageView setImage:[UIImage imageNamed:@"白色线"]];
    [splitline1 addSubview:splitline1ImageView];
    [_routerFunctionGruideView addSubview:splitline1];
    //当前速度
    UIView *currentSpeedView = [[UIView alloc]initWithFrame:CGRectMake((splitline1.frame.size.width+splitline1.frame.origin.x), 0, widthOfOneView, _routerFunctionGruideView.frame.size.height)];
    UILabel *currentSpeedTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, currentSpeedView.frame.size.width, currentSpeedView.frame.size.height/4)];
    [currentSpeedTitleLabel setText:@"当前速度"];
    [currentSpeedTitleLabel setTextColor:[UIColor whiteColor]];
    [currentSpeedTitleLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [currentSpeedTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [currentSpeedView addSubview:currentSpeedTitleLabel];
    _speedLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, wanConnectTitleLabel.frame.size.height+wanConnectTitleLabel.frame.origin.y-3, wanConnectTitleLabel.frame.size.width, wanConnectTitleLabel.frame.size.height)];
    [_speedLabel setText:@"--"];
    [_speedLabel setTextAlignment:NSTextAlignmentCenter];
    [_speedLabel setTextColor:[UIColor blackColor]];
    [_speedLabel setFont:[UIFont systemFontOfSize:8]];
    [currentSpeedView addSubview:_speedLabel];
    [_routerFunctionGruideView addSubview:wanConnectStateView];
    UIImageView *icon2ImageView = [[UIImageView alloc]initWithFrame:CGRectMake((wanConnectStateView.frame.size.width-wanConnectStateView.frame.size.height/3)/2, _wanConnectStateLabel.frame.size.height+_wanConnectStateLabel.frame.origin.y, wanConnectStateView.frame.size.height/3, wanConnectStateView.frame.size.height/3)];
    [icon2ImageView setImage:[UIImage imageNamed:@"当前速度"]];
    [currentSpeedView addSubview:icon2ImageView];
    
    [_routerFunctionGruideView addSubview:currentSpeedView];
    UIView *splitline2 = [[UIView alloc]initWithFrame:CGRectMake(currentSpeedView.frame.size.width+currentSpeedView.frame.origin.x, 5, 1, _routerFunctionGruideView.frame.size.height-10)];

    UIImageView *splitline2ImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 1, splitline1.frame.size.height)];
    [splitline2ImageView setImage:[UIImage imageNamed:@"白色线"]];
    [splitline2 addSubview:splitline2ImageView];
    [_routerFunctionGruideView addSubview:splitline2];
    //引导文字
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake((splitline2.frame.size.width+splitline2.frame.origin.x), 0, widthOfOneView, _routerFunctionGruideView.frame.size.height)];
    [_routerFunctionGruideView addSubview:titleView];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, titleView.frame.size.width, titleView.frame.size.height)];
    [titleLabel setText:@"路由器管理"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setNumberOfLines:2];
    [titleView addSubview:titleLabel];
    
    UIButton *intoRouterManagerButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _routerFunctionGruideView.frame.size.width, _routerFunctionGruideView.frame.size.height)];
    [intoRouterManagerButton addTarget:self action:@selector(intoRouterManagerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_routerFunctionGruideView addSubview:intoRouterManagerButton];
}


/**
 *  创建添加新设备模块引导按钮
 */
-(void)createAddNewDeviceFunctionGuideView{
    _addNewDeviceFunctionGuideView = [[UIView alloc]initWithFrame:CGRectMake(20, _routerFunctionGruideView.frame.origin.y+_routerFunctionGruideView.frame.size.height+HeightOfFunctionViewSpace, SCREEN_CGSIZE_WIDTH-40, heightOfFunctionView)];
    [_addNewDeviceFunctionGuideView setBackgroundColor:[UIColor colorWithRed:0.541 green:0.800 blue:0.208 alpha:1]];
    [_addNewDeviceFunctionGuideView setAlpha:1];
    [_functionGuideView addSubview:_addNewDeviceFunctionGuideView];
    
    CGFloat heightOfHeadImageView = _addNewDeviceFunctionGuideView.frame.size.height/1.5;
    CGFloat yOfHeadImageView = (_addNewDeviceFunctionGuideView.frame.size.height-heightOfHeadImageView)/2;
    UIImageView *headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(yOfHeadImageView, yOfHeadImageView, heightOfHeadImageView, heightOfHeadImageView)];
    [headImageView setImage:[UIImage imageNamed:@"添加新设备头像"]];
    [_addNewDeviceFunctionGuideView addSubview:headImageView];
    
    
    CGFloat heightOfPlusImageView = _addNewDeviceFunctionGuideView.frame.size.height/3;
    CGFloat yOfPlusImageView = (_addNewDeviceFunctionGuideView.frame.size.height-heightOfPlusImageView)/2;
    CGFloat xOfPlusImageView = _addNewDeviceFunctionGuideView.frame.size.width - heightOfPlusImageView*2;
    UIImageView *plusImageView = [[UIImageView alloc]initWithFrame:CGRectMake(xOfPlusImageView, yOfPlusImageView, heightOfPlusImageView, heightOfPlusImageView)];
    [plusImageView setImage:[UIImage imageNamed:@"加号按钮"]];
    [_addNewDeviceFunctionGuideView addSubview:plusImageView];
    
    CGFloat widthOfTotalView = _addNewDeviceFunctionGuideView.frame.size.width-(headImageView.frame.size.width+headImageView.frame.origin.x)-(_addNewDeviceFunctionGuideView.frame.size.width-plusImageView.frame.origin.x);
    UILabel *addDeviceLabel = [[UILabel alloc]initWithFrame:CGRectMake(headImageView.frame.size.width + headImageView.frame.origin.x, (_addNewDeviceFunctionGuideView.frame.size.height-30)/2, widthOfTotalView, 30)];
    [addDeviceLabel setTextColor:[UIColor whiteColor]];
    [addDeviceLabel setText:@"点击添加新设备"];
    [addDeviceLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [_addNewDeviceFunctionGuideView addSubview:addDeviceLabel];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _addNewDeviceFunctionGuideView.frame.size.width, _addNewDeviceFunctionGuideView.frame.size.height)];
    [button addTarget:self action:@selector(intoConfigPlugButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_addNewDeviceFunctionGuideView addSubview:button];
}

/**
 *  创建场景功能模块引导按钮
 */
-(void)createSceneModelFunctionGuideView{
    _sceneModelFunctionGuideView = [[UIView alloc]initWithFrame:CGRectMake(20, _addNewDeviceFunctionGuideView.frame.origin.y+_addNewDeviceFunctionGuideView.frame.size.height+HeightOfFunctionViewSpace, SCREEN_CGSIZE_WIDTH-40, heightOfFunctionView)];
    [_sceneModelFunctionGuideView setBackgroundColor:[UIColor colorWithRed:0.541 green:0.800 blue:0.208 alpha:1]];
    [_sceneModelFunctionGuideView setAlpha:1];
    [_functionGuideView addSubview:_sceneModelFunctionGuideView];
    
    CGFloat heightOfHeadImageView = _routerFunctionGruideView.frame.size.height/1.5;
    CGFloat yOfHeadImageView = (_routerFunctionGruideView.frame.size.height-heightOfHeadImageView)/2;
    UIImageView *headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(yOfHeadImageView, yOfHeadImageView, heightOfHeadImageView, heightOfHeadImageView)];
    [headImageView setImage:[UIImage imageNamed:@"购买智能设备"]];
    [_sceneModelFunctionGuideView addSubview:headImageView];
    
    
    CGFloat heightOfPlusImageView = _sceneModelFunctionGuideView.frame.size.height/3;
    CGFloat yOfPlusImageView = (_sceneModelFunctionGuideView.frame.size.height-heightOfPlusImageView)/2;
    CGFloat xOfPlusImageView = _sceneModelFunctionGuideView.frame.size.width - heightOfPlusImageView*2;
    UIImageView *plusImageView = [[UIImageView alloc]initWithFrame:CGRectMake(xOfPlusImageView, yOfPlusImageView, heightOfPlusImageView, heightOfPlusImageView)];
    [plusImageView setImage:[UIImage imageNamed:@"加号按钮"]];
    [_sceneModelFunctionGuideView addSubview:plusImageView];
    
    CGFloat widthOfTotalView = _sceneModelFunctionGuideView.frame.size.width-(headImageView.frame.size.width+headImageView.frame.origin.x)-(_sceneModelFunctionGuideView.frame.size.width-plusImageView.frame.origin.x);
    UILabel *addDeviceLabel = [[UILabel alloc]initWithFrame:CGRectMake(headImageView.frame.size.width + headImageView.frame.origin.x, (_sceneModelFunctionGuideView.frame.size.height-30)/2, widthOfTotalView, 30)];
    [addDeviceLabel setTextColor:[UIColor whiteColor]];
    [addDeviceLabel setText:@"购买更多智能设备"];
    [addDeviceLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [_sceneModelFunctionGuideView addSubview:addDeviceLabel];
    
    //推荐购买
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _sceneModelFunctionGuideView.frame.size.width, _sceneModelFunctionGuideView.frame.size.height)];
    [button addTarget:self action:@selector(intoShopButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_sceneModelFunctionGuideView addSubview:button];
}

/**
 *  创建网速显示标签视图
 *
 *  @param superView 父视图
 */
-(void)createNetworkSpeed:(UIView *)superView{
    //当前网速
    NSString *networkSpeed = @"0.0";
    UIFont *speedLableFont = [UIFont fontWithName:@"HiraKakuProN-W3" size:50];
    CGSize networkSpeedSize = [networkSpeed sizeWithAttributes:@{NSFontAttributeName:speedLableFont}];
    CGFloat networkSpeedWidth = networkSpeedSize.width;
    _networkSpeedLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 25, networkSpeedWidth, 80)];
    [_networkSpeedLabel setFont:speedLableFont];
    [_networkSpeedLabel setText:networkSpeed];
    [_networkSpeedLabel setTextColor:[UIColor whiteColor]];
    [superView addSubview:_networkSpeedLabel];
    
    
    _kbsLabel = [[UILabel alloc]initWithFrame:CGRectMake(networkSpeedWidth+10, _networkSpeedLabel.frame.origin.y+_networkSpeedLabel.frame.size.height-30, 40, 10)];
    [_kbsLabel setTextColor:[UIColor lightGrayColor]];
    [_kbsLabel setFont:[UIFont systemFontOfSize:8]];
    [_kbsLabel setText:@"KB/S"];
    [superView addSubview:_kbsLabel];
}


- (IBAction)actionToggleLeftDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (IBAction)actionToggleRightDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleRightDrawer:self animated:YES];
}


#pragma mark -UICollectionView

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"checkstate"] boolValue]) {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"开发中,敬请期待！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
//        return;
//    }
    CHECK_STATE;
    if (!_fullscreen) {
        _fullscreen = YES;
        
        [self setLargeCell];
        [_topView setHidden:YES];
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.collectionView setCollectionViewLayout:_largeLayout animated:YES];
            self.collectionView.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
        }];
        
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        if (!_cellArray) {
            _cellArray = [[NSMutableArray alloc]initWithCapacity:[_deviceDataArray count]];
        }
        
        HADeviceCollectionViewCell *collectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
        [collectionCell sizeToFit];
        collectionCell.delegate = self;
        [collectionCell setData:[_deviceDataArray objectAtIndex:indexPath.row]];
        [collectionCell setCurrentIndex:indexPath];
        if ([_cellArray count]>indexPath.row) {
            if ([_cellArray objectAtIndex:indexPath.row]) {
                [_cellArray replaceObjectAtIndex:indexPath.row withObject:collectionCell];
            }else{
                [_cellArray insertObject:collectionCell atIndex:indexPath.row];
            }
        }else{
            [_cellArray addObject:collectionCell];
        }
        
        return collectionCell;
    }
    @catch (NSException *exception) {
        DLog(@"collectionView滚动时异常%@",exception);
    }
    @finally {
        
    }
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger rowNumber = 0;
    if (_deviceDataArray) {
        if ([_deviceDataArray isKindOfClass:[NSArray class]]) {
            rowNumber = [_deviceDataArray count];
        }
    }
    return rowNumber;
}


/**
 *  首页智能设备缩略图放大缩小通知的处理函数
 *
 *  @param noti 设备视图放大缩小的通知
 */
-(void)changeCollectionViewLayout:(NSNotification *)noti{
    if (_fullscreen) {
        [self setSmallCell];
        _fullscreen = NO;
        
        [_topView setHidden:NO];
        
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
        
        [self.collectionView snapshotViewAfterScreenUpdates:NO];
        
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.collectionView setCollectionViewLayout:_smallLayout animated:YES];
            self.collectionView.backgroundColor = [UIColor clearColor];
            [_topView setHidden:NO];
        } completion:^(BOOL finished) {
            [_topView setHidden:NO];
        }];
        //[self.collectionView setCollectionViewLayout:_smallLayout];
    }
    else {
        _fullscreen = YES;
        
        [_topView setHidden:YES];
        
        [self setLargeCell];
        
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            // Change flow layout
            [self.collectionView setCollectionViewLayout:_largeLayout animated:YES];
            self.collectionView.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
        }];
        //[self.collectionView setCollectionViewLayout:_largeLayout];
    }
}



//设置cell为全屏模式
-(void)setLargeCell{
    //modify yxm 2015年10月09日22:37:43
    DLog(@"_cellArray1 count = %d",(int)[_cellArray count]);
    for (HADeviceCollectionViewCell *oneDeviceCell in _cellArray) {
        [oneDeviceCell setLargeCellViewLayout];
    }
    
//    self.collectionView.collectionViewLayout = _largeLayout;

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_COLLECTIONVIEW_SIZE_CHANGE object:nil userInfo:[NSDictionary dictionaryWithObject:@"large" forKey:@"size"]];
}
//设置cell为缩略模式
-(void)setSmallCell{
    //modify yxm 2015年10月09日22:38:50
//    DLog(@"_cellArray2 count = %d",[_cellArray count]);
    for (HADeviceCollectionViewCell *oneDeviceCell in _cellArray) {
        [oneDeviceCell setSmallCellViewLayout];
    }
//    self.collectionView.collectionViewLayout = _smallLayout;

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_COLLECTIONVIEW_SIZE_CHANGE object:nil userInfo:[NSDictionary dictionaryWithObject:@"small" forKey:@"size"]];
}


#pragma mark -单元格状态改变的回调实现方法
/**
 *  开关按钮状态改变时的处理方法
 *
 *  @param oneData 状态改变的数据
 *  @param index   对应的索引
 */
-(void)cellStateChange:(YXMDeviceInfoModel *)oneData andIndex:(NSIndexPath *)index{
    [_deviceDataArray replaceObjectAtIndex:index.row withObject:oneData];
}

/**
 *  根据索引去删除设备单元视图
 *
 *  @param currentCellIndexPath 当前视图的索引
 */
-(void)deleteDeviceCell:(NSIndexPath *)currentCellIndexPath{
    return;
    NSArray *deleteItems = @[currentCellIndexPath];
    NSInteger iDataOfIndex = currentCellIndexPath.row;
    if (iDataOfIndex<[_deviceDataArray count]) {
        YXMDeviceInfoModel *deleteData = [_deviceDataArray objectAtIndex:iDataOfIndex];
        //删除数据库的数据
        YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
        [db openDatabase];
        BOOL deleteResult = [db deletePlugDataWithPlugMac:deleteData.device_id];
        if (deleteResult) {
            [_deviceDataArray removeObjectAtIndex:iDataOfIndex];
            if (iDataOfIndex<[_cellArray count]) {
                [_cellArray removeObjectAtIndex:iDataOfIndex];
            }
            
            [self.collectionView performBatchUpdates:^{
                [self.collectionView deleteItemsAtIndexPaths:deleteItems];
            } completion:^(BOOL finished){
                [self setLargeCell];
                [self.collectionView reloadData];
            }];
            [[[iToast makeText:NSLocalizedString(@"delete_device_of_success", @"")]
              setGravity:iToastGravityCenter] show:iToastTypeError];
        }else{
            [[[iToast makeText:NSLocalizedString(@"delete_device_of_error", @"")]
              setGravity:iToastGravityCenter] show:iToastTypeError];
        }
        
    }
    

}

/**
 *  进入路由器管理的界面
 *
 *  @param sender 路由器管理入口按钮
 */
-(void)intoRouterManagerButtonClick:(UIButton *)sender{
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:[[AppDelegate globalDelegate] routerManagerViewController]];
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [APService startLogPageView:@"智能设备管理"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [APService stopLogPageView:@"智能设备管理"];
}


/**
 *  更新通知传递过来的数据到网速显示标签视图
 *
 *  @param noti 网速更新通知
 */
-(void)updateNetSpeed:(NSNotification *)noti{
    NSDictionary *userinfo = [noti userInfo];
    CGFloat netSpeedFloat = [[userinfo objectForKey:@"totalNetSpeed"] floatValue];
    NSString *speedLabelString = [[NSString alloc]initWithFormat:@"%0.0lfKB/S",netSpeedFloat];
    if (netSpeedFloat>1023) {
        speedLabelString = [[NSString alloc]initWithFormat:@"%0.0lfMB/S",netSpeedFloat/1024];
    }
    [_speedLabel setText:speedLabelString];
}


/**
 *  定时器每隔三秒调用此函数去从路由器获取当前总下行流量
 */
-(void)updateSelectSpeed{
    YXMTrafficStatistics *statistics = [[YXMTrafficStatistics alloc]init];
    [statistics getNetworkSpeed];
}


/**
 *  更新用户数据到视图上
 *
 *  @param noti 登录成功后的通知
 */
-(void)updateUserInfo:(NSNotification *)noti{
    NSDictionary *userInfo = [noti userInfo];
    NSString *uid = [userInfo objectForKey:@"uid"];
    NSString *username = [userInfo objectForKey:@"username"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:uid forKey:@"uid"];
    [ud setObject:username forKey:@"username"];
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/uc_server/avatar.php?uid=%@&type=real&size=middle",URL_DOMAIN,uid]] placeholderImage:[UIImage imageNamed:@"home_headMan"]];
    [_loginLabel setText:username];
    [_exitButton setHidden:NO];
}

/**
 *  退出登录按钮的处理事件
 *
 *  @param sender 退出按钮
 */
-(void)exitLoginButtonClick:(UIButton *)sender{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"uid"];
    [ud removeObjectForKey:@"username"];
    [self setDefaultHeadInfo];
}

/**
 *  设置头像视图的数据为默认数据
 */
-(void)setDefaultHeadInfo{
    [_loginLabel setText:NSLocalizedString(@"loginofguide", @"登录后更多精彩！")];
    [_headImageView setImage:[UIImage imageNamed:@"招呼--按钮"]];
    [_exitButton setHidden:YES];
}

/**
 *  读取用户的基本信息（用户头像和用户名称）
 */
-(void)loadUserBaseInfo{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *uid = [ud objectForKey:@"uid"];
    NSString *username = [ud objectForKey:@"username"];
    if (uid) {
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/uc_server/avatar.php?uid=%@&type=real&size=middle",URL_DOMAIN,uid]] placeholderImage:[UIImage imageNamed:@"home_headMan"]];
        [_loginLabel setText:username];
        [_exitButton setHidden:NO];
    }
}

/**
 *  用户登录按钮点击的处理方法，如果已经登录了，则不做任何处理，否则进入用户登录页面。
 *
 *  @param sender 登录按钮
 */
-(void)loginButtonClick:(UIButton *)sender{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud objectForKey:@"uid"]) {
        return;
    }
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:[[AppDelegate globalDelegate] loginViewController]];
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

/**
 *  进入到设备配置界面
 *
 *  @param 添加新设备按钮
 */
-(void)intoConfigPlugButtonClick:(UIButton *)sender{
    CHECK_STATE;
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:[[AppDelegate globalDelegate] configNavCtrl]];
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

/**
 *  网络相关
 */
-(void)launchNetComponent{
    _net = [[YXMPlugNetCtrlCenter alloc]init];
    [_net start];
}

/**
 *  当收到新的广播之后通知列表处理,当出现
 */
-(void)updateDeviceList:(NSNotification *)noti{
    return;
    YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
    [db openDatabase];
    @try {
        NSDictionary *deviceDataDict = [noti userInfo];
        if (deviceDataDict) {
            if ([deviceDataDict isKindOfClass:[NSDictionary class]]) {
                NSString *device_mac = [deviceDataDict objectForKey:@"Mac"];
                NSString *device_ip = [deviceDataDict objectForKey:@"device_local_ip"];

                //查询数据库中是否存在这个计算机设备，
                BOOL findResult = [db findDataWithDeviceMac:device_mac];
                if (findResult) {
                    
                    //如果存在，则检查ip地址是否一致，如果设备已经存在但是ip地址变更了，则需要更改数据库中的ip地址；
                    BOOL isChangeIP = [db findDataWithDeviceIPAndMac:device_ip andMac:device_mac];
                    if (!isChangeIP) {
                        //更新数据库中设备的ip地址，
                        [db updateDeviceLocalIP:device_ip andMacAddress:device_mac];
                        //更新内存中对象的设备的ip
                        YXMDeviceInfoModel *tempData = nil;
                        NSInteger updateIndex = 0;
                        for (int j=0; j<[_deviceDataArray count]; j++) {
                            tempData = [_deviceDataArray objectAtIndex:j];
                            if ([tempData.device_id isEqualToString:device_mac]) {
                                [tempData setDevice_local_ip:device_ip];
                                updateIndex = j;
                                return;
                            }
                        }
                        if (tempData) {
                            [_deviceDataArray replaceObjectAtIndex:updateIndex withObject:tempData];
                        }
                    }
                }else{
                    //如果不存在的话，那么组织数据存入数据库；
                    YXMDeviceInfoModel *data = [[YXMDeviceInfoModel alloc]init];
                    //设备编号
                    [data setDevice_id:device_mac];
                    //设备的头像
                    [data setDevice_head:@"virtual_device"];
                    //Type 设备类型 0插座 int
                    NSString *device_type_s = [deviceDataDict objectForKey:@"Type"];
                    NSInteger device_type_i = [device_type_s integerValue];
                    [data setDevice_type:device_type_i];
                    //设备的名称
                    [data setDevice_name:[NSString stringWithFormat:@"智能插座"]];
                    //设备的开关状态
                    NSString *device_state_s = [deviceDataDict objectForKey:@"Open"];
                    NSInteger device_state_i = [device_state_s integerValue];
                    [data setDevice_state:device_state_i];
                    //设备的网络状态
                    [data setDevice_net_state:EnumDeviceNetStateLocalOnline];
                    //设备的索引,建议使用数据库中的索引
                    [data setDevice_selectIndex:0];
                    //设备的ip地址
                    [data setDevice_local_ip:device_ip];
                    //设备的mac地址
                    [data setDevice_mac_address:device_mac];
                    //曾经控制过设备的人数
                    NSString *device_TotalNumber_s = [deviceDataDict objectForKey:@"TotalNumber"];
                    NSInteger device_TotalNumber_i = [device_TotalNumber_s integerValue];
                    [data setDevice_type:device_TotalNumber_i];
                    //当前有权限控制设备的人数
                    NSString *device_Authority_s = [deviceDataDict objectForKey:@"Authority"];
                    NSInteger device_Authority_i = [device_Authority_s integerValue];
                    [data setDevice_Authority:device_Authority_i];
                    /**
                     *  判断内存的设备集合中是否存在广播接收到的设备信息，如果没有则加入内存集合中；
                     */
                    BOOL isExist = NO;
                    for (YXMDeviceInfoModel *tempData in _deviceDataArray) {
                        if ([tempData.device_id isEqualToString:device_mac]) {
                            isExist = YES;
                        }
                    }
                    if (!isExist) {
                        [_deviceDataArray insertObject:data atIndex:0];
                        [db savePlugDeviceWithModelData:data];
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        DTLog(@"%@",exception);
    }
    @finally {
        
    }
    [self readLastDeviceInfo];
}


/**
 *  刷新collectionView，在最小化设备列表的时候调用，以解决最小化之后出现界面异常的问题。
 */
-(void)refreshCollection{
    [self setSmallCell];
    [self.collectionView reloadData];
}



/**
 *  更改设备名称的通知处理方法，
 *
 *  @param noti 通知
 */
-(void)updateDeviceName:(NSNotification *)noti{
    NSDictionary *userinfo = [noti userInfo];
    if (userinfo) {
        if ([userinfo isKindOfClass:[NSDictionary class]]) {
            [self readLastDeviceInfo];
        }
    }
}

/**
 *  进入推荐购买的页面
 *
 *  @param sender 推荐购买按钮
 */
-(void)intoShopButtonClick:(UIButton *)sender{
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:[[AppDelegate globalDelegate] shopNavCtrl]];
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

@end
