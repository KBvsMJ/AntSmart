//
//  YXMTimerModel.m
//  SmartHome
//
//  Created by iroboteer on 15/3/23.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMTimerModel.h"

@implementation YXMTimerModel
-(NSString *)description{
    return [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%d,%@,%@",self.timer_id,self.timer_period,self.timer_name,self.timer_start_hour,self.timer_start_minutes,self.timer_start_isuse,self.timer_close_hour,self.timer_close_minutes,self.timer_close_isuse,self.timer_isactive,self.timer_of_device_mac,self.timer_mark];
}
@end
