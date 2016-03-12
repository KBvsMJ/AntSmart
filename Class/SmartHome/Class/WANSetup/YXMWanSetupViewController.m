//
//  YXMWanSetupViewController.m
//  SmartHome
//
//  Created by iroboteer on 15/4/9.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMWanSetupViewController.h"
#import "UIView+Shadow.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "Config.h"
#import <iToast/iToast.h>
#import "IPHelpler.h"

#define TAG_NET_METHOD 300012
#define TAG_NET_METHOD_SELECT 300022
#define TAG_NET_ACCOUNT_SELECT 300024
#define TAG_NET_PASSWORD_SELECT 300026
#define TAG_NET_PASSWORD_FIELD 300028
//静态IP地址
#define TAG_STATIC_IP_ADDRESS 400022
#define TAG_STATIC_MASK_ADDRESS 400023
#define TAG_STATIC_GETWAY_ADDRESS 400024
#define TAG_STATIC_DNS_ADDRESS 400025
#define TAG_STATIC_SPARE_DNS_ADDRESS 400026

@interface YXMWanSetupViewController ()

@end

@implementation YXMWanSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"上网设置";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    //初始化数据
    //上网方式设置为adsl拨号
    setWANMethod = 0;
    //上网方式的名称集合
    sizeArray = [[NSArray alloc] initWithObjects:@"ADSL拨号",@"自动获取",@"静态IP", nil];
    
    [self.view setUserInteractionEnabled:YES];
    _baseView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_baseView];
    rectBaseView = _baseView.frame;
    //设置上网方式
    CGFloat widthSelectSSIDButton = SCREEN_CGSIZE_WIDTH*(300.0/320.0);
    CGFloat xSelectSSIDButton = (SCREEN_CGSIZE_WIDTH-widthSelectSSIDButton)/2.0;
    UILabel *ssidNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(xSelectSSIDButton, 24, widthSelectSSIDButton, 44)];
    [ssidNameLabel.layer setBorderColor:[UIColor colorWithRed:0.463 green:0.792 blue:0.000 alpha:1.000].CGColor];
    [ssidNameLabel.layer setBorderWidth:1.0];
    [_baseView addSubview:ssidNameLabel];
    UILabel *promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 44)];
    [promptLabel setText:@"上网方式"];
    [promptLabel setTextAlignment:NSTextAlignmentCenter];
    [promptLabel setFont:[UIFont systemFontOfSize:12]];
    [promptLabel makeInsetShadowWithRadius:0.5 Color:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] Directions:[NSArray arrayWithObjects:@"right", nil]];
    [ssidNameLabel addSubview:promptLabel];
    UIView *ssidField = [[UIView alloc]initWithFrame:CGRectMake(64, 0, ssidNameLabel.frame.size.width-64, 44)];
    [ssidField setTag:TAG_NET_METHOD];
    [ssidField setUserInteractionEnabled:YES];
    [ssidNameLabel setUserInteractionEnabled:YES];
    [ssidNameLabel addSubview:ssidField];
    
    
    //创建三种上网方式
    UIView *wanMethodView = [[UIView alloc]initWithFrame:CGRectMake(xSelectSSIDButton, 24+44, widthSelectSSIDButton, 44*8)];
    CGRect rectWan = CGRectMake(0, 0, widthSelectSSIDButton, 44*7);
    _adslView = [self createADSLSetupViewWithFrame:rectWan];
    [wanMethodView addSubview:_adslView];
    [_adslView setHidden:YES];
    _autoView = [self createAutoSetupViewWithFrame:rectWan];
    [wanMethodView addSubview:_autoView];
    [_autoView setHidden:NO];
    _staticView = [self createStaticIPSetupViewWithFrame:rectWan];
    [wanMethodView addSubview:_staticView];
    [_staticView setHidden:YES];
    [_baseView addSubview:wanMethodView];
    //上网方式下拉选择框
    [self createSizeTextFieldWithFrame:CGRectMake(xSelectSSIDButton+64.0, 24, widthSelectSSIDButton-64, 44) andTag:TAG_NET_METHOD_SELECT superViewTag:TAG_NET_METHOD];
    //保存设置按钮
    saveConfigButton = [[BaseButton alloc]initWithFrame:CGRectMake(xSelectSSIDButton, wanMethodView.frame.origin.y+wanMethodView.frame.size.height, widthSelectSSIDButton, 44)];
    [saveConfigButton setTitle:@"保存配置" forState:UIControlStateNormal];
    [saveConfigButton addTarget:self action:@selector(saveConfigButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [saveConfigButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [saveConfigButton.layer setBorderColor:[UIColor colorWithRed:0.463 green:0.792 blue:0.000 alpha:1.000].CGColor];
    [saveConfigButton.layer setBorderWidth:1.0];
    [_baseView addSubview:saveConfigButton];
    rectSaveConfigButton = saveConfigButton.frame;
    [saveConfigButton setFrame:CGRectMake(rectSaveConfigButton.origin.x, rectSaveConfigButton.origin.y-100, rectSaveConfigButton.size.width, rectSaveConfigButton.size.height)];
    [_baseView setContentSize:CGSizeMake(self.view.frame.size.width, wanMethodView.frame.origin.y+wanMethodView.frame.size.height+100)];
    
    if (!_adslView.hidden) {
        [saveConfigButton setFrame:CGRectMake(rectSaveConfigButton.origin.x, (_adslPwdTextField.frame.origin.y+_adslPwdTextField.frame.size.height)+(ssidNameLabel.frame.origin.y + ssidNameLabel.frame.size.height)+30+64, rectSaveConfigButton.size.width, rectSaveConfigButton.size.height)];
    }
    
}

//创建自动获取设置视图
-(UIView *)createAutoSetupViewWithFrame:(CGRect)rect{
    UIView *autoSetupView = [[UIView alloc]initWithFrame:rect];
    [autoSetupView setBackgroundColor:[UIColor whiteColor]];
    UILabel *promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, rect.size.width, rect.size.height-20)];
    [promptLabel setBackgroundColor:[UIColor clearColor]];
    [promptLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [promptLabel setNumberOfLines:10];
    [promptLabel setFont:[UIFont systemFontOfSize:14]];
    [promptLabel setTextColor:[UIColor blackColor]];
    [promptLabel setText:[Config DPLocalizedString:@"autoNetPromptLabel"]];
    [autoSetupView addSubview:promptLabel];
    return autoSetupView;
}
//创建拨号方式设置视图
-(UIView *)createADSLSetupViewWithFrame:(CGRect)rect{
    UIView *autoSetupView = [[UIView alloc]initWithFrame:rect];
    [autoSetupView setBackgroundColor:[UIColor whiteColor]];
    //宽带账号
    UILabel *passwordLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, rect.size.width, 44)];
    [passwordLabel setTag:TAG_NET_ACCOUNT_SELECT];
    [passwordLabel setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel setUserInteractionEnabled:YES];
    [passwordLabel.layer setBorderColor:[UIColor colorWithRed:0.463 green:0.792 blue:0.000 alpha:1.000].CGColor];
    [passwordLabel.layer setBorderWidth:1.0];
    [autoSetupView addSubview:passwordLabel];
    UILabel *promptLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 44)];
    [promptLabel2 setText:[Config DPLocalizedString:@"adslAccountLabel"]];//@"宽带账号"
    [promptLabel2 setFont:[UIFont systemFontOfSize:12]];
    [promptLabel2 makeInsetShadowWithRadius:0.5 Color:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] Directions:[NSArray arrayWithObjects:@"right", nil]];
    [promptLabel2 setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel addSubview:promptLabel2];
    
    _adslTextField = [[UITextField alloc]initWithFrame:CGRectMake(64, 0, passwordLabel.frame.size.width-64, 44)];
    [_adslTextField setTag:TAG_NET_ACCOUNT_SELECT];
    [_adslTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_adslTextField setDelegate:self];
    [passwordLabel addSubview:_adslTextField];
    
    //宽带密码
    UILabel *passwordLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(0, passwordLabel.frame.origin.y + passwordLabel.frame.size.height + 20, rect.size.width, 44)];
    [passwordLabel1 setTag:TAG_NET_PASSWORD_SELECT];
    [passwordLabel1 setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel1 setUserInteractionEnabled:YES];
    [passwordLabel1.layer setBorderColor:[UIColor colorWithRed:0.463 green:0.792 blue:0.000 alpha:1.000].CGColor];
    [passwordLabel1.layer setBorderWidth:1.0];
    [autoSetupView addSubview:passwordLabel1];
    UILabel *promptLabel21 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 44)];
    [promptLabel21 setText:[Config DPLocalizedString:@"adslPwdLabel"]];//@"宽带密码"
    [promptLabel21 setFont:[UIFont systemFontOfSize:12]];
    [promptLabel21 makeInsetShadowWithRadius:0.5 Color:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] Directions:[NSArray arrayWithObjects:@"right", nil]];
    [promptLabel21 setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel1 addSubview:promptLabel21];
    
    _adslPwdTextField = [[UITextField alloc]initWithFrame:CGRectMake(64, 0, passwordLabel.frame.size.width-64, 44)];
    [_adslPwdTextField setTag:TAG_NET_PASSWORD_FIELD];
    [_adslPwdTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_adslPwdTextField setDelegate:self];
    [passwordLabel1 addSubview:_adslPwdTextField];
    
    
    return autoSetupView;
}
//创建静态ip设置视图
-(UIView *)createStaticIPSetupViewWithFrame:(CGRect)rect{
    UIView *autoSetupView = [[UIView alloc]initWithFrame:rect];
    [autoSetupView setBackgroundColor:[UIColor whiteColor]];
    //ip地址
    UILabel *passwordLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, rect.size.width, 44)];
    [passwordLabel setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel setUserInteractionEnabled:YES];
    [passwordLabel.layer setBorderColor:[UIColor colorWithRed:0.463 green:0.792 blue:0.000 alpha:1.000].CGColor];
    [passwordLabel.layer setBorderWidth:1.0];
    [autoSetupView addSubview:passwordLabel];
    UILabel *promptLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 44)];
    [promptLabel2 setText:[Config DPLocalizedString:@"ipaddressLabel"]];
    [promptLabel2 setFont:[UIFont systemFontOfSize:12]];
    [promptLabel2 makeInsetShadowWithRadius:0.5 Color:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] Directions:[NSArray arrayWithObjects:@"right", nil]];
    [promptLabel2 setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel addSubview:promptLabel2];
    
    _ipAddressTextField = [[UITextField alloc]initWithFrame:CGRectMake(64, 0, passwordLabel.frame.size.width-64, 44)];
    [_ipAddressTextField setTag:TAG_STATIC_IP_ADDRESS];
    [_ipAddressTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_ipAddressTextField setDelegate:self];
    [passwordLabel addSubview:_ipAddressTextField];
    
    //子网掩码
    UILabel *passwordLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, passwordLabel.frame.origin.y + passwordLabel.frame.size.height + 20, rect.size.width, 44)];
    [passwordLabel2 setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel2 setUserInteractionEnabled:YES];
    [passwordLabel2.layer setBorderColor:[UIColor colorWithRed:0.463 green:0.792 blue:0.000 alpha:1.000].CGColor];
    [passwordLabel2.layer setBorderWidth:1.0];
    [autoSetupView addSubview:passwordLabel2];
    UILabel *promptLabel22 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 44)];
    [promptLabel22 setText:[Config DPLocalizedString:@"maskaddressLabel"]];
    [promptLabel22 setFont:[UIFont systemFontOfSize:12]];
    [promptLabel22 makeInsetShadowWithRadius:0.5 Color:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] Directions:[NSArray arrayWithObjects:@"right", nil]];
    [promptLabel22 setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel2 addSubview:promptLabel22];
    
    _maskAddressTextField = [[UITextField alloc]initWithFrame:CGRectMake(64, 0, passwordLabel.frame.size.width-64, 44)];
    [_maskAddressTextField setTag:TAG_STATIC_MASK_ADDRESS];
    [_maskAddressTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_maskAddressTextField setDelegate:self];
    [passwordLabel2 addSubview:_maskAddressTextField];
    
    //网关
    UILabel *passwordLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(0, passwordLabel2.frame.origin.y + passwordLabel2.frame.size.height + 20, rect.size.width, 44)];
    [passwordLabel3 setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel3 setUserInteractionEnabled:YES];
    [passwordLabel3.layer setBorderColor:[UIColor colorWithRed:0.463 green:0.792 blue:0.000 alpha:1.000].CGColor];
    [passwordLabel3.layer setBorderWidth:1.0];
    [autoSetupView addSubview:passwordLabel3];
    UILabel *promptLabel23 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 44)];
    [promptLabel23 setText:[Config DPLocalizedString:@"getwayLabel"]];
    [promptLabel23 setFont:[UIFont systemFontOfSize:12]];
    [promptLabel23 makeInsetShadowWithRadius:0.5 Color:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] Directions:[NSArray arrayWithObjects:@"right", nil]];
    [promptLabel23 setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel3 addSubview:promptLabel23];
    
    _getwayTextField = [[UITextField alloc]initWithFrame:CGRectMake(64, 0, passwordLabel.frame.size.width-64, 44)];
    [_getwayTextField setTag:TAG_STATIC_GETWAY_ADDRESS];
    [_getwayTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_getwayTextField setDelegate:self];
    [passwordLabel3 addSubview:_getwayTextField];
    
    //dns
    UILabel *passwordLabel4 = [[UILabel alloc]initWithFrame:CGRectMake(0, passwordLabel3.frame.origin.y + passwordLabel3.frame.size.height + 20, rect.size.width, 44)];
    [passwordLabel4 setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel4 setUserInteractionEnabled:YES];
    [passwordLabel4.layer setBorderColor:[UIColor colorWithRed:0.463 green:0.792 blue:0.000 alpha:1.000].CGColor];
    [passwordLabel4.layer setBorderWidth:1.0];
    [autoSetupView addSubview:passwordLabel4];
    UILabel *promptLabel24 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 44)];
    [promptLabel24 setText:[Config DPLocalizedString:@"dnsaddressLabel"]];
    [promptLabel24 setFont:[UIFont systemFontOfSize:12]];
    [promptLabel24 makeInsetShadowWithRadius:0.5 Color:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] Directions:[NSArray arrayWithObjects:@"right", nil]];
    [promptLabel24 setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel4 addSubview:promptLabel24];
    
    _dnsTextField = [[UITextField alloc]initWithFrame:CGRectMake(64, 0, passwordLabel.frame.size.width-64, 44)];
    [_dnsTextField setTag:TAG_STATIC_DNS_ADDRESS];
    [_dnsTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_dnsTextField setDelegate:self];
    [passwordLabel4 addSubview:_dnsTextField];
    
    //备用dns
    UILabel *passwordLabel5 = [[UILabel alloc]initWithFrame:CGRectMake(0, passwordLabel4.frame.origin.y + passwordLabel4.frame.size.height + 20, rect.size.width, 44)];
    [passwordLabel5 setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel5 setUserInteractionEnabled:YES];
    [passwordLabel5.layer setBorderColor:[UIColor colorWithRed:0.463 green:0.792 blue:0.000 alpha:1.000].CGColor];
    [passwordLabel5.layer setBorderWidth:1.0];
    [autoSetupView addSubview:passwordLabel5];
    UILabel *promptLabel25 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 44)];
    [promptLabel25 setText:[Config DPLocalizedString:@"sparednsLabel"]];
    [promptLabel25 setFont:[UIFont systemFontOfSize:12]];
    [promptLabel25 makeInsetShadowWithRadius:0.5 Color:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] Directions:[NSArray arrayWithObjects:@"right", nil]];
    [promptLabel25 setTextAlignment:NSTextAlignmentCenter];
    [passwordLabel5 addSubview:promptLabel25];
    
    _spareDnsTextField = [[UITextField alloc]initWithFrame:CGRectMake(64, 0, passwordLabel.frame.size.width-64, 44)];
    [_spareDnsTextField setTag:TAG_STATIC_SPARE_DNS_ADDRESS];
    [_spareDnsTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_spareDnsTextField setDelegate:self];
    [passwordLabel5 addSubview:_spareDnsTextField];
    
    return autoSetupView;
}

