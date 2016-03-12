//
//  YXMOptimizeNetViewController.h
//  SmartHome
//
//  Created by iroboteer on 15/4/4.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
//#import "BTRippleButtton.h"
//#import <QuartzCore/QuartzCore.h>
#import "ProjectItemCell.h"
#import "YXMBaseViewController.h"


@interface YXMOptimizeNetViewController : YXMBaseViewController<UITableViewDelegate,UITableViewDataSource>
{
    UIButton *rippleButton1;
    BOOL isRun;
    NSMutableArray *_channelDataArr;
    NSTimer *timer1;
    NSMutableDictionary *_wifiBaseInfoDict;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *nearWiFiListArray;
@end
