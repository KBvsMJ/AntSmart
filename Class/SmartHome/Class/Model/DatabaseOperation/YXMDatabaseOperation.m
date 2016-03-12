//
//  YXMDatabaseOperation.m
//  SmartHome
//
//  Created by iroboteer on 15/4/18.
//  Copyright (c) 2015年 antbang. All rights reserved.
//
// modify 新增保存推送通知数据到数据库的功能
// author 易兴满 date 2015年06月16日18:55:13
// savePushData:(YXMPushNotiModel *)data;

#import "YXMDatabaseOperation.h"
#import "FMDatabase.h"
#import "YXMDeviceEntity.h"
#import "YXMRouterEntity.h"
#import "YXMMacFilterObject.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "IPHelpler.h"
#import "YXMDeviceInfoModel.h"
#import "YXMTimerModel.h"
#import "YXMMyRouterModel.h"
#import "YXMPushNotiModel.h"
#import "MyTool.h"

@interface YXMDatabaseOperation ()
{
    FMDatabase *dataBase;
}
@end

@implementation YXMDatabaseOperation
+ (YXMDatabaseOperation *)sharedManager
{
    static YXMDatabaseOperation *sharedDatabaseManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedDatabaseManagerInstance = [[self alloc] init];
    });
    return sharedDatabaseManagerInstance;
}


-(BOOL)openDatabase{
    /*根据路径创建数据库和表*/
    NSArray * arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * path = [arr objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"AntbangDatabase.db"];

    dataBase = [FMDatabase databaseWithPath:path];
    [self createTable];
    
    return YES;
}

/**
 *  创建所有的数据库表
 */
