//
//  YXMOptimizeNetViewController.m
//  SmartHome
//
//  Created by iroboteer on 15/4/4.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMOptimizeNetViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "Config.h"
#import "YXMNetChannelDataObjet.h"
#import "IPHelpler.h"
#import "DejalActivityView.h"
#import <iToast/iToast.h>


@interface YXMOptimizeNetViewController ()
{
    
}
@end

@implementation YXMOptimizeNetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"网络优化";
    _channelDataArr = [[NSMutableArray alloc]init];
    _wifiBaseInfoDict = [[NSMutableDictionary alloc]init];
    [self baseInfo];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGFloat topViewHeightScale = 0.3;
    CGFloat whiteSpaceWidth = 10.0f;
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(whiteSpaceWidth, 84, SCREEN_CGSIZE_WIDTH-(whiteSpaceWidth*2), (SCREEN_CGSIZE_HEIGHT-84)*topViewHeightScale)];
    [topView setBackgroundColor:[UIColor colorWithRed:0.529 green:0.776 blue:0.333 alpha:1.000]];
    topView.layer.cornerRadius = 8;
    topView.layer.masksToBounds = YES;
    [self.view addSubview:topView];
    
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, topView.frame.size.width/2.0f,topView.frame.size.height-10)];
    
    [topView addSubview:leftView];
    
    
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(topView.frame.size.width/2.0f, leftView.frame.origin.y, topView.frame.size.width/2.0f,leftView.frame.size.height)];
    [topView addSubview:rightView];
    
    
    //网络优化按钮
    CGFloat optimizeButtonWidth = leftView.frame.size.width*0.8f;
    CGFloat xoptimize = leftView.frame.size.width*0.2f;
    CGFloat yoptimize = (leftView.frame.size.height-optimizeButtonWidth)/2.0f;
    rippleButton1 = [[UIButton alloc]initWithFrame:CGRectMake(xoptimize, yoptimize, optimizeButtonWidth, optimizeButtonWidth)];
    [rippleButton1 addTarget:self action:@selector(optimizeNetButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [rippleButton1 setBackgroundImage:[UIImage imageNamed:@"优化开关1"] forState:UIControlStateNormal];
    [leftView addSubview:rippleButton1];
    
    UILabel *promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, rightView.frame.size.height/2.0f-20, rightView.frame.size.width, 20)];
    [promptLabel setText:@"点击按钮自动优化信道"];
    [promptLabel setFont:[UIFont systemFontOfSize:22]];
    [promptLabel setAdjustsFontSizeToFitWidth:YES];
    [promptLabel setTextAlignment:NSTextAlignmentCenter];
    [promptLabel setTextColor:[UIColor whiteColor]];
    [rightView addSubview:promptLabel];
    UILabel *subPromptLabel = [[UILabel alloc]initWithFrame:CGRectMake(promptLabel.frame.origin.x, promptLabel.frame.origin.y + promptLabel.frame.size.height, promptLabel.frame.size.width, 20)];
    [subPromptLabel setText:@"让您的网络畅通无阻"];
    [subPromptLabel setTextAlignment:NSTextAlignmentCenter];
    [subPromptLabel setTextColor:[UIColor whiteColor]];
    [subPromptLabel setFont:[UIFont systemFontOfSize:12]];
    [subPromptLabel setAdjustsFontSizeToFitWidth:YES];
    [rightView addSubview:subPromptLabel];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(topView.frame.origin.x,topView.frame.origin.y+topView.frame.size.height -10, topView.frame.size.width, (SCREEN_CGSIZE_HEIGHT-64)*(1-topViewHeightScale))];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:self.tableView];
    
    [self reloadTableData:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self optimizeNetButtonClick:nil];
}

