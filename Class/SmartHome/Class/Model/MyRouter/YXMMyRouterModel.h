//
//  YXMMyRouterModel.h
//  管理过的路由器的数据对象
//
//  Created by iroboteer on 6/3/15.
//  Copyright (c) 2015 iroboteer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YXMMyRouterModel : NSObject
/**
 *  路由器的编号，由路由器的lan口的mac产生
 */
@property (nonatomic,strong) NSString *mrouter_id;
/**
 *  路由器的名称
 */
@property (nonatomic,strong) NSString *mrouter_name;
/**
 *  路由器的LAN口的IP
 */
@property (nonatomic,strong) NSString *mrouter_lan_ip;
/**
 *  路由器LAN口的mac
 */
@property (nonatomic,strong) NSString *mrouter_lan_mac;
/**
 *  路由器的WAN口mac
 */
@property (nonatomic,strong) NSString *mrouter_wan_mac;
/**
 *  路由器的WAN口ip
 */
@property (nonatomic,strong) NSString *mrouter_wan_ip;
/**
 *  路由器的硬件版本
 */
@property (nonatomic,strong) NSString *mrouter_hardware_version;
/**
 *  路由器的软件版本
 */
@property (nonatomic,strong) NSString *mrouter_software_version;
/**
 *  路由器的掩码
 */
@property (nonatomic,strong) NSString *mrouter_lan_mask;
/**
 *  备用dns
 */
@property (nonatomic,strong) NSString *mrouter_dns1;
/**
 *  路由器的网关地址
 */
@property (nonatomic,strong) NSString *mrouter_geteway;
-(NSString *)description;
@end
