//
//  ProjectItemCell
//  LEDAD
//  项目列表的Cell
//  Created by yixingman on 8/21/14.
//  Copyright (c) 2014 yixingman. All rights reserved.
//
//
//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YXMNetChannelDataObjet.h"



@interface ProjectItemCell : UITableViewCell
{
    //通道名称
    UILabel *_projectNameLabel;
    //当前通道内的路由器数量
    UILabel *_numberOfDeviceLabel;
    
    YXMNetChannelDataObjet *_channelObject;

    NSIndexPath *_myCheckBoxOfIndexPath;
    
    //当前选择的通道
    UIImageView *audioIndicatorView;
}

@property (nonatomic,strong) YXMNetChannelDataObjet *channelObject;

-(UIView*)getCellView;
+(CGFloat)projectItemCellHeight;
@end