-(void)createTable{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return;
    }
    //管理过的路由器的列表
    //路由器所在的局域网内设备列表
    NSMutableString *myRouterSqlString = [[NSMutableString alloc]initWithString:@"CREATE TABLE if not exists router_myself_table("];
    [myRouterSqlString appendString:@"mrouter_id TEXT(100) PRIMARY KEY NOT NULL,"];//路由器编号
    [myRouterSqlString appendString:@"mrouter_name TEXT(100) DEFAULT NULL,"];
    [myRouterSqlString appendString:@"mrouter_lan_ip TEXT(100) DEFAULT NULL,"];
    [myRouterSqlString appendString:@"mrouter_lan_mac TEXT(100) DEFAULT NULL,"];
    [myRouterSqlString appendString:@"mrouter_wan_mac TEXT(100) DEFAULT NULL,"];
    [myRouterSqlString appendString:@"mrouter_wan_ip TEXT(100) DEFAULT NULL,"];
    [myRouterSqlString appendString:@"mrouter_hardware_version TEXT(100) DEFAULT NULL,"];//路由器硬件版本
    [myRouterSqlString appendString:@"mrouter_software_version TEXT(100) DEFAULT NULL,"];//路由器软件版本
    [myRouterSqlString appendString:@"mrouter_lan_mask TEXT(100) DEFAULT NULL,"];//路由器子网掩码
    [myRouterSqlString appendString:@"mrouter_geteway TEXT(100) DEFAULT NULL,"];
    [myRouterSqlString appendString:@"mrouter_dns1 TEXT(100) DEFAULT NULL)"];//路由器dns
    [dataBase executeUpdate:myRouterSqlString];
    
    //路由器所在的局域网内设备列表
    NSMutableString *sqlString = [[NSMutableString alloc]initWithString:@"CREATE TABLE if not exists device_list_table("];
    [sqlString appendString:@"device_id TEXT(100) PRIMARY KEY NOT NULL,"];
    [sqlString appendString:@"device_name TEXT(100) DEFAULT NULL,"];
    [sqlString appendString:@"device_ip TEXT(100) DEFAULT NULL,"];
    [sqlString appendString:@"device_mac TEXT(100) DEFAULT NULL,"];
    [sqlString appendString:@"device_is_static TEXT(100) DEFAULT NULL,"];
    [sqlString appendString:@"device_is_period TEXT(100) DEFAULT NULL,"];
    [sqlString appendString:@"device_nickname TEXT(100) DEFAULT NULL,"];
    [sqlString appendString:@"device_online TEXT(100) DEFAULT NULL,"];
    [sqlString appendString:@"device_isself TEXT(100) DEFAULT NULL,"];
    [sqlString appendString:@"device_isdisable TEXT(100) DEFAULT NULL,"];
    [sqlString appendString:@"device_curNum TEXT(100) DEFAULT NULL,"];
    [sqlString appendString:@"device_group TEXT(100) DEFAULT NULL,"];
    [sqlString appendString:@"device_router_id TEXT(100) DEFAULT NULL)"];
    [dataBase executeUpdate:sqlString];
    
    //路由器附近wifi设备
    NSMutableString *sqlString2 = [[NSMutableString alloc]initWithString:@"CREATE TABLE if not exists near_wifi_list_table("];
    [sqlString2 appendString:@"wifi_id TEXT(100) PRIMARY KEY NOT NULL,"];
    [sqlString2 appendString:@"wifi_name TEXT(100) DEFAULT NULL,"];
    [sqlString2 appendString:@"wifi_mac TEXT(100) DEFAULT NULL,"];
    [sqlString2 appendString:@"wifi_channel TEXT(100) DEFAULT NULL,"];
    [sqlString2 appendString:@"wifi_encrypt TEXT(100) DEFAULT NULL,"];
    [sqlString2 appendString:@"wifi_dbm TEXT(100) DEFAULT NULL,"];
    [sqlString2 appendString:@"wifi_online TEXT(100) DEFAULT NULL,"];
    [sqlString2 appendString:@"wifi_is_be_repeater TEXT(100) DEFAULT NULL)"];
    [dataBase executeUpdate:sqlString2];
    
    //路由器mac地址过滤列表
    NSMutableString *sqlString3 = [[NSMutableString alloc]initWithString:@"CREATE TABLE if not exists filter_mac_list_table("];
    [sqlString3 appendString:@"filter_mac TEXT(100) PRIMARY KEY NOT NULL,"];
    [sqlString3 appendString:@"filter_week TEXT(100) DEFAULT NULL,"];
    [sqlString3 appendString:@"filter_date TEXT(100) DEFAULT NULL,"];
    [sqlString3 appendString:@"filter_enable TEXT(100) DEFAULT NULL,"];
    [sqlString3 appendString:@"filter_remark TEXT(100) DEFAULT NULL,"];
    [sqlString3 appendString:@"filter_channel TEXT(100) DEFAULT NULL)"];
    [dataBase executeUpdate:sqlString3];
    
    
    //手机已经配置成功的插座列表
    NSMutableString *sqlString4 = [[NSMutableString alloc]initWithString:@"CREATE TABLE if not exists device_plug_list_table("];
    [sqlString4 appendString:@"device_id TEXT(100) PRIMARY KEY NOT NULL,"];
    [sqlString4 appendString:@"device_head TEXT(100) DEFAULT NULL,"];
    [sqlString4 appendString:@"device_name TEXT(100) DEFAULT NULL,"];
    [sqlString4 appendString:@"device_state INTEGER(100) DEFAULT 0,"];
    [sqlString4 appendString:@"device_net_state INTEGER(100) DEFAULT 0,"];
    [sqlString4 appendString:@"device_show_power TEXT(100) DEFAULT NULL,"];
    [sqlString4 appendString:@"device_electricity TEXT(100) DEFAULT NULL,"];
    [sqlString4 appendString:@"device_open_time TEXT(100) DEFAULT NULL,"];
    [sqlString4 appendString:@"device_close_time TEXT(100) DEFAULT NULL,"];
    [sqlString4 appendString:@"device_lock TEXT(100) DEFAULT NULL,"];
    [sqlString4 appendString:@"device_mac_address TEXT(100) DEFAULT NULL,"];
    [sqlString4 appendString:@"device_local_ip TEXT(100) DEFAULT NULL,"];
    [sqlString4 appendString:@"device_last_updatetime INTEGER(100) DEFAULT 0,"];
    [sqlString4 appendString:@"device_selectIndex INTEGER(100) DEFAULT 0)"];
    [dataBase executeUpdate:sqlString4];
    
    //插座设备的定时器列表
    //需要设置定时器编号与定时器的mac地址双主键
    NSMutableString *sqlString5 = [[NSMutableString alloc]initWithString:@"CREATE TABLE if not exists device_plug_timer_table("];
    [sqlString5 appendString:@"timer_id TEXT(100) NOT NULL,"];
    [sqlString5 appendString:@"timer_period TEXT(100) DEFAULT NULL,"];
    [sqlString5 appendString:@"timer_name TEXT(100) DEFAULT NULL,"];
    [sqlString5 appendString:@"timer_start_hour TEXT(100) DEFAULT NULL,"];
    [sqlString5 appendString:@"timer_start_minutes TEXT(100) DEFAULT NULL,"];
    [sqlString5 appendString:@"timer_start_isuse TEXT(100) DEFAULT NULL,"];
    [sqlString5 appendString:@"timer_close_hour TEXT(100) DEFAULT NULL,"];
    [sqlString5 appendString:@"timer_close_minutes TEXT(100) DEFAULT NULL,"];
    [sqlString5 appendString:@"timer_close_isuse TEXT(100) DEFAULT NULL,"];
    [sqlString5 appendString:@"timer_isactive TEXT(100) DEFAULT NULL,"];
    [sqlString5 appendString:@"timer_of_device_mac TEXT(100) DEFAULT NULL,"];
    [sqlString5 appendString:@"timer_mark TEXT(100) DEFAULT NULL,"];
    [sqlString5 appendString:@"PRIMARY KEY(timer_id, timer_of_device_mac))"];
    [dataBase executeUpdate:sqlString5];
    
    
    //手机已经配置成功的插座列表
    NSMutableString *sqlString6 = [[NSMutableString alloc]initWithString:@"CREATE TABLE if not exists pushnoti_msg_table("];
    [sqlString6 appendString:@"pushNotiID TEXT(100) PRIMARY KEY NOT NULL,"];
    [sqlString6 appendString:@"pushNotiURL TEXT(100) DEFAULT NULL,"];
    [sqlString6 appendString:@"pushNotiTitle TEXT(100) DEFAULT NULL,"];
    [sqlString6 appendString:@"pushNoteReceiveDate TEXT(100) DEFAULT NULL,"];
    [sqlString6 appendString:@"pushNotiIsRead TEXT(100) DEFAULT 'NO')"];
    [dataBase executeUpdate:sqlString6];
}


-(BOOL)excuteSqlString:(NSString *)sqlString{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return NO;
    }
    return [dataBase executeUpdate:sqlString];
}

/**
 *  查询设备是否已经在本地存在
 *
 *  @param deviceid 设备的编号也就是mac地址
 *
 *  @return 返回是否查询到结果的布尔值
 */
-(BOOL)deviceExistWithDeviceID:(NSString *)deviceid{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return NO;
    }
    NSString *sqlString = [[NSString alloc]initWithFormat:@"select * from device_list_table where device_id = '%@'",deviceid];
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    
    return [selectResult next];
}

/**
 *  查询所有设备列表
 *
 *  @return 返回设备列表数组
 */
