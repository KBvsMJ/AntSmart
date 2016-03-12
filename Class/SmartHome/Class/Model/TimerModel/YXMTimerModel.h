//
//  YXMTimerModel.h
//  SmartHome
//  插座定时器对象
//  Created by iroboteer on 15/3/23.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YXMTimerModel : NSObject
//定时器的编号
@property (strong,nonatomic) NSString *timer_id;
//定时的周期（ 开关的周期，将十进制数转换为2进制，每一位表示一个星期中对应的那一天;）
@property (strong,nonatomic) NSString *timer_period;
//定时器的名称
@property (strong,nonatomic) NSString *timer_name;
//开启的小时
@property (strong,nonatomic) NSString *timer_start_hour;
//开启的分钟
@property (strong,nonatomic) NSString *timer_start_minutes;
//开启时间是否启用
@property (strong,nonatomic) NSString *timer_start_isuse;

//关闭的小时
@property (strong,nonatomic) NSString *timer_close_hour;
//关闭的分钟
@property (strong,nonatomic) NSString *timer_close_minutes;
//关闭时间是否启用
@property (strong,nonatomic) NSString *timer_close_isuse;
//定时器是否启用
@property BOOL timer_isactive;
//插座的mac地址
@property (strong,nonatomic) NSString *timer_of_device_mac;
//定时器的说明
@property (strong,nonatomic) NSString *timer_mark;
@end
