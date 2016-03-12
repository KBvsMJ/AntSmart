//
//  smartConfig.h
//  smartConfig
//
//  Created by sunrun on 14-8-27.
//  Copyright (c) 2014年 sunrun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface smartConfig : NSObject

- (void)StopSmartConfig;
- (void)StartSmartConfigSetSSID:(NSString *)ssid andSetPassWord:(NSString *)password;
@end