-(NSArray *)selectAllDeviceListWithRouterID:(NSString *)routerID{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return nil;
    }
    NSString *sqlString = [[NSString alloc]initWithFormat:@"select * from device_list_table where device_router_id = '%@'",routerID];
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    NSMutableArray *dataArray = [[NSMutableArray alloc]initWithCapacity:1];
    while ([selectResult next]) {
        YXMDeviceEntity *device = [[YXMDeviceEntity alloc]init];
        device.device_id = [selectResult stringForColumn:@"device_id"];
        device.device_name = [selectResult stringForColumn:@"device_name"];
        device.device_ip = [selectResult stringForColumn:@"device_ip"];
        device.device_mac = [selectResult stringForColumn:@"device_mac"];
        device.device_is_static = [selectResult stringForColumn:@"device_is_static"];
        device.device_is_period = [selectResult stringForColumn:@"device_is_period"];
        device.device_group = [selectResult stringForColumn:@"device_group"];
        device.device_nickname = [selectResult stringForColumn:@"device_nickname"];
        device.device_online = [selectResult stringForColumn:@"device_online"];
        device.device_isself = [selectResult stringForColumn:@"device_isself"];
        device.device_isdisable = [selectResult stringForColumn:@"device_isdisable"];
        device.device_curNum = [selectResult stringForColumn:@"device_curNum"];
        device.device_router_id = [selectResult stringForColumn:@"device_router_id"];
        [dataArray addObject:device];
    }
    return dataArray;
}

/**
 *  查询所有的wifi列表数据
 *
 *  @return 返回信息
 */
-(NSArray *)selectAllWiFiList{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return nil;
    }
    NSString *sqlString = @"select * from near_wifi_list_table";
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    NSMutableArray *dataArray = [[NSMutableArray alloc]initWithCapacity:1];
    while ([selectResult next]) {
        YXMRouterEntity *device = [[YXMRouterEntity alloc]init];
        device.wifi_id = [selectResult stringForColumn:@"wifi_id"];
        device.wifi_name = [selectResult stringForColumn:@"wifi_name"];
        device.wifi_mac = [selectResult stringForColumn:@"wifi_mac"];
        device.wifi_channel = [selectResult stringForColumn:@"wifi_channel"];
        device.wifi_encrypt = [selectResult stringForColumn:@"wifi_encrypt"];
        device.wifi_dbm = [selectResult stringForColumn:@"wifi_dbm"];
        device.wifi_online = [selectResult stringForColumn:@"wifi_online"];
        device.wifi_is_be_repeater = [selectResult stringForColumn:@"wifi_is_be_repeater"];
        [dataArray addObject:device];
    }
    return dataArray;
}


/**
 *  更新设备的别名
 *
 *  @param name     别名
 *  @param deviceid 设备编号也就是mac地址
 *
 *  @return 返回更新结果
 */
-(BOOL)updateDeviceNickname:(NSString *)name withId:(NSString *)deviceid{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return NO;
    }
    NSString *sqlString = [NSString stringWithFormat:@"update device_list_table set device_nickname='%@' where device_id='%@'",name,deviceid];
    return [dataBase executeUpdate:sqlString];
}
/**
 *  更新在线状态
 *
 *  @param state     设备在线状态
 *  @param deviceid  设备编号也就是mac地址
 *
 *  @return 返回更新结果
 */
-(BOOL)updateDeviceOnline:(NSString *)state withId:(NSString *)deviceid{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return NO;
    }
    NSString *sqlString = [NSString stringWithFormat:@"update device_list_table set device_online='%@' where device_id='%@'",state,deviceid];
    return [dataBase executeUpdate:sqlString];
}

/**
 *  查询已经被使用的过滤通道
 *
 *  @return 返回已经被使用的过滤通道集合
 */
-(NSSet *)isUsingCurNum{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return nil;
    }
    NSString *sqlString = @"select filter_channel from filter_mac_list_table";
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    NSMutableSet *dataSet = [[NSMutableSet alloc]initWithCapacity:1];
    while ([selectResult next]) {
        if ([selectResult stringForColumn:@"filter_channel"]) {
            [dataSet addObject:[selectResult stringForColumn:@"filter_channel"]];
        }
    }
    return dataSet;
}

/**
 *  通过mac地址去禁用设备上网
 *
 *  @param macAddress 设备的mac地址
 */
-(void)disableDeviceWithMacAddress:(NSString *)macAddress{
    NSInteger curNum = 1;
    NSSet *usingCurNumSet = [self isUsingCurNum];
    DLog(@"usingCurNumSet = %@",usingCurNumSet);
    if (usingCurNumSet) {
        NSArray *usingCurNumArray = [usingCurNumSet allObjects];
        NSArray *sortedUsingCurNumArray = [usingCurNumArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSComparisonResult result = [obj1 compare:obj2];
            
            return result == NSOrderedDescending; // 升序
            //        return result == NSOrderedAscending;  // 降序
        }];
        DLog(@"sortedUsingCurNumArray = %@",sortedUsingCurNumArray);
        curNum = [[sortedUsingCurNumArray lastObject] integerValue];
        if ([usingCurNumArray count]<1) {
            curNum = 1;
        }
        if (curNum==0) {
            curNum = 1;
        }
    }
    DLog(@"curNum = %d",curNum);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *routerDomain = [IPHelpler getGatewayIPAddress];
    NSMutableString *url_disable_device = [[NSMutableString alloc]initWithFormat:@"%@",[ud objectForKey:URL_DISABLE_DEVICE]];
    [url_disable_device appendFormat:@"?GO=firewall_mac.asp&"];
    [url_disable_device appendFormat:@"check=deny&"];
    [url_disable_device appendFormat:@"curNum=%d&",(int)curNum];
    [url_disable_device appendFormat:@"CL%d=%@,0-6,0-0,on,1",(int)curNum,macAddress];
    DLog(@"url_disable_device = %@",url_disable_device);

    [manager GET:[NSString stringWithFormat:@"%@%@",routerDomain,url_disable_device] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *sDisableDeviceReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        [self analysisFilterData:sDisableDeviceReturnCode];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:[NSString stringWithFormat:@"%@",[IPHelpler getGatewayIPAddress]] forKey:URL_ROUTER_DOMAIN];
    }];
}

