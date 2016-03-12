//
//  YXMOptimizeTableViewCell.h
//  SmartHome
//
//  Created by iroboteer on 15/4/26.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YXMOptimizeTableViewCell : UITableViewCell
{
    UILabel *channelLabel;//通道编号
    UILabel *devieNumberLabel;//通道内的设备数量
}

-(UIView *)getCellView;
@end
