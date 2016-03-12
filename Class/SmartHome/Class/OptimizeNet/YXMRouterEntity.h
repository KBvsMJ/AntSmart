//
//  YXMRouterEntity.h
//  SmartHome
//
//  Created by iroboteer on 15/4/20.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YXMRouterEntity : NSObject
@property (atomic,strong) NSString *wifi_id;
@property (atomic,strong) NSString *wifi_name;
@property (atomic,strong) NSString *wifi_mac;
@property (atomic,strong) NSString *wifi_channel;
@property (atomic,strong) NSString *wifi_encrypt;
@property (atomic,strong) NSString *wifi_dbm;
@property (atomic,strong) NSString *wifi_online;
@property (atomic,strong) NSString *wifi_is_be_repeater;
@end
