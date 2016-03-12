//
//  YXMTimerTableViewCell.h
//  SmartHome
//
//  Created by iroboteer on 15/3/22.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXMTimerModel.h"


@interface YXMTimerTableViewCell : UITableViewCell
{
    UILabel *_timerNameLabel;
    UILabel *_timerPeriodLabel;
    UILabel *_timerStartTimeLabel;
    UILabel *_timerEndTimeLabel;
    UISwitch *_timerIsOpenSwitch;
    
    YXMTimerModel *_data;
}

@property (strong,nonatomic) YXMTimerModel *data;
@end