-(void)baseInfo{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *routerDomain = [IPHelpler getGatewayIPAddress];
    NSString *url_wifi_base_info = [ud objectForKey:URL_GET_WIFI_BASE_SETUP_INFO];
    [manager GET:[NSString stringWithFormat:@"%@%@",routerDomain,url_wifi_base_info] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *sWifiBaseInfoReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        sWifiBaseInfoReturnCode = [sWifiBaseInfoReturnCode stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSArray *wifiBaseInfoArray = [sWifiBaseInfoReturnCode componentsSeparatedByString:@"\r"];
        DLog(@"wifiBaseInfoArray = %@",wifiBaseInfoArray);
        NSArray *keyArray = [[NSArray alloc]initWithObjects:@"wirelessmode",@"broadcastssid",@"channel",@"wl_power",@"n_bandwidth",@"n_extcha",@"enablewireless",@"mode",@"wmm_capable",@"apsd_capable",@"ssid",@"mssid_1",@"wds_list",@"wireless11gchannels",@"ap_isolate",@"wds_list",nil];
        NSInteger keyIndex=0;
        for (NSString *valueString in wifiBaseInfoArray) {
            if (keyIndex<[keyArray count]) {
                NSString *keyString = [keyArray objectAtIndex:keyIndex];
                [_wifiBaseInfoDict setObject:valueString forKey:keyString];
                keyIndex ++;
            }
        }
        
        DLog(@"wifiBaseInfoDict = %@",_wifiBaseInfoDict);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}


-(void)optimizeNetButtonClick:(UIButton *)sender{
    [self startDejalBezelActivityView:nil];
    [self loadSingalData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cell = @"cell";
    ProjectItemCell *oneChannelCell = [tableView dequeueReusableCellWithIdentifier:cell];
    if (!oneChannelCell) {
        oneChannelCell = [[ProjectItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell];
    }
    YXMNetChannelDataObjet *data = [_channelDataArr objectAtIndex:indexPath.row];
    [oneChannelCell setChannelObject:data];
    return oneChannelCell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_channelDataArr count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

/**
 *  列表中的复选框被选择或被反选的之后的表格的索引传给代理处理者
 *
 *  @param cellIndexPath 列表的索引
 *  @param checked       是否被选中
 */
-(void)didSelectedCheckBoxWithIndexPath:(NSIndexPath *)cellIndexPath checked:(BOOL)checked{
    
}

-(void)reloadTableData:(NSArray *)nearWifiDataArray{
    [_channelDataArr removeAllObjects];
    for (int i=1; i<14; i++) {
        YXMNetChannelDataObjet *channel = [[YXMNetChannelDataObjet alloc]init];
        NSString *channelStr = nil;
        if (i<10) {
            channelStr = [NSString stringWithFormat:@"0%d",i];
        }else{
           channelStr = [NSString stringWithFormat:@"%d",i];
        }
        [channel setChannelsName:[NSString stringWithFormat:@"信道%@",channelStr]];
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        [channel setChannelInnerRouterArray:arr];
        
        if ([[_wifiBaseInfoDict objectForKey:@"wireless11gchannels"] integerValue]==i) {
            [channel setIsIncludeCurrentDevice:YES];
        }else{
            [channel setIsIncludeCurrentDevice:NO];
        }
        [_channelDataArr addObject:channel];
    }
    
    DLog(@"nearWifiDataArray = %@",nearWifiDataArray);
    for (YXMRouterEntity *router in nearWifiDataArray) {
        NSInteger iChannelIndex = [router.wifi_channel integerValue]-1;
        if (iChannelIndex<0) {
            iChannelIndex = 0;
        }
        if (iChannelIndex >12) {
            iChannelIndex = 12;
        }
        YXMNetChannelDataObjet *channel = [_channelDataArr objectAtIndex:iChannelIndex];
        NSMutableArray *tempArr = [[NSMutableArray alloc]init];
        if (channel.channelInnerRouterArray) {
            [tempArr setArray:channel.channelInnerRouterArray];
        }
        [tempArr addObject:router];
        [channel setChannelInnerRouterArray:tempArr];
        [_channelDataArr replaceObjectAtIndex:iChannelIndex withObject:channel];
    }
    DLog(@"_channelDataArr = %@",_channelDataArr);
    [self.tableView reloadData];
}


-(void)loadSingalData{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *routerDomain = [IPHelpler getGatewayIPAddress];
    NSString *url_scan = [ud objectForKey:URL_WDSSCAN_WIFILIST];
    [manager GET:[NSString stringWithFormat:@"%@%@",routerDomain,url_scan] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [timer1 invalidate];
        NSString *sScanReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        DLog(@"sScanReturnCode = %@",sScanReturnCode);
        sScanReturnCode = [sScanReturnCode substringToIndex:([sScanReturnCode length]-1)];
        NSArray *wifiListArray = [sScanReturnCode componentsSeparatedByString:@"\r"];
        
        NSMutableArray *nearWifiDataArray = [[NSMutableArray alloc]init];
        for (NSString *wifi in wifiListArray) {
            NSArray *wifiArray = [wifi componentsSeparatedByString:@"\t"];
            DLog(@"wifiArray =%@",wifiArray);
            YXMRouterEntity *router = [[YXMRouterEntity alloc]init];
            [router setWifi_id:[wifiArray objectAtIndex:1]];
            [router setWifi_dbm:[wifiArray objectAtIndex:4]];
            [router setWifi_mac:[wifiArray objectAtIndex:1]];
            [router setWifi_channel:[wifiArray objectAtIndex:2]];
            [router setWifi_encrypt:[wifiArray objectAtIndex:3]];
            [nearWifiDataArray addObject:router];
        }
        [self reloadTableData:nearWifiDataArray];
        //加载数据完毕，关闭进度视图
        [self stopDegalBezeActivityView];
        [[[iToast makeText:NSLocalizedString(@"网络优化完成", @"")]
          setGravity:iToastGravityCenter] show:iToastTypeError];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self stopDegalBezeActivityView];
        [[[iToast makeText:NSLocalizedString(@"网络优化失败", @"")]
          setGravity:iToastGravityCenter] show:iToastTypeError];
    }];
}

@end
