//
//  YXMMacFilterObject.h
//  SmartHome
//
//  Created by iroboteer on 15/4/25.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YXMMacFilterObject : NSObject
@property (atomic,strong) NSString *filter_mac;
@property (atomic,strong) NSString *filter_week;
@property (atomic,strong) NSString *filter_date;
@property (atomic,strong) NSString *filter_enable;
@property (atomic,strong) NSString *filter_remark;
@property (atomic,strong) NSString *filter_channel;
@end