/**
 *  创建上网方式设置控件
 *
 *  @param myFrame 控件的位置
 */
-(void)createSizeTextFieldWithFrame:(CGRect)myFrame andTag:(NSInteger)myTag superViewTag:(NSInteger)superTag{
    UIView *textView = [[UIView alloc]initWithFrame:myFrame];
    
    UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, myFrame.size.height)];
    [myLabel setFont:[UIFont systemFontOfSize:10]];

    
    /*设置上网方式*/
    sizeTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, myFrame.size.width-50, myFrame.size.height)];
    sizeTextField.delegate = self;
    sizeTextField.borderStyle = UITextBorderStyleLine;
    sizeTextField.textAlignment = NSTextAlignmentLeft;
    sizeTextField.keyboardType = UIKeyboardTypeNumberPad;
    sizeTextField.text = [sizeArray objectAtIndex:setWANMethod];
    sizeTextField.enabled = NO;
    
    sizeIsOpend = NO;//判断下拉tableView是否打开
    sizeButton = [[BaseButton alloc] initWithFrame:CGRectMake(myFrame.size.width-44, 0, 44, 44) andNorImg:@"toolbar_webview_pre" andHigImg:nil andTitle:nil];
    [sizeButton addTarget:self action:@selector(sizeButton:) forControlEvents:UIControlEventTouchUpInside];
    
    sizeTableBlock = [[TableViewWithBlock alloc] initWithFrame:CGRectMake(myFrame.origin.x, myFrame.origin.y + myFrame.size.height, myFrame.size.width-50, 1) style:UITableViewStylePlain];
    
    [sizeTableBlock initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
        return (CGFloat)[sizeArray count];
    } setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        [cell.lb setText:[sizeArray objectAtIndex:indexPath.row]];
        
        return cell;
    } setDidSelectRowBlock:^(UITableView *tableView, NSIndexPath *indexPath){
        SelectionCell *cell = (SelectionCell *)[tableView cellForRowAtIndexPath:indexPath];
        sizeTextField.text = cell.lb.text;
        setWANMethod = indexPath.row;
        switch (setWANMethod) {
            case 0:
            {
                [_adslView setHidden:NO];
                [_autoView setHidden:YES];
                [_staticView setHidden:YES];
                [saveConfigButton setFrame:CGRectMake(rectSaveConfigButton.origin.x, (_adslPwdTextField.frame.origin.y+_adslPwdTextField.frame.size.height+20)+(sizeTableBlock.frame.origin.y + sizeTableBlock.frame.size.height)+30, rectSaveConfigButton.size.width, rectSaveConfigButton.size.height)];
                myMethod = WANOfSetupADSL;
            }
            break;
            case 1:
            {
                [_adslView setHidden:YES];
                [_autoView setHidden:NO];
                [_staticView setHidden:YES];
                [saveConfigButton setFrame:CGRectMake(rectSaveConfigButton.origin.x, rectSaveConfigButton.origin.y-100, rectSaveConfigButton.size.width, rectSaveConfigButton.size.height)];
                myMethod = WANOfSetupAuto;
            }
            break;
            case 2:
            {
                [_adslView setHidden:YES];
                [_autoView setHidden:YES];
                [_staticView setHidden:NO];
                [saveConfigButton setFrame:rectSaveConfigButton];
                myMethod = WANOfSetupStatic;
            }
            break;
                
            default:
                break;
        }
        [sizeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }];
    [sizeTableBlock.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [sizeTableBlock.layer setBorderWidth:2];
    [textView setUserInteractionEnabled:YES];
    [textView addSubview:myLabel];
    [textView addSubview:sizeTextField];
    [textView addSubview:sizeButton];
    [_baseView addSubview:sizeTableBlock];
    
    [_baseView addSubview:textView];
}

