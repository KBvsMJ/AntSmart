//
//  YXMWiFiSwitchViewController.h
//  SmartHome
//
//  Created by iroboteer on 15/6/25.
//  Copyright (c) 2015年 iroboteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXMBaseViewController.h"

@interface YXMWiFiSwitchViewController : YXMBaseViewController <UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_switchTableView;
}
@end
