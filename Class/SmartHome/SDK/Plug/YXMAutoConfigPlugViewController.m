//
//  YXMAutoConfigPlugViewController.m
//  SmartHome
//
//  Created by iroboteer on 15/5/4.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMAutoConfigPlugViewController.h"
#import "Config.h"
#import "YXMDatabaseOperation.h"
#import <STAlertView/STAlertView.h>
#import "AppDelegate.h"
#import "JVFloatingDrawerViewController.h"

#define INT_PROGRESS_BAR_TOTAL 61

@interface YXMAutoConfigPlugViewController ()

@end

@implementation YXMAutoConfigPlugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"智能自动配置";
    //为了适应返回了之后再次进入的时候初始化页面，页面初始化的代码在进入页面的地方进行调用 initConfigView 方法来完成
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 *  初始化自动配置视图
 */
- (void)initConfigView{
    self.navigationController.navigationBar.translucent = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    //初始化smartconfig组件
    smart = [[smartConfig alloc]init];
    tdo = [[TDO alloc] init];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *ssid = [ud objectForKey:KEY_ROUTER_SSID];
    NSString *pwd = [ud objectForKey:KEY_OF_WIFI_PASSWORD];
    DTLog(@"ssid = %@,pwd = %@",ssid,pwd);
    NSArray *SmartConfigArray = [[NSArray alloc] initWithArray:[tdo SmartConfigSetSSID:ssid andSetPassWord:pwd]];
    DTLog(@"%@",SmartConfigArray);
    //根视图
    configBaseView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:configBaseView];
    CGFloat topOffsetHeight = 44.0f;
    //主提示
    mainPromptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, topOffsetHeight, self.view.frame.size.width, 44)];
    [mainPromptLabel setBackgroundColor:[UIColor clearColor]];
    [mainPromptLabel setText:@"自动配置插座中"];
    [mainPromptLabel setTextColor:[UIColor grayColor]];
    [mainPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [mainPromptLabel setFont:[UIFont systemFontOfSize:24 weight:20]];
    [configBaseView addSubview:mainPromptLabel];
    //配置的进度条
    //进度条样式可以自定义。。这里我们引用了一个第三方类。只作为显示。对配置无影响
    newTheme = [[MDRadialProgressTheme alloc] init];
    newTheme.completedColor = [UIColor colorWithRed:19/255.0 green:193/255.0 blue:255/255.0 alpha:1];
    newTheme.incompletedColor = [UIColor whiteColor];
    newTheme.centerColor = [UIColor clearColor];
    newTheme.sliceDividerHidden = YES;
    newTheme.labelColor = [UIColor colorWithRed:111/255.0 green:124/255.0 blue:111/255.0 alpha:1];
    newTheme.labelShadowColor = [UIColor whiteColor];
    newTheme.font = [UIFont systemFontOfSize:16.0f];
    CGRect progressRect = CGRectMake((SCREEN_CGSIZE_WIDTH - SCREEN_CGSIZE_WIDTH/2.0f)/2, mainPromptLabel.frame.origin.y + mainPromptLabel.frame.size.height +30, SCREEN_CGSIZE_WIDTH/2.0f, SCREEN_CGSIZE_WIDTH/2.0f);
    [self insertProgressView:configBaseView andFrame:progressRect];
    //定时刷新进度条
    time = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(changeView) userInfo:nil repeats:YES];
    //取消按钮
    CGFloat fCancelButtonX = SCREEN_CGSIZE_WIDTH/4.0f;
    CGFloat fButtonWidth = SCREEN_CGSIZE_WIDTH/2.0f;
    UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(fCancelButtonX, progressRect.origin.y + progressRect.size.height + 44, fButtonWidth, 40)];
    [cancelButton addTarget:self action:@selector(stopConfigButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton.layer setBorderColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000].CGColor];
    [cancelButton.layer setBorderWidth:0.6f];
    [cancelButton setTitleColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000] forState:UIControlStateNormal];
    [cancelButton setTitle:[Config DPLocalizedString:@"cancel"] forState:UIControlStateNormal];
    [configBaseView addSubview:cancelButton];
    
    
    //启动配置方法
    [NSThread detachNewThreadSelector:@selector(startConfig) toTarget:self withObject:nil];
}