/**
 *  上网方式设置的下拉框的回调事件
 *
 *  @param sender 触发的按钮
 */
- (void)sizeButton:(BaseButton *)sender {
    if (sizeIsOpend) {
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *closeImage=[UIImage imageNamed:@"toolbar_webview_pre"];
            [sizeButton setBackgroundImage:closeImage forState:UIControlStateNormal];
            CGRect frame=sizeTableBlock.frame;
            frame.size.height=1;
            [sizeTableBlock setFrame:frame];
        } completion:^(BOOL finished){
            sizeIsOpend=NO;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *openImage=[UIImage imageNamed:@"drop_up"];
            [sizeButton setBackgroundImage:openImage forState:UIControlStateNormal];
            CGRect frame=sizeTableBlock.frame;
            frame.size.height=[sizeArray count]*30;
            [sizeTableBlock setFrame:frame];
        } completion:^(BOOL finished){
            sizeIsOpend=YES;
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  保存设置信息的按钮
 *
 *  @param senderf 保存按钮
 */
-(void)saveConfigButtonClick:(BaseButton *)senderf{
    if (myMethod == WANOfSetupAuto) {
        [self autoGetMethod];
    }
    if (myMethod == WANOfSetupADSL) {
        [self setADSLMethod];
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//关闭键盘
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self closeTextField];
    return YES;
}

//关闭键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self closeTextField];
}

//关闭键盘
-(void)closeTextField
{
    [_adslTextField resignFirstResponder];
    [_adslPwdTextField resignFirstResponder];
    [_ipAddressTextField resignFirstResponder];
    [_maskAddressTextField resignFirstResponder];
    [_getwayTextField resignFirstResponder];
    [_dnsTextField resignFirstResponder];
    [_spareDnsTextField resignFirstResponder];
    
    [_baseView setFrame:rectBaseView];
}

//防止输入框被键盘覆盖
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _adslPwdTextField)
    {
        if (((_adslPwdTextField.superview.frame.origin.y+_adslPwdTextField.superview.frame.size.height+24+20)+64)>(self.view.frame.size.height-251.5)) {
            [_baseView setFrame:CGRectMake(rectBaseView.origin.x, rectBaseView.origin.y-44, rectBaseView.size.width, rectBaseView.size.height)];
        }
    }

    if (textField == _maskAddressTextField)
    {
        if (((_maskAddressTextField.superview.frame.origin.y+_maskAddressTextField.superview.frame.size.height+24+20)+64)>(self.view.frame.size.height-251.5)) {
            [_baseView setFrame:CGRectMake(rectBaseView.origin.x, rectBaseView.origin.y-44, rectBaseView.size.width, rectBaseView.size.height)];
        }
    }
    
    if (textField == _getwayTextField)
    {
        if (((_getwayTextField.superview.frame.origin.y+_getwayTextField.superview.frame.size.height+24+20)+64)>(self.view.frame.size.height-251.5)) {
            [_baseView setFrame:CGRectMake(rectBaseView.origin.x, rectBaseView.origin.y-88, rectBaseView.size.width, rectBaseView.size.height)];
        }
    }
    
    if (textField == _dnsTextField)
    {
        if (((_dnsTextField.superview.frame.origin.y+_dnsTextField.superview.frame.size.height+24+40)+64)>(self.view.frame.size.height-251.5)) {
            [_baseView setFrame:CGRectMake(rectBaseView.origin.x, rectBaseView.origin.y-155, rectBaseView.size.width, rectBaseView.size.height)];
        }
    }
    
    if (textField == _spareDnsTextField)
    {
        if (((_spareDnsTextField.superview.frame.origin.y+_spareDnsTextField.superview.frame.size.height+24+40)+64)>(self.view.frame.size.height-251.5)) {
            [_baseView setFrame:CGRectMake(rectBaseView.origin.x, rectBaseView.origin.y-220, rectBaseView.size.width, rectBaseView.size.height)];
        }
    }
}


