//
//  YXMSpeedAdjustmentViewController.m
//  SmartHome
//
//  Created by iroboteer on 15/4/4.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMSpeedAdjustmentViewController.h"
#import "Config.h"
#import "IPHelpler.h"

#define TAG_CHANGE_WIFI_POWER_ALERT 100900

@interface YXMSpeedAdjustmentViewController ()

@end

@implementation YXMSpeedAdjustmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"穿墙提速";
    _wifiBaseInfoDict = [[NSMutableDictionary alloc]initWithCapacity:0];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _filter = [[SEFilterControl alloc]initWithFrame:CGRectMake((SCREEN_CGSIZE_WIDTH-(SCREEN_CGSIZE_WIDTH*0.618))/2, SCREEN_CGSIZE_HEIGHT*0.382, SCREEN_CGSIZE_WIDTH*0.618, 60) Titles:[NSArray arrayWithObjects:@"普通", @"增强", nil]];
    [_filter setProgressColor:[UIColor magentaColor]];
    [_filter setHandlerColor:[UIColor yellowColor]];
    [_filter setTitlesColor:[UIColor purpleColor]];
    [_filter setTitlesFont:[UIFont fontWithName:@"Didot" size:14]];
    [_filter addTarget:self action:@selector(filterValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_filter];
    
    UILabel *promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, _filter.frame.size.height+_filter.frame.origin.y, SCREEN_CGSIZE_WIDTH-40, SCREEN_CGSIZE_HEIGHT-(_filter.frame.size.height+_filter.frame.origin.y))];
    [promptLabel setText:@"1，滑动按钮可以调整路由器的功率，增强或者减弱信号，当调整成功后路由器会自动进行重启，您需要在手机的设置中重新连接到无线网络\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n."];
    [promptLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [promptLabel setFont:[UIFont systemFontOfSize:12]];
    [promptLabel setNumberOfLines:0];
    [self.view addSubview:promptLabel];
    
    
}
/**
 *  获取无线基本设置中的信息
 */
-(void)getWIFIBaseInfo{

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
        
//        var str=http_request2.responseText.split("\r");
//        ap_isolate
//        broadcastssidEnable = str[1];//0//是否广播也就是broadcastssid
//        channel_index = str[2];//0//设备通道索引也就是channel
//        countrycode = str[3];//US//国家代码也就是wl_power,功率调整
//        ht_bw = str[4];//1//等于参数n_bandwidth默认为1
//        ht_extcha = str[5];//none//扩展信道n_extcha默认值none
//        enable_wl = str[6];//1//无线开关enable_wl默认1也就是enablewireless
//        mode = str[7];//ap
//        wmmCapable = str[8];//on//wmm_capable默认on
//        APSDCapable = str[9];//off//apsd_capable默认off
//        SSID0 = ssid000;//str[12];//无线名称//ssid
//        SSID1 = ssid111;//str[13];//次无线名称//mssid_1
//        wireless11bchannels = str[12];//无线信道channel0-13其中0为自动
//        wireless11gchannels = str[13];
//        ap_isolate = str[14];//ap_isolate默认为0
//        wds_list = str[15];//wds_list默认为空
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
        NSString *wl_power = [_wifiBaseInfoDict objectForKey:@"wl_power"];
        if ([wl_power isEqualToString:@"FR"]) {
            [_filter setSelectedIndex:0];
        }
        if ([wl_power isEqualToString:@"HK"]) {
            [_filter setSelectedIndex:1];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
}

-(void)speedSelected:(NSString *)speedString{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    
    if ([speedString isEqualToString:@"FR"]||[speedString isEqualToString:@"HK"]) {
//        "apsd_capable" = off;
         NSString *apsd_capable = [_wifiBaseInfoDict objectForKey:@"apsd_capable"];
//        broadcastssid = 0;
        NSString *broadcastssid = [_wifiBaseInfoDict objectForKey:@"broadcastssid"];
//        channel = 0;
        NSString *channel = [_wifiBaseInfoDict objectForKey:@"channel"];
//        enablewireless = 1;
        NSString *enablewireless = [_wifiBaseInfoDict objectForKey:@"enablewireless"];
//        mode = ap;
        NSString *mode = [_wifiBaseInfoDict objectForKey:@"mode"];
//        "mssid_1" = "";
        NSString *mssid_1 = [_wifiBaseInfoDict objectForKey:@"mssid_1"];
//        "n_bandwidth" = 1;
        NSString *n_bandwidth = [_wifiBaseInfoDict objectForKey:@"n_bandwidth"];
//        "n_extcha" = none;
        NSString *n_extcha = [_wifiBaseInfoDict objectForKey:@"n_extcha"];
//        ssid = "Tenda_3FE708";
        NSString *ssid = [_wifiBaseInfoDict objectForKey:@"ssid"];
//        "wds_list" = 13;
        NSString *wds_list = [_wifiBaseInfoDict objectForKey:@"wds_list"];
//        wirelessmode = 9;
        NSString *wirelessmode = [_wifiBaseInfoDict objectForKey:@"wirelessmode"];
//        "wl_power" = HK;
        NSString *wl_power = [_wifiBaseInfoDict objectForKey:@"wl_power"];
//        "wmm_capable" = on;
        NSString *wmm_capable = [_wifiBaseInfoDict objectForKey:@"wmm_capable"];
//        ap_isolate
        NSString *ap_isolate = [_wifiBaseInfoDict objectForKey:@"ap_isolate"];
        
        NSDictionary *parameters = @{@"ssid":ssid,@"wirelessmode":wirelessmode,@"broadcastssid":broadcastssid,@"ap_isolate":ap_isolate,@"channel":channel,@"n_bandwidth":n_bandwidth,@"n_extcha":n_extcha,@"wmm_capable":wmm_capable,@"apsd_capable":apsd_capable,@"wl_power":speedString,@"GO":@"wireless_basic.asp",@"en_wl":enablewireless,@"enablewireless":enablewireless};
        DLog(@"parameters = %@",parameters);
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *routerDomain = [IPHelpler getGatewayIPAddress];
        NSString *url_change_wifi_ssid = [ud objectForKey:URL_MODIFY_WIFI_NAME];
        [manager POST:[NSString stringWithFormat:@"%@%@",routerDomain,url_change_wifi_ssid] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *sChangewl_powerReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            DLog(@"url = %@,sChangewl_powerReturnCode = %@",[operation response].URL,sChangewl_powerReturnCode);
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString *domain = [IPHelpler getGatewayIPAddress];
            NSString *url = [NSString stringWithFormat:@"%@/wireless_basic.asp",domain];
            NSString *responseUrl = [NSString stringWithFormat:@"%@",[operation response].URL];
            if ([responseUrl isEqualToString:url]) {
                
                UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"无线网络%@ 的功率已经调整成功,路由器正在重启,请稍后在设置中重新连接网络",ssid] delegate:self cancelButtonTitle:[Config DPLocalizedString:@"sure"] otherButtonTitles:nil, nil];
                [alerView show];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"sChangeSSIDerror = %@",error);
            UIAlertView *alerView2 = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"修改失败"] delegate:self cancelButtonTitle:[Config DPLocalizedString:@"sure"] otherButtonTitles:nil, nil];
            [alerView2 show];
        }];

    }


    
}

