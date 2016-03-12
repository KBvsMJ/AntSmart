//
//  YXMTimerTableViewCell.m
//  SmartHome
//
//  Created by iroboteer on 15/3/22.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMTimerTableViewCell.h"


@implementation YXMTimerTableViewCell
@synthesize data = _data;

-(YXMTimerModel *)data{
    return _data;
}

-(void)setData:(YXMTimerModel *)data{
    if (data) {
        if (data!=_data) {
            _data = data;
            [_timerIsOpenSwitch setOn:data.timer_isactive];
            [_timerNameLabel setText:[NSString stringWithFormat:@"%@",data.timer_name]];
            [_timerPeriodLabel setText:[NSString stringWithFormat:@"%@",[self periodToLocalString:data.timer_period]]];
            
            [_timerStartTimeLabel setText:[NSString stringWithFormat:@"开启 %@:%@",data.timer_start_hour,data.timer_start_minutes]];
            
            [_timerEndTimeLabel setText:[NSString stringWithFormat:@"关闭 %@:%@",data.timer_close_hour,data.timer_close_minutes]];
        }
    }
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:[self createCellView]];
    }
    return self;
}


/**
 *  初始化cell的视图
 */
-(UIView *)createCellView{
    UIView *cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_CGSIZE_WIDTH-30, 80.0)];
    //定时器的名称
    _timerNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(cellView.frame.size.width/10, 10, cellView.frame.size.width/2, 30)];
    [_timerNameLabel setBackgroundColor:[UIColor clearColor]];
    [_timerNameLabel setFont:[UIFont systemFontOfSize:12]];
    [_timerNameLabel setText:@""];
    [cellView addSubview:_timerNameLabel];
    
    //定时器的周期
    _timerPeriodLabel = [[UILabel alloc]initWithFrame:CGRectMake(cellView.frame.size.width/10, _timerNameLabel.frame.size.height + _timerNameLabel.frame.origin.y, cellView.frame.size.width/2, 30)];
    [_timerPeriodLabel setBackgroundColor:[UIColor clearColor]];
    [_timerPeriodLabel setFont:[UIFont systemFontOfSize:12]];
    [_timerPeriodLabel setText:@""];
    [cellView addSubview:_timerPeriodLabel];
    
    //开始时间
    _timerStartTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(cellView.frame.size.width/2, 10, cellView.frame.size.width/4, 30)];
    [_timerStartTimeLabel setBackgroundColor:[UIColor clearColor]];
    [_timerStartTimeLabel setFont:[UIFont systemFontOfSize:12]];
    [_timerStartTimeLabel setText:@""];
    [cellView addSubview:_timerStartTimeLabel];
    //结束时间
    _timerEndTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(cellView.frame.size.width/2, _timerStartTimeLabel.frame.size.height + _timerStartTimeLabel.frame.origin.y, cellView.frame.size.width/4, 30)];
    [_timerEndTimeLabel setBackgroundColor:[UIColor clearColor]];
    [_timerEndTimeLabel setFont:[UIFont systemFontOfSize:12]];
    [_timerEndTimeLabel setText:@""];
    [cellView addSubview:_timerEndTimeLabel];
    //是否激活开关
    _timerIsOpenSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(cellView.frame.size.width/4+cellView.frame.size.width/2, cellView.frame.size.height/3, cellView.frame.size.width/4, cellView.frame.size.height/3)];
    [_timerIsOpenSwitch setOn:YES];
    [_timerIsOpenSwitch addTarget:self action:@selector(updateSwitchState:) forControlEvents:UIControlEventTouchUpInside];
    [cellView addSubview:_timerIsOpenSwitch];
    //设置文本的颜色为蓝色
    [self setLabelTextColor:YES];
    
    UIImageView *tableViewCellSeparatorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, cellView.frame.size.height-2, SCREEN_CGSIZE_WIDTH, 2)];
    [tableViewCellSeparatorImageView setImage:[UIImage imageNamed:@"tableViewCell_bkground_points_line.png"]];
    [cellView addSubview:tableViewCellSeparatorImageView];
    
    return cellView;
}

/**
 *  定时器是否激活
 *
 *  @param sender 激活开关
 */
-(void)updateSwitchState:(UISwitch *)sender{
    [_data setTimer_isactive:sender.on];
    [self setLabelTextColor:sender.on];
}

/**
 *  处于激活状态的定时项目的颜色为蓝色
 *
 *  @param isBlue 是否为蓝色
 */
-(void)setLabelTextColor:(BOOL)isBlue{
    UIColor *textColor = nil;
    if (isBlue) {
        textColor = [UIColor blueColor];
    }else{
        textColor = [UIColor grayColor];
    }
    [_timerNameLabel setTextColor:textColor];
    [_timerPeriodLabel setTextColor:textColor];
    [_timerStartTimeLabel  setTextColor:textColor];
    [_timerEndTimeLabel setTextColor:textColor];
}

/**
 *  将周期数据转换为周期本地字符串
 *
 *  @param period 周期数据
 *
 *  @return 周期的本地字符串
 */
-(NSString *)periodToLocalString:(NSString *)period{
    NSMutableString *localString = [[NSMutableString alloc]init];
    if (period) {
        if ([period isKindOfClass:[NSString class]]) {
            NSArray *periodArray = [period componentsSeparatedByString:@","];
            NSInteger index = 0;
            for (NSString *oneDay in periodArray) {
                switch ([oneDay integerValue]) {
                    case 0:
                    {
                        [localString appendString:@"一"];
                    }
                        break;
                    case 1:
                    {
                        [localString appendString:@"二"];
                    }
                        break;
                    case 2:
                    {
                        [localString appendString:@"三"];
                    }
                        break;
                    case 3:
                    {
                        [localString appendString:@"四"];
                    }
                        break;
                    case 4:
                    {
                        [localString appendString:@"五"];
                    }
                        break;
                    case 5:
                    {
                        [localString appendString:@"六"];
                    }
                        break;
                    case 6:
                    {
                        [localString appendString:@"日"];
                    }
                        break;
                    case 7:
                    {
                        [localString appendString:@"单次"];
                    }
                        break;
                    default:
                        break;
                }
                
                if ((index!=([periodArray count]-1))) {
                    [localString appendString:@","];
                }
                index ++;
            }
        }
    }
    return localString;
}
@end
