//
//  YXMSpeedAdjustmentViewController.h
//  SmartHome
//
//  Created by iroboteer on 15/4/4.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "SEFilterControl.h"

@interface YXMSpeedAdjustmentViewController : UIViewController<UIAlertViewDelegate>
{
    NSMutableDictionary *_wifiBaseInfoDict;
    SEFilterControl *_filter;
    //当前想要调整到的功率值
    NSInteger iwl_power;
}
@end
