//
//  YXMTrafficStatistics.m
//  SmartHome
//
//  Created by iroboteer on 15/4/16.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMTrafficStatistics.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "Config.h"
#import "IPHelpler.h"

@implementation YXMTrafficStatistics
/**
 *  获得路由器外网的速度
 */
-(void)getNetworkSpeed{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *routerDomain = [IPHelpler getGatewayIPAddress];
    NSString *url_get_net_speed = [ud objectForKey:URL_GET_NET_SPEED];
    [manager GET:[NSString stringWithFormat:@"%@%@",routerDomain,url_get_net_speed] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *sGetNetworkReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if ([sGetNetworkReturnCode rangeOfString:KEY_LOGIN_ERROR].location != NSNotFound) {
            [ud setBool:NO forKey:KEY_OF_ISLOGIN];
            return;
        }else{
            [ud setBool:YES forKey:KEY_OF_ISLOGIN];
        }
        
        NSArray *netspeedArray = [sGetNetworkReturnCode componentsSeparatedByString:@"\n"];

        float totalNetSpeed = 0.0f;
        for (NSString *oneDeviceSpeed in netspeedArray) {
            NSArray *oneDeviceSpeedArray = [oneDeviceSpeed componentsSeparatedByString:@";"];
            if ([oneDeviceSpeedArray count]>2) {
                totalNetSpeed += [[oneDeviceSpeedArray objectAtIndex:2] floatValue];
            }
        }
        NSDictionary *netSpeedDict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithFloat:totalNetSpeed],@"totalNetSpeed", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_UPDATE_NET_SPEED object:nil userInfo:netSpeedDict];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if (totalNetSpeed>0) {
            [ud setBool:YES forKey:KEY_OF_ISLOGIN];
        }else{
            [ud setBool:NO forKey:KEY_OF_ISLOGIN];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:[NSString stringWithFormat:@"%@",[IPHelpler getGatewayIPAddress]] forKey:URL_ROUTER_DOMAIN];
    }];

}
@end
