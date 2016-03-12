//
//  YXMDeviceEntity.h
//  SmartHome
//  连接到路由器的终端设备
//  Created by iroboteer on 15/4/18.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YXMDeviceEntity : NSObject
@property (atomic,strong) NSString *device_id;
@property (atomic,strong) NSString *device_name;
@property (atomic,strong) NSString *device_ip;
@property (atomic,strong) NSString *device_mac;
@property (atomic,strong) NSString *device_is_static;
@property (atomic,strong) NSString *device_is_period;
@property (atomic,strong) NSString *device_group;
@property (atomic,strong) NSString *device_nickname;
@property (atomic,strong) NSString *device_online;
@property (atomic,strong) NSString *device_isself;//是否是本机设备
@property (atomic,strong) NSString *device_isdisable;//是否被禁用
@property (atomic,strong) NSString *device_curNum;//使用哪个通道禁用此设备的
@property (atomic,strong) NSString *device_router_id;//设备在哪个路由器下面
@end
