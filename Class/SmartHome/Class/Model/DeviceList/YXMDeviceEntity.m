//
//  YXMDeviceEntity.m
//  SmartHome
//  连接到路由器的终端设备
//  Created by iroboteer on 15/4/18.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMDeviceEntity.h"

@implementation YXMDeviceEntity
-(NSString *)description{
    return [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@",self.device_id,self.device_ip,self.device_mac,self.device_online,self.device_name,self.device_nickname,self.device_isdisable,self.device_isself,self.device_curNum];
}
@end
