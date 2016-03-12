//
//  YXMWiFiSetupViewController.h
//  SmartHome
//
//  Created by iroboteer on 15/4/8.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <STAlertView/STAlertView.h>

@interface YXMWiFiSetupViewController : UIViewController<UITextFieldDelegate>
@property (atomic,strong) STAlertView *stAlertView;

@property (atomic,strong) STAlertView *stAlertView2;
@end
