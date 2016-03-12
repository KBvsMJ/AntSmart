//
//  ForgetPwdViewController.m
//  Project_Aidu
//
//  Created by macmini_01 on 15-1-29.
//  Copyright (c) 2015年 Vooda. All rights reserved.
//

#import "ForgetPwdViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "SectionsViewController.h"

#import <SMS_SDK/SMS_SDK.h>
#import <SMS_SDK/CountryAndAreaCode.h>

@interface ForgetPwdViewController ()
{
    CountryAndAreaCode* _data2;
    NSString* _str;
    NSMutableData* _data;
    int _state;
    NSString* _localPhoneNumber;
    
    NSString* _localZoneNumber;
    NSString* _appKey;
    NSString* _duid;
    NSString* _token;
    NSString* _appSecret;
    
    NSMutableArray* _areaArray;
    NSString* _defaultCode;
    NSString* _defaultCountryName;
    
    NSString* _phone;
    NSString* _areaCode;
}
@end

@implementation ForgetPwdViewController
@synthesize fetcherDic;
#pragma mark - SecondViewControllerDelegate的方法
- (void)setSecondData:(CountryAndAreaCode *)data
{
    _data2=data;
    NSLog(@"the area data：%@,%@", data.areaCode,data.countryName);
    
    self.areaCodeField.text=[NSString stringWithFormat:@"+%@",data.areaCode];
    [self.tableView reloadData];
}
//收键盘
-(void)closeTextField
{
    [txtPhoneNumber resignFirstResponder];
    [txtPassWord resignFirstResponder];
    [txtPhoneCode resignFirstResponder];
    [txtNewPwd resignFirstResponder];
    [txtOldWord resignFirstResponder];
    
    viewBackground.frame = CGRectMake(0, 0, SCREEN_CGSIZE_WIDTH, SCREEN_CGSIZE_HEIGHT);
    
}
//关闭键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self closeTextField];
    
}
#pragma mark UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == txtPassWord) {
        viewBackground.frame = CGRectMake(0, -80, SCREEN_CGSIZE_WIDTH, SCREEN_CGSIZE_HEIGHT);
    }
    else if(textField == txtPhoneCode)
    {
        viewBackground.frame = CGRectMake(0, -40, SCREEN_CGSIZE_WIDTH, SCREEN_CGSIZE_HEIGHT);
    }else if (textField == txtNewPwd)
    {
        viewBackground.frame = CGRectMake(0, -120, SCREEN_CGSIZE_WIDTH, SCREEN_CGSIZE_HEIGHT);
    }else if (textField == txtOldWord)
    {
        viewBackground.frame = CGRectMake(0, -80, SCREEN_CGSIZE_WIDTH, SCREEN_CGSIZE_HEIGHT);
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self closeTextField];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"找回密码";
    txtPassWord.secureTextEntry = YES;
    txtNewPwd.secureTextEntry = YES;
    txtOldWord.secureTextEntry = YES;
    
    secondTime = 0;
    
    CGFloat statusBarHeight=0;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        statusBarHeight=20;
    }
    UILabel* label=[[UILabel alloc] init];
    label.frame=CGRectMake(15, 56+statusBarHeight, self.view.frame.size.width - 30, 50);
    label.text=[NSString stringWithFormat:NSLocalizedString(@"labelnotice", nil)];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Helvetica" size:16];
    label.textColor=[UIColor darkGrayColor];
    [viewBackground addSubview:label];
    
    UITableView* tableView=[[UITableView alloc] initWithFrame:CGRectMake(10, 106+statusBarHeight, self.view.frame.size.width - 20, 45) style:UITableViewStylePlain];
    [viewBackground addSubview:tableView];
    
    //区域码
    UITextField* areaCodeField=[[UITextField alloc] init];
    areaCodeField.frame=CGRectMake(10, 155+statusBarHeight, (self.view.frame.size.width - 30)/4, 40+statusBarHeight/4);
    areaCodeField.borderStyle=UITextBorderStyleBezel;
    areaCodeField.text=[NSString stringWithFormat:@"+86"];
    areaCodeField.textAlignment=NSTextAlignmentCenter;
    areaCodeField.font=[UIFont fontWithName:@"Helvetica" size:18];
    areaCodeField.keyboardType=UIKeyboardTypePhonePad;
    [areaCodeField setHidden:YES];
    [viewBackground addSubview:areaCodeField];
    _areaCodeField = areaCodeField;
    _tableView = tableView;
    
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.areaCodeField.delegate=self;
    txtPhoneNumber.delegate=self;
    
    _areaArray= [NSMutableArray array];
    
    //设置本地区号
    [self setTheLocalAreaCode];
    //获取支持的地区列表
    [SMS_SDK getZone:^(enum SMS_ResponseState state, NSArray *array)
     {
         if (1==state)
         {
             NSLog(@"sucessfully get the area code");
             //区号数据
             _areaArray=[NSMutableArray arrayWithArray:array];
         }
         else if (0==state)
         {
             NSLog(@"failed to get the area code");
         }
         
     }];
    
    //添加倒计时的Label
    lblTime = [[UILabel alloc] initWithFrame:CGRectMake(215, 208, 98, 40)];
    imgTime = [[UIImageView alloc] initWithFrame:CGRectMake(215, 208, 98, 40)];
    imgTime.image = [UIImage imageNamed:@"Regitser_btn_getCode.png"];
    [viewBackground addSubview:imgTime];
    [viewBackground addSubview:lblTime];
    lblTime.adjustsFontSizeToFitWidth = YES;
    lblTime.font = [UIFont systemFontOfSize:13.0f];
    lblTime.textAlignment = NSTextAlignmentCenter;
    lblTime.textColor = [UIColor whiteColor];
    lblTime.hidden = YES;
    imgTime.hidden = YES;
    

    UIImageView *s = (UIImageView *)txtPassWord.superview;
    [txtPassWord.superview setFrame:CGRectMake(s.frame.origin.x, s.frame.origin.y, s.frame.size.width+(SCREEN_CGSIZE_WIDTH-320), s.frame.size.height)];
}
- (void)changTimeAction
{
    secondTime--;
    lblTime.text = [NSString stringWithFormat:NSLocalizedString(@"重新发送(%d)",nil),secondTime];
    if (secondTime == 0) {
        lblTime.hidden = YES;
        imgTime.hidden = YES;
        btnGetPhoneCode.hidden = NO;
        if ([spackTimer isValid]) {
            [spackTimer invalidate];
            spackTimer = nil;
        }
    }
}
//获得手机验证码
- (IBAction)cmd_btn_getCode:(id)sender
{
    [self nextStep];
}
//确定
- (IBAction)cmd_btn_register:(id)sender
{
    [self submit];
}
- (IBAction)cmd_btn_back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)nextStep
{
    int compareResult = 0;
    for (int i=0; i<_areaArray.count; i++)
    {
        NSDictionary* dict1=[_areaArray objectAtIndex:i];
        NSString* code1=[dict1 valueForKey:@"zone"];
        if ([code1 isEqualToString:[_areaCodeField.text stringByReplacingOccurrencesOfString:@"+" withString:@""]])
        {
            compareResult=1;
            NSString* rule1=[dict1 valueForKey:@"rule"];
            NSPredicate* pred=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",rule1];
            BOOL isMatch=[pred evaluateWithObject:txtPhoneNumber.text];
            if (!isMatch)
            {
                //手机号码不正确
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                              message:NSLocalizedString(@"errorphonenumber", nil)
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                    otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            break;
        }
    }
    
    if (!compareResult)
    {
        if (txtPhoneNumber.text.length!=11)
        {
            //手机号码不正确
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                          message:NSLocalizedString(@"errorphonenumber", nil)
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    
    NSString* str=[NSString stringWithFormat:@"%@:%@ %@",NSLocalizedString(@"willsendthecodeto", nil),self.areaCodeField.text,txtPhoneNumber.text];
    _str=[NSString stringWithFormat:@"%@",txtPhoneNumber.text];
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"surephonenumber", nil)
                                                  message:str delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                        otherButtonTitles:NSLocalizedString(@"sure", nil), nil];
    [alert show];
}




-(void)setTheLocalAreaCode
{
    NSLocale *locale = [NSLocale currentLocale];
    
    NSDictionary *dictCodes = [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
                               @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                               @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                               @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                               @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                               @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                               @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                               @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                               @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                               @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                               @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                               @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                               @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                               @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                               @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                               @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                               @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                               @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                               @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                               @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                               @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                               @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                               @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                               @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                               @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                               @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                               @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                               @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                               @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                               @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                               @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                               @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                               @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                               @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                               @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                               @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                               @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                               @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                               @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                               @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                               @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                               @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                               @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                               @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                               @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                               @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                               @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                               @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                               @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                               @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                               @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                               @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                               @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                               @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                               @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                               @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                               @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                               @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                               @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                               @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                               @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
    
    NSString* tt=[locale objectForKey:NSLocaleCountryCode];
    NSString* defaultCode=[dictCodes objectForKey:tt];
    _areaCodeField.text=[NSString stringWithFormat:@"+%@",defaultCode];
    
    NSString* defaultCountryName=[locale displayNameForKey:NSLocaleCountryCode value:tt];
    _defaultCode=defaultCode;
    _defaultCountryName=defaultCountryName;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] ;
        
    }
    cell.textLabel.text=NSLocalizedString(@"countrylable", nil);
    cell.textLabel.textColor=[UIColor darkGrayColor];
    
    if (_data2)
    {
        cell.detailTextLabel.text=_data2.countryName;
    }
    else
    {
        cell.detailTextLabel.text=_defaultCountryName;
    }
    cell.detailTextLabel.textColor=[UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIView *tempView = [[UIView alloc] init];
    [cell setBackgroundView:tempView];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SectionsViewController* country2=[[SectionsViewController alloc] init];
    country2.delegate=self;
    [country2 setAreaArray:_areaArray];
    [self presentViewController:country2 animated:YES completion:^{
        ;
    }];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1==buttonIndex)
    {
        VerifyViewController* verify=[[VerifyViewController alloc] init];
        NSString* str2=[self.areaCodeField.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        [verify setPhone:txtPhoneNumber.text AndAreaCode:str2];
        
        [SMS_SDK getVerificationCodeBySMSWithPhone:txtPhoneNumber.text
                                              zone:str2
                                            result:^(SMS_SDKError *error)
         {
             if (!error)
             {
                 UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"codesendprompt", nil)
                                                               message:NSLocalizedString(@"codesendsuccess", nil)
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                     otherButtonTitles:nil, nil];
                 [alert show];
             }
             else
             {
                 UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"codesenderrtitle", nil)
                                                               message:[NSString stringWithFormat:@"状态码：%zi ,错误描述：%@",error.errorCode,error.errorDescription]
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                     otherButtonTitles:nil, nil];
                 [alert show];
             }
             
         }];
    }
}