/**
 *  插入进度条
 *
 *  @param superView 进度条视图的父视图
 *  @param rect      进度条的rect
 */
-(void)insertProgressView:(UIView *)superView andFrame:(CGRect)rect{
    progressView = [[MDRadialProgressView alloc] initWithFrame:rect andTheme:newTheme];
    progressView.progressTotal = INT_PROGRESS_BAR_TOTAL;
    progressView.progressCounter = 0;
    value = 0;
    [superView addSubview:progressView];
}

/**
 *  通过一个定时器来循环调用此方法来达到进度条前进的效果
 */
- (void)changeView{
    value ++;
    if (value > INT_PROGRESS_BAR_TOTAL) {

        //停止计时器
        [time invalidate];
        value = 0;
        [smart StopSmartConfig];
        [progressView removeFromSuperview];
        //配置完毕，发现设备
        [self configSuccessAndFindLocalDevice];
    }else{
        progressView.progressCounter = value;
    }
}

/**
 * 当配置插座成功后启动发现设备的程序
 */
-(void)configSuccessAndFindLocalDevice{

    //读取配置成功后设备的数量
    YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
    [db openDatabase];
    _afterDeviceCount = [db readDeviceCount];
    DTLog(@"after = %d,before = %d",(int)_afterDeviceCount,(int)_beforeDeviceCount);
    int newDeviceCount = (int)(_beforeDeviceCount - _afterDeviceCount);
    newDeviceCount = 1;
    self.findDeviceResultAlertView = [[STAlertView alloc]initWithTitle:[NSString stringWithFormat:@"配置设备完毕"] message:[NSString stringWithFormat:@"本地已存在%d个设备,新加入%d个设备",(int)_afterDeviceCount,newDeviceCount] cancelButtonTitle:nil otherButtonTitle:[Config DPLocalizedString:@"sure"] cancelButtonBlock:^{
        DTLog(@"取消登录");
        [self closeCurrentPage:nil];
    } otherButtonBlock:^(NSString *result) {
        DTLog(@"%@",result);
        
    }];
    [self.findDeviceResultAlertView show];
}

/**
 *  关闭当前自动配置页面
 *
 *  @param sender 关闭按钮
 */
- (void)closeCurrentPage:(id)sender {
    [time invalidate];
    [smart StopSmartConfig];
    progressView.progressCounter = 0;
    [configBaseView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closecurrentpage" object:nil]; 
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


/**
 *  开始配置插座网络的处理方法
 */
- (void)startConfig{
    //查询当前配置成功的设备有多少个
    YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
    [db openDatabase];
    _beforeDeviceCount = [db readDeviceCount];
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"isSend"];
    dispatch_async(dispatch_get_main_queue(), ^(){
        
    });
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *ssid = [ud objectForKey:KEY_ROUTER_SSID];
    NSString *pwd = [ud objectForKey:KEY_OF_WIFI_PASSWORD];
    [smart StartSmartConfigSetSSID:ssid andSetPassWord:pwd];
    
    //移除已经存在的进度条，重新插入进度条
    [progressView removeFromSuperview];
    CGRect progressRect = CGRectMake((SCREEN_CGSIZE_WIDTH - SCREEN_CGSIZE_WIDTH/2.0f)/2, mainPromptLabel.frame.origin.y + mainPromptLabel.frame.size.height +30, SCREEN_CGSIZE_WIDTH/2.0f, SCREEN_CGSIZE_WIDTH/2.0f);
    [self insertProgressView:configBaseView andFrame:progressRect];
    
    //定时刷新进度条
    [time invalidate];
    time = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(changeView) userInfo:nil repeats:YES];
}



/**
 *  停止配置
 *
 *  @param sender
 */
-(void)stopConfigButtonClick:(UIButton *)sender{
    [time invalidate];
    [smart StopSmartConfig];
    progressView.progressCounter = 0;
    [progressView removeFromSuperview];
    [configBaseView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [time invalidate];
    [smart StopSmartConfig];
    progressView.progressCounter = 0;
    [progressView removeFromSuperview];
    [configBaseView removeFromSuperview];
}

@end