-(void)filterValueChanged:(SEFilterControl *) sender{
    
    
    
    if (sender) {
        iwl_power = sender.SelectedIndex;
        NSInteger iNewwl_power = 0;
        NSString *swl_power = [_wifiBaseInfoDict objectForKey:@"wl_power"];
        if ([swl_power isEqualToString:@"HK"]) {
            iNewwl_power = 1;
        }
        if ([swl_power isEqualToString:@"FR"]) {
            iNewwl_power = 0;
        }
        DLog(@"_filter.SelectedIndex = %d,被选择 = %d,iNewwl_power=%d", _filter.SelectedIndex,sender.SelectedIndex,iNewwl_power);
        if (iNewwl_power == iwl_power) {
            return;
        }
        if (_wifiBaseInfoDict) {
            if ([_wifiBaseInfoDict isKindOfClass:[NSDictionary class]]) {
                UIAlertView *wifiPowerChangeAlertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"调整无线型号强度后,路由器会重新启动,您确定要修改么？" delegate:self cancelButtonTitle:[Config DPLocalizedString:@"cancel"] otherButtonTitles:[Config DPLocalizedString:@"sure"], nil];
                [wifiPowerChangeAlertView setTag:TAG_CHANGE_WIFI_POWER_ALERT];
                [wifiPowerChangeAlertView show];
            }
        }

    }
    
}



-(void)modifyWifiPower:(NSInteger)myiwl_power{
    switch (myiwl_power) {
        case 0:
        {
            [self speedSelected:@"FR"];
        }
            break;
        case 1:
        {
            [self speedSelected:@"HK"];
        }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == TAG_CHANGE_WIFI_POWER_ALERT) {
        if (buttonIndex == 1) {
            DLog(@"iwl_power = %d",iwl_power);
            [self modifyWifiPower:iwl_power];
        }
        if (buttonIndex == 0) {
            NSInteger iNewwl_power = 0;
//            NSString *swl_power = [_wifiBaseInfoDict objectForKey:@"wl_power"];
//            if ([swl_power isEqualToString:@"HK"]) {
//                iNewwl_power = 1;
//            }
//            if ([swl_power isEqualToString:@"FR"]) {
//                iNewwl_power = 0;
//            }
            NSString *wl_power = [_wifiBaseInfoDict objectForKey:@"wl_power"];
            if ([wl_power isEqualToString:@"FR"]) {
                [_filter setSelectedIndex:0];
            }
            if ([wl_power isEqualToString:@"HK"]) {
                [_filter setSelectedIndex:1];
            }
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //获得路由器的基本信息
    [self getWIFIBaseInfo];
}

@end
