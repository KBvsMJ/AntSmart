//
//  YXMRelayViewController.m
//  SmartHome
//
//  Created by iroboteer on 15/4/4.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMRelayViewController.h"
#import "DropDownListView.h"
#import "UIView+Shadow.h"
#import "Config.h"
#import <iToast/iToast.h>
#import "IPHelpler.h"

#define WIFILIST_BASE_VIEW 200088
#define TAG_SSID_NAME_SELECT 200001
#define TAG_PASSWORD_SELECT 200002
#define TAG_PASSWORD_TEXTFIELD 200003
//提示路由器将重启
#define TAG_REBOOT_ROUTER 300003
//提示将桥接到路由器
#define TAG_EXTRA_ROUTER 300009

@interface YXMRelayViewController ()

@end

@implementation YXMRelayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    arryList = [[NSMutableArray alloc]init];
    self.title = @"万能中继";
    
    CGFloat widthSelectSSIDButton = SCREEN_CGSIZE_WIDTH*(300.0/320.0);
    CGFloat xSelectSSIDButton = (SCREEN_CGSIZE_WIDTH-widthSelectSSIDButton)/2.0;
    
    //是否打开万能中继
    UIView *isOpenView = [[UIView alloc]initWithFrame:CGRectMake(xSelectSSIDButton, 84, SCREEN_CGSIZE_WIDTH-xSelectSSIDButton*2, 44)];
    UILabel *isOpenTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, isOpenView.frame.size.width/2, 30)];
    [isOpenTitleLabel setText:@"是否启用万能中继"];
    [isOpenView addSubview:isOpenTitleLabel];
    _extraSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(isOpenView.frame.size.width-70, 0, 70, 30)];
    [isOpenView addSubview:_extraSwitch];
    [_extraSwitch addTarget:self action:@selector(isOpenRelay:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:isOpenView];
    
    //选择想要中继的wifi信号
    UILabel *ssidNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(xSelectSSIDButton, isOpenView.frame.origin.y + isOpenView.frame.size.height, widthSelectSSIDButton, 44)];
    [ssidNameLabel setText:@"选择您要中继的WiFi"];
    [ssidNameLabel setTag:TAG_SSID_NAME_SELECT];
    [ssidNameLabel setTextAlignment:NSTextAlignmentCenter];
    [ssidNameLabel setUserInteractionEnabled:YES];
    [ssidNameLabel.layer setBorderColor:[UIColor greenColor].CGColor];
    [ssidNameLabel.layer setBorderWidth:1.0];
    [self.view addSubview:ssidNameLabel];
    UILabel *promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 44)];
    [promptLabel setText:@"SSID"];
    [promptLabel setTextAlignment:NSTextAlignmentCenter];
    [promptLabel makeInsetShadowWithRadius:0.5 Color:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] Directions:[NSArray arrayWithObjects:@"right", nil]];
    [ssidNameLabel addSubview:promptLabel];
    UIImageView *arrowImangeView = [[UIImageView alloc]initWithFrame:CGRectMake(ssidNameLabel.frame.size.width-60, 0, 35, 35)];
    [arrowImangeView setImage:[UIImage imageNamed:@"toolbar_webview_pre"]];
    [ssidNameLabel addSubview:arrowImangeView];
    //点击开始选择想要中继的wifi的按钮
    selectSSIDButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectSSIDButton setFrame:CGRectMake(0, 0, ssidNameLabel.frame.size.width, ssidNameLabel.frame.size.height)];
    [selectSSIDButton addTarget:self action:@selector(searchWireless:) forControlEvents:UIControlEventTouchUpInside];
    [ssidNameLabel addSubview:selectSSIDButton];
    
    //输入选择的wifi的信号的密码
    UILabel *passwordLabel = [[UILabel alloc]initWithFrame:CGRectMake(xSelectSSIDButton, ssidNameLabel.frame.size.height+ssidNameLabel.frame.origin.y+20, widthSelectSSIDButton, 44)];
    [passwordLabel setTag:TAG_PASSWORD_SELECT];
    [passwordLabel setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel setUserInteractionEnabled:YES];
    [passwordLabel.layer setBorderColor:[UIColor greenColor].CGColor];
    [passwordLabel.layer setBorderWidth:1.0];
    [self.view addSubview:passwordLabel];
    UILabel *promptLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 44)];
    [promptLabel2 setText:@"密码"];
    [promptLabel2 makeInsetShadowWithRadius:0.5 Color:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] Directions:[NSArray arrayWithObjects:@"right", nil]];
    [promptLabel2 setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel addSubview:promptLabel2];
    
    UITextField *passwordField = [[UITextField alloc]initWithFrame:CGRectMake(64, 0, passwordLabel.frame.size.width-64, 44)];
    [passwordField setTag:TAG_PASSWORD_TEXTFIELD];
    [passwordField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [passwordField setDelegate:self];
    [passwordLabel addSubview:passwordField];
    
    //确定开始配置按钮
    configButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [configButton setFrame:CGRectMake(passwordLabel.frame.origin.x, passwordLabel.frame.size.height+passwordLabel.frame.origin.y+20, widthSelectSSIDButton, 44)];
    [configButton addTarget:self action:@selector(setupConfig:) forControlEvents:UIControlEventTouchUpInside];
    [configButton setTitle:@"开始配置" forState:UIControlStateNormal];
    [configButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [configButton.layer setBorderColor:[UIColor greenColor].CGColor];
    [configButton.layer setBorderWidth:1.0];
    [self.view addSubview:configButton];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
}

-(void)getNearRouterDevice{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *routerDomain = [IPHelpler getGatewayIPAddress];
    NSString *url_scan = [ud objectForKey:URL_WDSSCAN_WIFILIST];
    NSString *url = [NSString stringWithFormat:@"%@%@",routerDomain,url_scan];
    DLog(@"url = %@",url);
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSString *sScanReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        DLog(@"sScanReturnCode = %@",sScanReturnCode);
        sScanReturnCode = [sScanReturnCode substringToIndex:([sScanReturnCode length]-1)];
        NSArray *wifiListArray = [sScanReturnCode componentsSeparatedByString:@"\r"];
        
        NSMutableArray *nearWifiDataArray = [[NSMutableArray alloc]init];
        for (NSString *wifi in wifiListArray) {
            NSArray *wifiArray = [wifi componentsSeparatedByString:@"\t"];
            DLog(@"wifiArray =%@",wifiArray);
            
            if ([[wifiArray objectAtIndex:0] length]>1) {
                YXMRouterEntity *router = [[YXMRouterEntity alloc]init];
                [router setWifi_name:[wifiArray objectAtIndex:0]];
                [router setWifi_id:[wifiArray objectAtIndex:1]];
                [router setWifi_dbm:[wifiArray objectAtIndex:4]];
                [router setWifi_mac:[wifiArray objectAtIndex:1]];
                [router setWifi_channel:[wifiArray objectAtIndex:2]];
                [router setWifi_encrypt:[wifiArray objectAtIndex:3]];
                [nearWifiDataArray addObject:router];
            }
            
        }
        if ([nearWifiDataArray count]>0) {
            [arryList addObjectsFromArray:nearWifiDataArray];
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showPopUpWithTitle:(NSString*)popupTitle withOption:(NSArray*)arrOptions xy:(CGPoint)point size:(CGSize)size isMultiple:(BOOL)isMultiple{
    UIView *baseView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_CGSIZE_WIDTH, SCREEN_CGSIZE_HEIGHT-64)];
    [baseView setBackgroundColor:[UIColor whiteColor]];
    [baseView setTag:WIFILIST_BASE_VIEW];
    [self.view addSubview:baseView];
    
    Dropobj = [[DropDownListView alloc] initWithTitle:popupTitle options:arrOptions xy:point size:size isMultiple:isMultiple];
    Dropobj.delegate = self;
    [Dropobj showInView:baseView animated:YES];
    
    /*----------------Set DropDown backGroundColor-----------------*/
    [UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000];
    [Dropobj SetBackGroundDropDwon_R:120.0 G:199.92 B:14.025 alpha:0.70];
}

- (void)DropDownListView:(DropDownListView *)dropdownListView didSelectedIndex:(NSInteger)anIndex{
    /*----------------Get Selected Value[Single selection]-----------------*/
    [self hiddenDropDownList];
    UILabel *ssidNameLabel = (UILabel *)[self.view viewWithTag:TAG_SSID_NAME_SELECT];
    if (arryList) {
        if ([arryList count]>anIndex) {
            YXMRouterEntity *router = [arryList objectAtIndex:anIndex];
            [ssidNameLabel setText:router.wifi_name];
            _selectedRouter = router;
        }
    }
}

- (void)DropDownListView:(DropDownListView *)dropdownListView Datalist:(NSMutableArray*)ArryData{
    
    /*----------------Get Selected Value[Multiple selection]-----------------*/
    if (ArryData.count>0) {

    }
    else{

    }
    
}

-(void)DropDownListViewDidCancel{
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if ([touch.view isKindOfClass:[UIView class]]) {
        [self hiddenDropDownList];
    }
}

-(void)hiddenDropDownList{
    [Dropobj fadeOut];
    [[self.view viewWithTag:WIFILIST_BASE_VIEW] removeFromSuperview];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/**
 *  搜索无线信号并且呈现到列表中
 *
 *  @param sender 供客户点击的搜索按钮
 */
-(void)searchWireless:(UIButton *)sender{
    
    // Do any additional setup after loading the view.
    [self hiddenDropDownList];
    NSMutableArray *titleArray = [[NSMutableArray alloc]init];
    if (arryList) {
        if ([arryList count]<1) {
            [[[iToast makeText:NSLocalizedString(@"正在搜索附近的无线网络,稍后再试！", @"")]
              setGravity:iToastGravityCenter] show:iToastTypeError];
            return;
        }
        for (YXMRouterEntity *router in arryList) {
            if (router.wifi_name) {
                [titleArray addObject:router.wifi_name];
            }
            
        }
        if (titleArray) {
            if ([titleArray count]>0) {
                [self showPopUpWithTitle:@"选择你要中继的SSID" withOption:titleArray xy:CGPointMake(20, 86) size:CGSizeMake(SCREEN_CGSIZE_WIDTH-40, SCREEN_CGSIZE_HEIGHT-200) isMultiple:NO];
            }
        }
        
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


-(void)setupConfig:(UIButton *)sender{
    if (_selectedRouter.wifi_name) {
        if (_extraSwitch.on) {
            UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"确定要桥接到%@无线网络吗？",_selectedRouter.wifi_name] delegate:self cancelButtonTitle:[Config DPLocalizedString:@"cancel"] otherButtonTitles:[Config DPLocalizedString:@"sure"], nil];
            [alerView setDelegate:self];
            [alerView setTag:TAG_EXTRA_ROUTER];
            [alerView show];
        }
    }
}


-(void)extraRouter{
    UITextField *passphraseTestField = (UITextField *)[self.view viewWithTag:TAG_PASSWORD_TEXTFIELD];
    NSString *sPassphrase = passphraseTestField.text;
    if ([sPassphrase length]>30) {
        return;
    }
    if ([sPassphrase length]<1) {
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *securityAndCipher = _selectedRouter.wifi_encrypt;
    NSArray *sacArr = [securityAndCipher componentsSeparatedByString:@"_"];
    NSString *security = nil;
    NSString *cipher = nil;
    if ([sacArr count]!=2) {
        DLog(@"数据分解错误");
        security = @"0";
        cipher = @"none";
    }else{
        security = [sacArr firstObject];
        cipher = [sacArr lastObject];
    }
    
    if ([security isEqualToString:@"WPA"]) {
        security = @"psk";
    }
    if ([security isEqualToString:@"WPA2"]) {
        security = @"psk2";
    }
    if ([security isEqualToString:@"WPAWPA2"]) {
        security = @"psk psk2";
    }
    //    AESTKIP
    if ([cipher isEqualToString:@"AESTKIP"]) {
        cipher = @"tkip+aes";
    }
    
    
    NSDictionary *parameters = @{@"extra_mode":@"wisp",@"ssid": _selectedRouter.wifi_name,@"channel":_selectedRouter.wifi_channel,@"security":security,@"cipher":cipher,@"passphrase":sPassphrase,@"wds_list":@"1"};
    DLog(@"parameters = %@",parameters);
    NSString *routerDomain = [IPHelpler getGatewayIPAddress];
    NSString *url_wireless_extra = [ud objectForKey:URL_WIRELESS_EXTRA];
    [manager POST:[NSString stringWithFormat:@"%@%@",routerDomain,url_wireless_extra] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *sExtraWifiReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        DLog(@"url = %@,sExtraWifiReturnCode = %@",[operation response].URL,sExtraWifiReturnCode);
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *domain = [IPHelpler getGatewayIPAddress];
        NSString *url = [NSString stringWithFormat:@"%@/direct_reboot.asp",domain];
        NSString *responseUrl = [NSString stringWithFormat:@"%@",[operation response].URL];
        if ([responseUrl isEqualToString:url]) {
            
            UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"无线网络已经桥接到%@,点击确定重启路由器！",_selectedRouter.wifi_name] delegate:self cancelButtonTitle:[Config DPLocalizedString:@"sure"] otherButtonTitles:nil, nil];
            [alerView setDelegate:self];
            [alerView setTag:TAG_REBOOT_ROUTER];
            [alerView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"sChangeSSIDerror = %@",error);
        UIAlertView *alerView2 = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"桥接失败"] delegate:self cancelButtonTitle:[Config DPLocalizedString:@"sure"] otherButtonTitles:nil, nil];
        [alerView2 show];
    }];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == TAG_EXTRA_ROUTER) {
        if (buttonIndex==1) {
            [self extraRouter];
        }
    }
    if (alertView.tag == TAG_REBOOT_ROUTER) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *routerDomain = [IPHelpler getGatewayIPAddress];
        
        [manager GET:[NSString stringWithFormat:@"%@direct_reboot.asp",routerDomain] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadExtraSetupState];
}

-(void)loadExtraSetupState{
    [_extraSwitch setOn:NO];
    [self isOpenRelay:_extraSwitch];
}


-(void)isOpenRelay:(UISwitch *)mySwitch{
    DLog(@"%d",mySwitch.isOn);
    UITextField *passphraseTestField = (UITextField *)[self.view viewWithTag:TAG_PASSWORD_TEXTFIELD];
    
    if (mySwitch.isOn) {
        [selectSSIDButton setEnabled:YES];
        [passphraseTestField setEnabled:YES];
        [self getNearRouterDevice];
    }else{
        [selectSSIDButton setEnabled:NO];
        [passphraseTestField setEnabled:NO];
    }
}
@end