/**
 *  通过设备的mac地址查询设备的ip地址
 *
 *  @param deviceID 设备mac地址
 *
 *  @return 设备ip地址
 */
-(NSString *)getDeviceIPWithDeviceID:(NSString *)deviceID{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return nil;
    }
    NSString *sqlString = [[NSString alloc]initWithFormat:@"select device_ip from device_list_table where device_id='%@'",deviceID];
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    while ([selectResult next]) {
        return [NSString stringWithFormat:@"%@",[selectResult stringForColumn:@"device_ip"]];
    }
    return nil;
}

/**
 *  通过mac地址获得mac过滤项的对象
 *
 *  @param macAddress mac地址
 */
-(YXMMacFilterObject *)getOneFileterWithMacAddress:(NSString *)macAddress{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return nil;
    }
    NSString *sqlString = [[NSString alloc]initWithFormat:@"select * from filter_mac_list_table where filter_mac='%@'",macAddress];
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    while ([selectResult next]) {
        YXMMacFilterObject *filter = [[YXMMacFilterObject alloc]init];
        filter.filter_mac = [selectResult stringForColumn:@"filter_mac"];
        filter.filter_week = [selectResult stringForColumn:@"filter_week"];
        filter.filter_date = [selectResult stringForColumn:@"filter_date"];
        filter.filter_enable = [selectResult stringForColumn:@"filter_enable"];
        filter.filter_remark = [selectResult stringForColumn:@"filter_remark"];
        filter.filter_channel = [selectResult stringForColumn:@"filter_channel"];
        return filter;
    }
    return nil;
}


/**
 *  解禁设备的mac地址过滤
 *
 *  @param macAddress mac地址
 *
 *  @return 是否成功解禁
 */
-(void)enableDeviceWithMacAddress:(NSString *)macAddress{
    YXMMacFilterObject *filter = [self getOneFileterWithMacAddress:macAddress];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *routerDomain = [IPHelpler getGatewayIPAddress];
    NSMutableString *url_enable_device = [[NSMutableString alloc]initWithFormat:@"%@",[ud objectForKey:URL_DISABLE_DEVICE]];
    [url_enable_device appendFormat:@"?GO=firewall_mac.asp&"];
    [url_enable_device appendFormat:@"check=deny&curNum=%@",filter.filter_channel];
    DLog(@"url_enable_device = %@",url_enable_device);
    
    [manager GET:[NSString stringWithFormat:@"%@%@",routerDomain,url_enable_device] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *sEnableDeviceReturnCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        DLog(@"sEnableDeviceReturnCode = %@",sEnableDeviceReturnCode);
        [self analysisFilterData:sEnableDeviceReturnCode];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_REFRESH_DEVICE_LIST object:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"url_enable_device: %@", error);
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:[NSString stringWithFormat:@"%@",[IPHelpler getGatewayIPAddress]] forKey:URL_ROUTER_DOMAIN];
    }];
}

/**
 *  根据通道去删除mac过滤项目
 *
 *  @param channel 通道数
 *
 *  @return 返回是否删除成功
 */
-(BOOL)deleteFilterWithChannel:(NSString *)channel{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return NO;
    }
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM filter_mac_list_table WHERE filter_channel='%@'",channel];
    return [dataBase executeUpdate:sqlString];
}

-(void)analysisFilterData:(NSString *)sDisableDeviceReturnCode{
    //需要判断是否成功设置mac地址过滤
    //从返回的数据中抓取已经设置成功的列表
    //过滤设置项的前缀集合
    NSArray *filterPrefixArray = [[NSArray alloc]initWithObjects:@"addCfg(\"ML1\",60,'",@"addCfg(\"ML2\",61,'",@"addCfg(\"ML3\",62,'",@"addCfg(\"ML4\",63,'",@"addCfg(\"ML5\",64,'",@"addCfg(\"ML6\",65,'",@"addCfg(\"ML7\",66,'",@"addCfg(\"ML8\",67,'",@"addCfg(\"ML9\",68,'",@"addCfg(\"ML10\",69,'", nil];
    NSMutableArray *filterDataArray = [[NSMutableArray alloc]init];
    NSInteger channl = 1;
    for (NSString *filterPrefix in filterPrefixArray) {
        NSString *filterDataString = nil;
        NSRange prefixRange = [sDisableDeviceReturnCode rangeOfString:filterPrefix];
        
        if (prefixRange.location!=NSNotFound) {
            NSString *subFilterString = [sDisableDeviceReturnCode substringFromIndex:prefixRange.location+prefixRange.length];
            NSRange subFilterSuffixRange = [subFilterString rangeOfString:@"');"];
            NSArray *oneFilterArray = nil;
            if (subFilterSuffixRange.location!=NSNotFound) {
                filterDataString = [subFilterString substringToIndex:subFilterSuffixRange.location];
                if (filterDataString) {
                    [filterDataArray addObject:filterDataString];
                }
                oneFilterArray = [filterDataString componentsSeparatedByString:@","];
            }
            
            
            if (oneFilterArray) {
                NSMutableString *insertFilterSQL = [[NSMutableString alloc]initWithFormat:@"replace into filter_mac_list_table(filter_mac,filter_week,filter_date,filter_enable,filter_remark,filter_channel) values("];
                
                for (int i=0; i<[oneFilterArray count]; i++) {
                    if (i+1==[oneFilterArray count]) {
                        [insertFilterSQL appendFormat:@"'%@','%d')",[oneFilterArray objectAtIndex:i],(int)channl];
                    }else{
                        [insertFilterSQL appendFormat:@"'%@',",[oneFilterArray objectAtIndex:i]];
                    }
                }
                DLog(@"insertFilterSQL = %@",insertFilterSQL);
                if ([oneFilterArray count]==5) {
                    [self excuteSqlString:insertFilterSQL];
                }
                
            }
        }
        if ([filterDataString length]<1) {
            [self deleteFilterWithChannel:[NSString stringWithFormat:@"%d",(int)channl]];
        }
        channl ++;
    }

}