-(void)autoGetMethod{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    //,@"":@""
    NSDictionary *parameters = @{@"WANT1":@"2",@"GO": @"wan_connectd.asp",@"MTU":@"1500",@"rebootTag":@"",@"v12_time":@"",@"WANT2":@""};
    DLog(@"parameters = %@",parameters);
    NSString *routerDomain = [IPHelpler getGatewayIPAddress];
    NSString *url_adv_set_wan = [ud objectForKey:URL_ADVSET_WAN];
    [manager POST:[NSString stringWithFormat:@"%@%@",routerDomain,url_adv_set_wan] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *sChangeSSIDReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        DLog(@"url = %@,sChangeSSIDReturnCode = %@",[operation response].URL,sChangeSSIDReturnCode);
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *domain = [IPHelpler getGatewayIPAddress];
        NSString *url = [NSString stringWithFormat:@"%@/system_status.asp",domain];
        NSString *responseUrl = [NSString stringWithFormat:@"%@",[operation response].URL];
        if ([responseUrl isEqualToString:url]) {
            
            UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"网络已经设置为自动获取的方式"] delegate:self cancelButtonTitle:[Config DPLocalizedString:@"sure"] otherButtonTitles:nil, nil];
            [alerView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"sChangeSSIDerror = %@",error);
        UIAlertView *alerView2 = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"设置失败"] delegate:self cancelButtonTitle:[Config DPLocalizedString:@"sure"] otherButtonTitles:nil, nil];
        [alerView2 show];
    }];

}

