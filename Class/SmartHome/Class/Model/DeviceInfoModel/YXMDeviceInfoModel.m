//
//  YXMDeviceInfoModel.m
//  SmartHome
//  插座设备
//  Created by iroboteer on 15/3/16.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMDeviceInfoModel.h"

@implementation YXMDeviceInfoModel
-(NSString *)description{
    return [NSString stringWithFormat:@"%@,%@,%@,%d,%@,%d,%@,%@,%@,%@,%@,%@,%@,%@,%@",self.device_id,self.device_head,self.device_name,(int)self.device_state,self.device_name,(int)self.device_net_state,self.device_mac_address,self.device_show_power,self.device_electricity,self.device_open_time,self.device_close_time,self.device_lock,self.device_timerlist,self.device_local_ip,self.device_last_updatetime];
}
@end