/**
 *  存储插座设备信息到本地数据库中
 *
 *  @param model 插座数据对象
 */
-(BOOL)savePlugDeviceWithModelData:(YXMDeviceInfoModel *)model{
    
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return NO;
    }
//    [self deletePlugDataWithPlugMac:model.device_id];
    BOOL isInsertResult = NO;
    //判断是否已经存在，如果已经存在则插入，否则跳过
    NSString *selectDeviceSql = [[NSString alloc]initWithFormat:@"select device_id from device_plug_list_table where device_id = '%@'",model.device_id];
    FMResultSet *selectDeviceResult = [dataBase executeQuery:selectDeviceSql];
    BOOL isExistDevice = [selectDeviceResult next];
    if (!isExistDevice) {
        NSString *insertSqlString = [[NSString alloc]initWithFormat:@"insert into device_plug_list_table(device_id,device_state,device_net_state,device_show_power,device_electricity,device_lock,device_mac_address,device_local_ip,device_last_updatetime,device_selectIndex) values('%@',%d,%d,'%@','%@','%@','%@','%@',datetime('now','localtime'),%d)",model.device_id,(int)model.device_state,(int)model.device_net_state,model.device_show_power,model.device_electricity,model.device_lock,model.device_mac_address,model.device_local_ip,(int)model.device_selectIndex];
        //插座设备的定时器列表
        for (YXMTimerModel *timer in model.device_timerlist) {
            NSString *insertTimerSqlString = [[NSString alloc]initWithFormat:@"replace into device_plug_timer_table(timer_id,timer_period,timer_name,timer_start_hour,timer_start_minutes,timer_start_isuse,timer_close_hour,timer_close_minutes,timer_close_isuse,timer_isactive,timer_of_device_mac,timer_mark) values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%d','%@','%@')",timer.timer_id,timer.timer_period,timer.timer_name,timer.timer_start_hour,timer.timer_start_minutes,timer.timer_start_isuse,timer.timer_close_hour,timer.timer_close_minutes,timer.timer_close_isuse,timer.timer_isactive,timer.timer_of_device_mac,timer.timer_mark];
            [self excuteSqlString:insertTimerSqlString];
        }
        isInsertResult = [self excuteSqlString:insertSqlString];
    }
    return isInsertResult;
}

/**
 *  通过插座的mac地址去删除数据库里的插座数据
 *
 *  @param plugMac 插座的mac地址
 */
-(BOOL)deletePlugDataWithPlugMac:(NSString *)plugMac{
    if (!plugMac) {
        return NO;
    }
    //删除插座数据库中的记录
    NSString *deleSqlString = [[NSString alloc]initWithFormat:@"DELETE FROM device_plug_list_table WHERE device_id='%@'",plugMac];
    //删除定时器数据库中的记录
    NSString *deleTimerSqlString = [[NSString alloc]initWithFormat:@"DELETE FROM device_plug_timer_table WHERE timer_of_device_mac='%@'",plugMac];
    return [self excuteSqlString:deleSqlString]&&[self excuteSqlString:deleTimerSqlString];
}


/**
 *  更新或者插入定时器数据
 *
 *  @param timer 定时器对象
 *
 *  @return 是否更新数据成功
 */
-(BOOL)replaceOrInsertTimerWithData:(YXMTimerModel *)timer{
    NSString *sqlString2 = [[NSString alloc]initWithFormat:@"insert into device_plug_timer_table(timer_id,timer_period,timer_name,timer_start_hour,timer_start_minutes,timer_start_isuse,timer_close_hour,timer_close_minutes,timer_close_isuse,timer_isactive,timer_of_device_mac,timer_mark) values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%d','%@','%@')",timer.timer_id,timer.timer_period,timer.timer_name,timer.timer_start_hour,timer.timer_start_minutes,timer.timer_start_isuse,timer.timer_close_hour,timer.timer_close_minutes,timer.timer_close_isuse,timer.timer_isactive,timer.timer_of_device_mac,timer.timer_mark];
    DLog(@"sqlString2 = %@",sqlString2);
    return [self excuteSqlString:sqlString2];
}

/**
 *  通过插座的mac地址和定时器编号去删除数据库里的插座的定时数据
 *
 *  @param plugMac 插座的mac地址
 */
-(BOOL)deleteTimerDataWithPlugMac:(NSString *)timerid andMac:(NSString *)pmac{
    if (!timerid) {
        return NO;
    }
    //删除定时器数据库中的记录
    NSString *deleTimerSqlString = [[NSString alloc]initWithFormat:@"DELETE FROM device_plug_timer_table WHERE pmactimer_of_device_mac='%@' and timer_id='%@'",pmac,timerid];
    return [self excuteSqlString:deleTimerSqlString];
}

/**
 *  查询本地以及配置的所有插座数据
 *
 *  @return 插座数据集
 */
