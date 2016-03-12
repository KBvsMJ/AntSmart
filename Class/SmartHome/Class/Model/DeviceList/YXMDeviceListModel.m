//
//  YXMDeviceListModel.m
//  SmartHome
//
//  Created by iroboteer on 15/4/17.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMDeviceListModel.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "Config.h"
#import "IPHelpler.h"
#import "YXMDatabaseOperation.h"
#import "YXMDeviceEntity.h"


@implementation YXMDeviceListModel
+ (YXMDeviceListModel *)sharedManager
{
    static YXMDeviceListModel *sharedDeviceListInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedDeviceListInstance = [[self alloc] init];
    });
    return sharedDeviceListInstance;
}

-(void)deviceList:(GetDeviceList)blockDeviceListArray{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *routerDomain = [IPHelpler getGatewayIPAddress];
    NSString *url_dhcp_list = [ud objectForKey:URL_DHCP_LIST];
    [manager GET:[NSString stringWithFormat:@"%@%@",routerDomain,url_dhcp_list] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *sRegReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        //1、搜索dhcpList=new Array(
        NSRange range1 = [sRegReturnCode rangeOfString:@"dhcpList=new Array("];
        if (range1.location!=NSNotFound) {
            NSInteger range1Index = range1.location + range1.length;
            NSString *subString1 = [sRegReturnCode substringFromIndex:range1Index];
            //2、搜索),
            NSRange range2 = [subString1 rangeOfString:@"),"];
            NSInteger range2Index = range2.location;
            NSString *subString2 = [subString1 substringToIndex:range2Index];
            //按照','分解
            NSArray *deviceOriangeListArray = [subString2 componentsSeparatedByString:@"','"];
            //        DLog(@"%@",deviceOriangeListArray);
            NSMutableArray *onlineArray = [[NSMutableArray alloc]init];
            YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
            [db openDatabase];
            for (int i=0; i<[deviceOriangeListArray count]; i++) {
                NSString *device = [deviceOriangeListArray objectAtIndex:i];
                if ([device length]>1) {
                    if (i==0) {
                        device = [device substringFromIndex:1];
                    }
                    if (i==[deviceOriangeListArray count]-1) {
                        device = [device substringWithRange:NSMakeRange(0, [device length]-1)];
                    }
                    
                    /**
                     *  分解设备列表数据
                     */
                    NSArray *deviceElementArray = [device componentsSeparatedByString:@";"];
                    if (deviceElementArray) {
                        if ([deviceElementArray count]>1) {
                            NSString *device_id = [[NSString alloc]initWithFormat:@"%@",[deviceElementArray objectAtIndex:2]];
                            if ([db deviceExistWithDeviceID:device_id]) {
                                //如果数据库已经存在则更新在线状态
                                NSString *updateString = [[NSString alloc]initWithFormat:@"update device_list_table set device_online = '%@',device_ip = '%@' where device_id = '%@'",@"YES",[deviceElementArray objectAtIndex:1],device_id];
                                BOOL updateResult = [db excuteSqlString:updateString];
                                if (updateResult) {
                                    DLog(@"更新数据成功");
                                }else{
                                    DLog(@"更新数据失败");
                                }
                            }else{
                                //如果不是新设备则不存储
                                NSMutableString *insertSqlString = [[NSMutableString alloc]initWithString:@"insert into device_list_table(device_id,device_name,device_ip,device_mac,device_is_static,device_is_period,device_router_id,device_online) values("];
                                for (int j=0; j<[deviceElementArray count]; j++) {
                                    if (j==0) {
                                        [insertSqlString appendFormat:@"'%@','%@',",device_id,[deviceElementArray objectAtIndex:0]];
                                        [onlineArray addObject:device_id];
                                    }else{
                                        [insertSqlString appendFormat:@"'%@',",[deviceElementArray objectAtIndex:j]];
                                    }
                                    
                                }
                                
                                [insertSqlString appendFormat:@"'%@','%@')",[[NSUserDefaults standardUserDefaults] objectForKey:@"lan_mac"],@"YES"];
                                DTLog(@"sql = %@",insertSqlString);
                                BOOL insertResult = [db excuteSqlString:insertSqlString];
                                if (insertResult) {
                                    DLog(@"插入数据成功");
                                }else{
                                    DLog(@"插入数据失败");
                                }
                            }
                        }
                    }
                }
            }
            
            
            NSArray *dataSourceArray = [db selectAllDeviceListWithRouterID:[[NSUserDefaults standardUserDefaults] objectForKey:@"lan_mac"]];
            DLog(@"onlineArray = %@,dataSourceArray = %@",onlineArray,dataSourceArray);
            for (YXMDeviceEntity *deviceEntity in dataSourceArray) {
                if ([onlineArray indexOfObject:deviceEntity.device_id]==NSNotFound) {
                    [db updateDeviceOnline:@"NO" withId:deviceEntity.device_id];
                }else{
                    [db updateDeviceOnline:@"YES" withId:deviceEntity.device_id];
                }
            }
            blockDeviceListArray(dataSourceArray);
            
            
            [ud setBool:YES forKey:KEY_OF_ISLOGIN];
        }else{
            [ud setBool:NO forKey:KEY_OF_ISLOGIN];
            [ud setObject:[NSString stringWithFormat:@"%@",[IPHelpler getGatewayIPAddress]] forKey:URL_ROUTER_DOMAIN];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:[NSString stringWithFormat:@"%@",[IPHelpler getGatewayIPAddress]] forKey:URL_ROUTER_DOMAIN];
    }];
}
@end
