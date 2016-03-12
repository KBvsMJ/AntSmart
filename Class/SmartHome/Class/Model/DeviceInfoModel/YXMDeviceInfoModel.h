//
//  YXMDeviceInfoModel.h
//  SmartHome
//  插座设备
//  Created by iroboteer on 15/3/16.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

/**
 设备的网络状态
 */
typedef enum : NSUInteger {
    EnumDeviceNetStateLocalOnline = 0,
    EnumDeviceNetStateLocalOffline,
    EnumDeviceNetStateRemoteOnline,
} EnumDeviceNetState;

/**
 设备的电源状态
 */
typedef enum : NSUInteger {
    EnumDevicePowerStateClose = 0,
    EnumDevicePowerStateOpen
} EnumDevicePowerState;

@interface YXMDeviceInfoModel : NSObject
//设备编号
@property (strong,nonatomic) NSString *device_id;
//设备头像
@property (strong,nonatomic) NSString *device_head;
//设备名称
@property (strong,nonatomic) NSString *device_name;
//设备的状态
@property (nonatomic) NSInteger device_state;
//设备网络状态
@property (nonatomic) NSInteger device_net_state;
//设备MAC地址
@property (strong,nonatomic) NSString *device_mac_address;
//实时功率
@property (strong,nonatomic) NSString *device_show_power;
//耗电量
@property (strong,nonatomic) NSString *device_electricity;
//打开电源的时间
@property (strong,nonatomic) NSString *device_open_time;
//关闭电源的时间
@property (strong,nonatomic) NSString *device_close_time;
//设备是否锁定
@property (strong,nonatomic) NSString *device_lock;
//定时控制列表
@property (strong,nonatomic) NSMutableArray *device_timerlist;
//分段选择按钮的索引
@property (nonatomic) NSInteger device_selectIndex;
//设备的局域网ip地址
@property (strong,nonatomic) NSString *device_local_ip;
//最后更新的时间
@property (strong,nonatomic) NSDate *device_last_updatetime;
//网络对象
@property (strong,nonatomic) AsyncSocket *device_socket;
//设备类型Type 设备类型 0插座 NSInteger
@property (nonatomic) NSInteger device_type;
//控制过设备的总人数
@property (nonatomic) NSInteger device_TotalNumber;
//当前有权限控制设备的人数
@property (nonatomic) NSInteger device_Authority;
@end