-(NSArray*)readAllPlugData{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return nil;
    }
    NSMutableArray *dataOfPlugArray = [[NSMutableArray alloc]init];
    NSString *sqlString = @"select device_id,device_head,device_name,device_state,device_net_state,device_mac_address,device_show_power,device_electricity,device_open_time,device_close_time,device_lock,device_local_ip,device_last_updatetime,device_selectIndex from device_plug_list_table";
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    while ([selectResult next]) {
        YXMDeviceInfoModel *plug = [[YXMDeviceInfoModel alloc]init];
        plug.device_id = [selectResult stringForColumn:@"device_id"];
        plug.device_head = [selectResult stringForColumn:@"device_head"];
        plug.device_name = [selectResult stringForColumn:@"device_name"];
        plug.device_state = [selectResult intForColumn:@"device_state"];//设备的电源状态
        plug.device_net_state = [selectResult intForColumn:@"device_net_state"];//设备的网络状态
        plug.device_mac_address = [selectResult stringForColumn:@"device_mac_address"];
        plug.device_show_power = [selectResult stringForColumn:@"device_show_power"];
        plug.device_electricity = [selectResult stringForColumn:@"device_electricity"];
        plug.device_open_time = [selectResult stringForColumn:@"device_open_time"];
        plug.device_close_time = [selectResult stringForColumn:@"device_close_time"];
        plug.device_lock = [selectResult stringForColumn:@"device_lock"];
        plug.device_local_ip = [selectResult stringForColumn:@"device_local_ip"];
        plug.device_last_updatetime = [self myDateFromString:[selectResult stringForColumn:@"device_last_updatetime"]];
        plug.device_selectIndex = [selectResult intForColumn:@"device_selectIndex"];//分段选择按钮被选择的索引
        plug.device_timerlist = [[NSMutableArray alloc]init];
        
        NSString *timerSqlString = @"select * from device_plug_timer_table";
        FMResultSet *selectTimerResult = [dataBase executeQuery:timerSqlString];
        while ([selectTimerResult next]) {
            YXMTimerModel *timer = [[YXMTimerModel alloc]init];
            timer.timer_id = [selectTimerResult stringForColumn:@"timer_id"];
            timer.timer_period = [selectTimerResult stringForColumn:@"timer_period"];
            timer.timer_name = [selectTimerResult stringForColumn:@"timer_name"];
            timer.timer_start_hour = [selectTimerResult stringForColumn:@"timer_start_hour"];
            timer.timer_start_minutes = [selectTimerResult stringForColumn:@"timer_start_minutes"];
            timer.timer_start_isuse = [selectTimerResult stringForColumn:@"timer_start_isuse"];
            timer.timer_close_hour = [selectTimerResult stringForColumn:@"timer_close_hour"];
            timer.timer_close_minutes = [selectTimerResult stringForColumn:@"timer_close_minutes"];
            timer.timer_close_isuse = [selectTimerResult stringForColumn:@"timer_close_isuse"];
            timer.timer_isactive = [[selectTimerResult stringForColumn:@"timer_isactive"] boolValue];
            timer.timer_of_device_mac = [selectTimerResult stringForColumn:@"timer_of_device_mac"];
            timer.timer_mark = [selectTimerResult stringForColumn:@"timer_mark"];
            [plug.device_timerlist addObject:timer];
        }
        
        [dataOfPlugArray addObject:plug];
    }
    return dataOfPlugArray;
}

/**
 *  更新插座设备的别名
 *
 *  @param deviceMac 通过设备的mac地址去判断
 */
-(BOOL)updateSmartDeviceNickname:(NSString*)deviceName WithDeviceMac:(NSString *)deviceMac{
    NSString *updateSqlString = [NSString stringWithFormat:@"update device_plug_list_table set device_name='%@' where device_id='%@'",deviceName,deviceMac];
    DLog(@"updateSqlString = %@",updateSqlString);
    return [self excuteSqlString:updateSqlString];
}

/**
 *  设置所有设备为离线状态
 */
-(BOOL)setAllDeviceNetStateWithOffline{
    NSString *updateSqlString = [NSString stringWithFormat:@"update device_plug_list_table set device_net_state=%d",(int)EnumDeviceNetStateLocalOffline];
    DLog(@"updateSqlString = %@",updateSqlString);
    return [self excuteSqlString:updateSqlString];
}

-(BOOL)updateDeviceNetStateWithNowDate{
    NSString *updateNetStateSqlString = [NSString stringWithFormat:@"update device_plug_list_table set device_net_state=%d where device_last_updatetime<%@",(int)EnumDeviceNetStateLocalOffline,[NSDate date]];
    DLog(@"updateNetStateSqlString %@",updateNetStateSqlString);
    return [self excuteSqlString:updateNetStateSqlString];
}

/**
 *  从时间字符串转换为NSDate对象
 *
 *  @param dateString 时间字符串 2015-05-16 14:41:37
 *
 *  @return NSDate对象
 */
-(NSDate *)myDateFromString:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate = [dateFormatter dateFromString:dateString];
    return destDate;
}

/**
 *  更新设备电源状态
 *
 *  @param data 设备数据对象
 *
 *  @return 更新成功与否
 */
-(BOOL)updatedevicePowerState:(YXMDeviceInfoModel *)data{
    NSString *updatePowerSql = [NSString stringWithFormat:@"update device_plug_list_table set device_state=%d where device_id='%@'",(int)data.device_state,data.device_id];
    DTLog(@"updatePowerSql %@",updatePowerSql);
    return [self excuteSqlString:updatePowerSql];
}

/**
 *  读取已经添加的设备的数量
 *
 *  @return 设备数量
 */
-(NSInteger)readDeviceCount{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return 0;
    }
    NSString *countSqlString = @"select count(*) as deviceCount from device_plug_list_table";
    NSInteger deviceCount = 0;
    FMResultSet *selectResult = [dataBase executeQuery:countSqlString];
    while ([selectResult next]) {
        deviceCount = [selectResult intForColumn:@"deviceCount"];
    }
    return deviceCount;
}


/**
 *  通过设备的mac地址查询数据库中是否有此设备了
 *
 *  @param macAddress mac地址
 *
 *  @return 返回是否查询到了
 */
-(BOOL)findDataWithDeviceMac:(NSString *)macAddress{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return NO;
    }
    BOOL findRes = NO;
    NSString *selectSqlString = [NSString stringWithFormat:@"select device_id from device_plug_list_table where device_id='%@'",macAddress];
    FMResultSet *selectResult = [dataBase executeQuery:selectSqlString];
    while ([selectResult next]) {
        findRes = YES;
    }
    return findRes;
}