-(void)submit
{
    //验证号码
    //验证成功后 获取通讯录 上传通讯录
    [self.view endEditing:YES];
    if (txtOldWord.text.length<6) {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                      message:NSLocalizedString(@"passwordlengthnotlessthansix", nil)
                                                     delegate:self
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (txtPassWord.text.length<6) {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                      message:NSLocalizedString(@"passwordlengthnotlessthansix", nil)
                                                     delegate:self
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if(txtPhoneCode.text.length!=4)
    {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                      message:NSLocalizedString(@"verifycodeformaterror", nil)
                                                     delegate:self
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else
    {
        //[[SMS_SDK sharedInstance] commitVerifyCode:self.verifyCodeField.text];
        [SMS_SDK enableAppContactFriends:NO];
        [SMS_SDK commitVerifyCode:txtPhoneCode.text result:^(enum SMS_ResponseState state) {
            if (1==state)
            {
                NSLog(@"验证成功");
                //                NSString* str=[NSString stringWithFormat:NSLocalizedString(@"verifycoderightmsg", nil)];
                //                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"verifycoderighttitle", nil)
                //                                                              message:str
                //                                                             delegate:self
                //                                                    cancelButtonTitle:NSLocalizedString(@"sure", nil)
                //                                                    otherButtonTitles:nil, nil];
                //                [alert show];
                //                _alert3=alert;
                //                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                //                                                              message:NSLocalizedString(@"regsuccess", nil)
                //                                                             delegate:self
                //                                                    cancelButtonTitle:NSLocalizedString(@"sure", nil)
                //                                                    otherButtonTitles:nil, nil];
                //                [alert show];
                [self regInfoSubmit];
            }
            else if(0==state)
            {
                NSLog(@"验证失败");
                NSString* str=[NSString stringWithFormat:NSLocalizedString(@"verifycodeerrormsg", nil)];
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"verifycodeerrortitle", nil)
                                                              message:str
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                    otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
        }];
    }
    
    
}


/**
 *  修改用户密码
 *  
 1:更新成功
 0:没有做任何修改
 -1:旧密码不正确
 -4:Email 格式有误
 -5:Email 不允许注册
 -6:该 Email 已经被注册
 -7:没有做任何修改
 -8:该用户受保护无权限更改
 */
-(void)regInfoSubmit{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = @{@"username": txtPhoneNumber.text,@"oldpassword": txtOldWord.text,@"newpassword": txtNewPwd.text};
    [manager POST:[NSString stringWithFormat:@"%@/usermanager.php?act=forget",URL_DOMAIN] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *sRegReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"sRegReturnCode: %@", sRegReturnCode);
        NSString *echo = @"";
        NSInteger iRegReturnCode = [sRegReturnCode integerValue];
        switch (iRegReturnCode) {
            case 0:
            {
                echo = @"密码未修改";
            }
                break;
            case 1:
            {
                echo = @"密码更新成功,请重新登陆！";
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud removeObjectForKey:@"uid"];
                [ud removeObjectForKey:@"username"];
                //返回到登陆页面
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
            case -1:
            {
                echo = @"旧密码错误";
            }
                
            default:
                break;
        }
        
        if (iRegReturnCode<1) {
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"loginreturninfotitle", nil)
                                                          message:echo
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                otherButtonTitles:nil, nil];
            [alert show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

@end
