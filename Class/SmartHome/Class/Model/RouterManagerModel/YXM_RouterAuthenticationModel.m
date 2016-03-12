//
//  YXM_RouterAuthenticationModel.m
//  SmartHome
//
//  Created by iroboteer on 15/4/16.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXM_RouterAuthenticationModel.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "MyTool.h"
#import "IPHelpler.h"

@implementation YXM_RouterAuthenticationModel
+ (YXM_RouterAuthenticationModel *)sharedManager
{
    static YXM_RouterAuthenticationModel *sharedRouterAuthManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedRouterAuthManagerInstance = [[self alloc] init];
    });
    return sharedRouterAuthManagerInstance;
}

-(void)loginRouter{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *pwdString = [ud objectForKey:KEY_OF_ROUTER_PASSWORD];
    if ([pwdString length]<1) {
        pwdString = @"";
    }
    NSDictionary *parameters = @{@"Username":@"admin",@"checkEn": @"0",@"Password":pwdString};
    
    NSString *routerDomain = [IPHelpler getGatewayIPAddress];
    NSString *url_login_router = [ud objectForKey:URL_LOGIN_ROUTER];
    [manager POST:[NSString stringWithFormat:@"%@%@",routerDomain,url_login_router] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *sLoginRouterReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        DLog(@"sLoginRouterReturnCode: %@", sLoginRouterReturnCode);
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if ([sLoginRouterReturnCode rangeOfString:@"ssid000 ="].location != NSNotFound) {

            NSString *ssidString = [MyTool getSSIDWithString:sLoginRouterReturnCode];
            [ud setObject:ssidString forKey:KEY_ROUTER_SSID];
            //wifi密码
            NSString *pwdString = [MyTool getWIFIPassword:sLoginRouterReturnCode];
            [ud setObject:pwdString forKey:KEY_OF_WIFI_PASSWORD];
            [ud setBool:YES forKey:KEY_OF_ISLOGIN];
        }else{
            [ud setBool:NO forKey:KEY_OF_ISLOGIN];
        }
        
        if ([sLoginRouterReturnCode rangeOfString:KEY_LOGIN_ERROR].location != NSNotFound) {
            [ud setObject:@"未连接" forKey:NET_CONNECT_STATE];
        }else{
            [ud setObject:@"已连接" forKey:NET_CONNECT_STATE];
        }
        
        [ud synchronize];
        
        //通知UI更新状态
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_LOGIN_ROUTER_STATE_CHANGE object:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Error: %@", error);
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setBool:NO forKey:KEY_OF_ISLOGIN];
        [ud setObject:@"未连接" forKey:NET_CONNECT_STATE];
    }];
}
@end