/**
 *  使用设备的mac与ip去判断数据是否存在,如果不存在，则证明设备的ip地址已经做了更改了，需要更新设备的ip地址
 *
 *  @param ipAddress  设备的ip地址
 *  @param macAddress 设备的mac地址
 *
 *  @return 返回是否查询到数据
 */
-(BOOL)findDataWithDeviceIPAndMac:(NSString *)ipAddress andMac:(NSString *)macAddress{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return NO;
    }
    BOOL findRes = NO;
    NSString *selectSqlString = [NSString stringWithFormat:@"select device_id from device_plug_list_table where device_id='%@' and device_local_ip='%@'",macAddress,ipAddress];
    FMResultSet *selectResult = [dataBase executeQuery:selectSqlString];
    while ([selectResult next]) {
        findRes = YES;
    }
    return findRes;
}


/**
 *  根据设备的mac地址去更新设备的ip地址
 *
 *  @param ipAddress  设备的ip地址
 *  @param macAddress 设备的mac地址
 *
 *  @return 更新是否成功的返回值
 */
-(BOOL)updateDeviceLocalIP:(NSString *)ipAddress andMacAddress:(NSString *)macAddress{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return NO;
    }
    NSString *updatePowerSql = [NSString stringWithFormat:@"update device_plug_list_table set device_local_ip='%@' where device_id='%@'",ipAddress,macAddress];
    return [self excuteSqlString:updatePowerSql];
}



/**
 *  更新设备信息到数据库
 *
 *  @param model 设备数据对象
 *
 *  @return 返回是否更新成功
 */
-(BOOL)updateDeviceInfoWithObj:(YXMDeviceInfoModel *)model{
    NSString *updateDeviceSql = [[NSString alloc]initWithFormat:@"update device_plug_list_table set device_state=%d,device_net_state=%d,device_show_power='%@',device_electricity='%@',device_lock='%@',device_local_ip='%@',device_last_updatetime=datetime('now','localtime'),device_selectIndex=%d where device_id='%@'",(int)model.device_state,(int)model.device_net_state,model.device_show_power,model.device_electricity,model.device_lock,model.device_local_ip,(int)model.device_selectIndex,model.device_id];
    [dataBase executeUpdate:updateDeviceSql];
    //插座设备的定时器列表
    for (YXMTimerModel *timer in model.device_timerlist) {
        NSString *updateTimerSql = [[NSString alloc]initWithFormat:@"update device_plug_timer_table set timer_period='%@',timer_start_hour='%@',timer_start_minutes='%@',timer_start_isuse='%@',timer_close_hour='%@',timer_close_minutes='%@',timer_close_isuse='%@',timer_isactive='%d',timer_mark='%@' where timer_id='%@' and timer_of_device_mac='%@'",timer.timer_period,timer.timer_start_hour,timer.timer_start_minutes,timer.timer_start_isuse,timer.timer_close_hour,timer.timer_close_minutes,timer.timer_close_isuse,timer.timer_isactive,timer.timer_mark,timer.timer_id,timer.timer_of_device_mac];
        [dataBase executeUpdate:updateTimerSql];
    }

    return YES;
}


/**
 *  根据设备的mac地址去查询数据库中的设备信息
 *
 *  @param deviceid 设备的mac地址
 *
 *  @return 设备的信息对象
 */
-(YXMDeviceInfoModel *)readOneDeviceInfoWithDeviceID:(NSString *)deviceid{
    NSString *sqlString = @"select device_id,device_head,device_name,device_state,device_net_state,device_mac_address,device_show_power,device_electricity,device_open_time,device_close_time,device_lock,device_local_ip,device_last_updatetime,device_selectIndex from device_plug_list_table";
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    YXMDeviceInfoModel *plug = nil;
    while ([selectResult next]) {
        plug = [[YXMDeviceInfoModel alloc]init];
        plug.device_id = [selectResult stringForColumn:@"device_id"];
        plug.device_head = [selectResult stringForColumn:@"device_head"];
        plug.device_name = [selectResult stringForColumn:@"device_name"];
        plug.device_state = [selectResult intForColumn:@"device_state"];//设备的电源状态
        plug.device_net_state = [selectResult intForColumn:@"device_net_state"];//设备的网络状态
        plug.device_mac_address = [selectResult stringForColumn:@"device_mac_address"];
        plug.device_show_power = [selectResult stringForColumn:@"device_show_power"];
        plug.device_electricity = [selectResult stringForColumn:@"device_electricity"];
        plug.device_open_time = [selectResult stringForColumn:@"device_open_time"];
        plug.device_close_time = [selectResult stringForColumn:@"device_close_time"];
        plug.device_lock = [selectResult stringForColumn:@"device_lock"];
        plug.device_local_ip = [selectResult stringForColumn:@"device_local_ip"];
        plug.device_last_updatetime = [self myDateFromString:[selectResult stringForColumn:@"device_last_updatetime"]];
        plug.device_selectIndex = [selectResult intForColumn:@"device_selectIndex"];//分段选择按钮被选择的索引
        plug.device_timerlist = [[NSMutableArray alloc]init];
        
        NSString *timerSqlString = @"select * from device_plug_timer_table";
        FMResultSet *selectTimerResult = [dataBase executeQuery:timerSqlString];
        while ([selectTimerResult next]) {
            YXMTimerModel *timer = [[YXMTimerModel alloc]init];
            timer.timer_id = [selectTimerResult stringForColumn:@"timer_id"];
            timer.timer_period = [selectTimerResult stringForColumn:@"timer_period"];
            timer.timer_name = [selectTimerResult stringForColumn:@"timer_name"];
            timer.timer_start_hour = [selectTimerResult stringForColumn:@"timer_start_hour"];
            timer.timer_start_minutes = [selectTimerResult stringForColumn:@"timer_start_minutes"];
            timer.timer_start_isuse = [selectTimerResult stringForColumn:@"timer_start_isuse"];
            timer.timer_close_hour = [selectTimerResult stringForColumn:@"timer_close_hour"];
            timer.timer_close_minutes = [selectTimerResult stringForColumn:@"timer_close_minutes"];
            timer.timer_close_isuse = [selectTimerResult stringForColumn:@"timer_close_isuse"];
            timer.timer_isactive = [[selectTimerResult stringForColumn:@"timer_isactive"] boolValue];
            timer.timer_of_device_mac = [selectTimerResult stringForColumn:@"timer_of_device_mac"];
            timer.timer_mark = [selectTimerResult stringForColumn:@"timer_mark"];
            [plug.device_timerlist addObject:timer];
        }
    }
    return plug;
}



