//
//  YXMDeviceListModel.h
//  SmartHome
//
//  Created by iroboteer on 15/4/17.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^GetDeviceList)(NSArray *deviceListArray);
@interface YXMDeviceListModel : NSObject
+ (YXMDeviceListModel *)sharedManager;
-(void)deviceList:(GetDeviceList)blockDeviceListArray;
@end