-(void)setADSLMethod{
    NSString *pun = [_adslTextField text];
    NSString *ppw = [_adslPwdTextField text];
    if (!ppw) {
        return;
    }
    if (!pun) {
        return;
    }
    if (([pun length]<1)||([ppw length]<1)) {
        [[[iToast makeText:NSLocalizedString(@"宽带账号或密码不能为空", @"")]
          setGravity:iToastGravityCenter] show:iToastTypeError];
        return;
    }
    if ([ppw length]>128) {
        [[[iToast makeText:NSLocalizedString(@"宽带密码不能大于128", @"")]
          setGravity:iToastGravityCenter] show:iToastTypeError];
        return;
    }
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    //,@"":@""
    NSDictionary *parameters = @{@"WANT1":@"3",@"GO": @"wan_connectd.asp",@"MTU":@"1492",@"rebootTag":@"",@"v12_time":@"",@"WANT2":@"",@"PCM":@"0",@"PIDL":@"60",@"":@"",@"PUN":pun,@"PPW":ppw};
    DLog(@"parameters = %@",parameters);
    NSString *routerDomain = [IPHelpler getGatewayIPAddress];
    NSString *url_adv_set_wan = [ud objectForKey:URL_ADVSET_WAN];
    [manager POST:[NSString stringWithFormat:@"%@%@",routerDomain,url_adv_set_wan] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *sChangeSSIDReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        DLog(@"url = %@,sChangeSSIDReturnCode = %@",[operation response].URL,sChangeSSIDReturnCode);
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *domain = [IPHelpler getGatewayIPAddress];
        NSString *url = [NSString stringWithFormat:@"%@/system_status.asp",domain];
        NSString *responseUrl = [NSString stringWithFormat:@"%@",[operation response].URL];
        if ([responseUrl isEqualToString:url]) {
            
            UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"网络已经设置为ADSL拨号上网的方式,请重新连接网络！！"] delegate:self cancelButtonTitle:[Config DPLocalizedString:@"sure"] otherButtonTitles:nil, nil];
            [alerView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"sChangeSSIDerror = %@",error);
        UIAlertView *alerView2 = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"设置失败"] delegate:self cancelButtonTitle:[Config DPLocalizedString:@"sure"] otherButtonTitles:nil, nil];
        [alerView2 show];
    }];
}

@end