/**
 *  保存管理过的路由器的信息到数据库
 *
 *  @param routerObj 路由器对象
 *
 *  @return 返回是否保存成功
 */
-(BOOL)saveMyRouterWithObj:(YXMMyRouterModel *)model{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return NO;
    }

    BOOL isInsertResult = NO;
    //判断是否已经存在，如果已经存在则插入，否则跳过
    NSString *selectDeviceSql = [[NSString alloc]initWithFormat:@"select mrouter_id from router_myself_table where mrouter_id = '%@'",model.mrouter_id];
    FMResultSet *selectDeviceResult = [dataBase executeQuery:selectDeviceSql];
    BOOL isExistDevice = [selectDeviceResult next];
    if (!isExistDevice) {
        NSString *insertSqlString = [[NSString alloc]initWithFormat:@"insert into router_myself_table(mrouter_id,mrouter_name,mrouter_lan_ip,mrouter_lan_mac,mrouter_wan_mac,mrouter_wan_ip,mrouter_hardware_version,mrouter_software_version,mrouter_lan_mask,mrouter_geteway,mrouter_dns1) values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",model.mrouter_id,model.mrouter_name,model.mrouter_lan_ip,model.mrouter_lan_mac,model.mrouter_wan_mac,model.mrouter_wan_ip,model.mrouter_hardware_version,model.mrouter_software_version,model.mrouter_lan_mask,model.mrouter_geteway,model.mrouter_dns1];
        isInsertResult = [self excuteSqlString:insertSqlString];
    }
    return isInsertResult;
}


#pragma mark -推送通知相关


/**
 *  保存推送过来的数据
 *
 *  @param model 推送消息数据
 *
 *  @return 是否保存成功
 */
-(BOOL)savePushData:(YXMPushNotiModel *)model{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return NO;
    }
    
    BOOL isInsertResult = NO;
    //判断是否已经存在，如果已经存在则插入，否则跳过
    NSString *selectDeviceSql = [[NSString alloc]initWithFormat:@"select pushNotiTitle from pushnoti_msg_table where pushNotiID = '%@'",model.pushNotiID];
    FMResultSet *selectDeviceResult = [dataBase executeQuery:selectDeviceSql];
    BOOL isExistDevice = [selectDeviceResult next];
    if (!isExistDevice) {
        NSString *insertSqlString = [[NSString alloc]initWithFormat:@"insert into pushnoti_msg_table(pushNotiID,pushNotiTitle,pushNotiIsRead,pushNotiURL,pushNoteReceiveDate) values('%@','%@','%@','%@','%@')",model.pushNotiID,model.pushNotiTitle,model.pushNotiIsRead,model.pushNotiURL,[MyTool stringFromDate:model.pushNoteReceiveDate]];
        isInsertResult = [self excuteSqlString:insertSqlString];
    }
    
    return isInsertResult;
}

/**
 *  查询本地存储的所有推送通知
 *
 *  @return 返回的推送通知对象数组
 */
-(NSArray *)selectAllPushMsgData{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return nil;
    }
    NSString *sqlString = @"select * from pushnoti_msg_table";
    FMResultSet *selectResult = [dataBase executeQuery:sqlString];
    NSMutableArray *dataArray = [[NSMutableArray alloc]initWithCapacity:1];
    while ([selectResult next]) {
        YXMPushNotiModel *model = [[YXMPushNotiModel alloc]init];
        model.pushNotiID = [selectResult stringForColumn:@"pushNotiID"];
        model.pushNotiTitle = [selectResult stringForColumn:@"pushNotiTitle"];
        model.pushNotiURL = [selectResult stringForColumn:@"pushNotiURL"];
        model.pushNoteReceiveDate = [self myDateFromString:[selectResult stringForColumn:@"pushNoteReceiveDate"]];
        model.pushNotiIsRead = [selectResult stringForColumn:@"pushNotiIsRead"];
        [dataArray addObject:model];
    }
    return dataArray;
}


/**
 *  通过推送消息的id去删除本地数据
 *
 *  @param 推送消息的id
 *
 *  @return 返回是否删除成功
 */
-(BOOL)deletePushMsgWithMsgID:(NSString *)msgid{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return NO;
    }
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM pushnoti_msg_table WHERE pushNotiID='%@'",msgid];
    return [dataBase executeUpdate:sqlString];
}


/**
 *  更新推送通知的阅读状态为已经阅读
 *
 *  @param msgid 推送通知的编号
 *
 *  @return 是否更新成功
 */
-(BOOL)updatePushDataToReadWithPushMsgID:(NSString *)msgid{
    if (![dataBase open]) {
        DLog(@"can not open dataBase!");
        return NO;
    }
    NSString *updatePowerSql = [NSString stringWithFormat:@"update pushnoti_msg_table set pushNotiIsRead='YES' where pushNotiID='%@'",msgid];
    return [self excuteSqlString:updatePowerSql];
}
@end
