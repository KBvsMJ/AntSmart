//
//  YXMDeviceIPInfo.h
//  SmartHome
//
//  Created by iroboteer on 15/4/17.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPHelpler : NSObject
+ (NSString *)localIP;
+ (NSString *)getGatewayIPAddress;
+ (NSString *) getDeviceSSID;
@end
