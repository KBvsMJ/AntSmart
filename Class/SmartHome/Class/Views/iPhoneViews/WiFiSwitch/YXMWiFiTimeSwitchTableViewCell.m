//
//  YXMWiFiTimeSwitchTableViewCell.m
//  SmartHome
//
//  Created by iroboteer on 15/6/25.
//  Copyright (c) 2015年 iroboteer. All rights reserved.
//

#import "YXMWiFiTimeSwitchTableViewCell.h"
#import <BFPaperButton.h>
#import "UIColor+BFPaperColors.h"

//定时器开始时间按钮
#define TAG_START_TIME_BUTTON 10010
//时间选择器
#define TAG_DATE_PICKER 10020
//开始时间是否启用的开关
#define TAG_START_TIME_SWITCH 10030
//结束时间按钮
#define TAG_END_TIME_BUTTON 100040
//结束时间开关
#define TAG_END_TIME_SWITCH 100050
//周期选择按钮的周一,从周一到单次，依次加1
#define TAG_WEEK_BUTTON 100060
@implementation YXMWiFiTimeSwitchTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *cellView = [self getCellView];
        [self.contentView addSubview:cellView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+(CGFloat)getCellWidth{
    return SCREEN_CGSIZE_WIDTH;
}

+(CGFloat)getCellHeight{
    return 200.0f;
}

-(UIView *)getCellView{
    UIView *addTimerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [YXMWiFiTimeSwitchTableViewCell getCellWidth], [YXMWiFiTimeSwitchTableViewCell getCellHeight])];
    //开始时间
    UILabel *startTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, addTimerView.frame.size.width/3, 44)];
    [startTimeLabel setBackgroundColor:[UIColor clearColor]];
    [startTimeLabel setFont:[UIFont systemFontOfSize:18]];
    [startTimeLabel setText:@"开启时间"];
    [addTimerView addSubview:startTimeLabel];
    //开始时间显示和设置按钮
    BFPaperButton *startTimeButton = [[BFPaperButton alloc] initWithFrame:CGRectMake(startTimeLabel.frame.size.width+startTimeLabel.frame.origin.x, startTimeLabel.frame.origin.y, addTimerView.frame.size.width/3, 44) raised:NO];
    [startTimeButton setTitleFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.f]];
    [startTimeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [startTimeButton setTag:TAG_START_TIME_BUTTON];
    [startTimeButton setTitle:[self stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    [startTimeButton addTarget:self action:@selector(startTimeButtonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [addTimerView addSubview:startTimeButton];
    //分割线
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, startTimeButton.frame.origin.y + startTimeButton.frame.size.height+5, addTimerView.frame.size.width, 0.5)];
    [line1 setBackgroundColor:[UIColor grayColor]];
    [addTimerView addSubview:line1];
    //开始时间 end
    
    //结束时间
    UILabel *endTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, startTimeLabel.frame.origin.y + startTimeLabel.frame.size.height, addTimerView.frame.size.width/3, 44)];
    [endTimeLabel setBackgroundColor:[UIColor clearColor]];
    [endTimeLabel setFont:[UIFont systemFontOfSize:18]];
    [endTimeLabel setText:@"关闭时间"];
    [addTimerView addSubview:endTimeLabel];
    //结束时间显示和设置按钮
    BFPaperButton *endTimeButton = [[BFPaperButton alloc] initWithFrame:CGRectMake(endTimeLabel.frame.size.width+endTimeLabel.frame.origin.x, endTimeLabel.frame.origin.y, addTimerView.frame.size.width/3, 44) raised:NO];
    [endTimeButton setTitleFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.f]];
    [endTimeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [endTimeButton setTitle:[self stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    [endTimeButton setTag:TAG_END_TIME_BUTTON];
    [endTimeButton addTarget:self action:@selector(startTimeButtonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [addTimerView addSubview:endTimeButton];
    //分割线
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, endTimeButton.frame.origin.y + endTimeButton.frame.size.height+5, addTimerView.frame.size.width, 0.5)];
    [line2 setBackgroundColor:[UIColor grayColor]];
    [addTimerView addSubview:line2];
    //结束时间 end
    
    //周期
    UILabel *periodLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, endTimeLabel.frame.origin.y + endTimeLabel.frame.size.height, addTimerView.frame.size.width/3, 44)];
    [periodLabel setBackgroundColor:[UIColor clearColor]];
    [periodLabel setFont:[UIFont systemFontOfSize:18]];
    [periodLabel setText:@"周期设置"];
    [addTimerView addSubview:periodLabel];
    UIView *weekSettingView = [[UIView alloc]initWithFrame:CGRectMake(0, periodLabel.frame.origin.y + periodLabel.frame.size.height, addTimerView.frame.size.width, 44)];
    CGRect wframe = CGRectMake(0, 0, weekSettingView.frame.size.width, weekSettingView.frame.size.height);
    [weekSettingView addSubview:[self createWeekButton:@"1,2,3,4" andFrame:wframe]];
    [addTimerView addSubview:weekSettingView];
    
    return addTimerView;
}


/**
 *  格式化日期对象为小时和分钟的字符串
 *
 *  @param date 日期对象
 *
 *  @return 小时：分钟的字符串
 */
- (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

/**
 *  创建周期选择按钮(已选择为[UIColor colorWithRed:0.255 green:0.827 blue:0.318 alpha:1.000]，未选择为白色)
 *
 *  @param period 已有的周期数据
 *
 *  @return 返回创建好的周期选择按钮
 */
-(UIView *)createWeekButton:(NSString *)period andFrame:(CGRect)wframe{
    UIView *oneWeekView = [[UIView alloc]initWithFrame:wframe];
    float dayButtonWidth = oneWeekView.frame.size.width/7.0f;
    NSArray *periodArray = nil;
    if (period) {
        NSString *p = [[NSString alloc]initWithString:period];
        DTLog(@"p=%@",p);
        periodArray = [p componentsSeparatedByString:@","];
        DTLog(@"pa=%@",periodArray);
    }else{
        periodArray = [[NSArray alloc]init];
    }
    
    
    for (int i=0; i<7; i++) {
        BFPaperButton *oneDayButton = [[BFPaperButton alloc] initWithFrame:CGRectMake(dayButtonWidth*i+0.5, 0, dayButtonWidth, 40)];
        [oneDayButton setTitleFont:[UIFont systemFontOfSize:10]];
        [oneDayButton setTitle:[self weekConver:i] forState:UIControlStateNormal];
        [oneDayButton setBackgroundColor:[UIColor whiteColor]];
        if (i==7) {
            [oneDayButton setBackgroundColor:[UIColor colorWithRed:0.255 green:0.827 blue:0.318 alpha:1.000]];
        }
        [oneDayButton setTitleFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.f]];
        [oneDayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [oneDayButton setTag:(TAG_WEEK_BUTTON + i)];
        [oneDayButton addTarget:self action:@selector(selectDayButtonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        oneDayButton.layer.borderColor = [UIColor grayColor].CGColor;
        oneDayButton.layer.borderWidth = 0.5;
        if ([periodArray count]>0) {
            if ([periodArray indexOfObject:[NSString stringWithFormat:@"%d",i]]!=NSNotFound) {
                [oneDayButton setBackgroundColor:[UIColor colorWithRed:0.255 green:0.827 blue:0.318 alpha:1.000]];
                [oneDayButton setAccessibilityValue:@"select"];
            }else{
                [oneDayButton setBackgroundColor:[UIColor whiteColor]];
                [oneDayButton setAccessibilityValue:@"unselect"];
            }
        }else{
            [oneDayButton setBackgroundColor:[UIColor whiteColor]];
            [oneDayButton setAccessibilityValue:@"unselect"];
        }
        
        [oneWeekView addSubview:oneDayButton];
    }
    return oneWeekView;
}

-(NSString *)weekConver:(NSInteger )iday{
    switch (iday) {
        case 0:
        {
            return @"周一";
        }
            break;
        case 1:
        {
            return @"周二";
        }
            break;
        case 2:
        {
            return @"周三";
        }
            break;
        case 3:
        {
            return @"周四";
        }
            break;
        case 4:
        {
            return @"周五";
        }
            break;
        case 5:
        {
            return @"周六";
        }
            break;
        case 6:
        {
            return @"周日";
        }
            break;
        default:
            break;
    }
    return @"单次";
}

/**
 *  选择周期按钮
 *
 *  @param sender 周期按钮
 */
-(void)selectDayButtonClickEvent:(BFPaperButton *)sender{
    UIView *superView = sender.superview;
    
    if ([sender.accessibilityValue isEqualToString:@"select"]) {
        if (sender.tag != TAG_WEEK_BUTTON+7) {
            [sender setBackgroundColor:[UIColor whiteColor]];
            [sender setAccessibilityValue:@"unselect"];
        }
    }else{
        [sender setBackgroundColor:[UIColor colorWithRed:0.255 green:0.827 blue:0.318 alpha:1.000]];
        [sender setAccessibilityValue:@"select"];
        if (sender.tag == TAG_WEEK_BUTTON+7) {
            for (int i=0; i<7; i++) {
                [[superView viewWithTag:TAG_WEEK_BUTTON+i] setBackgroundColor:[UIColor whiteColor]];
                [[superView viewWithTag:TAG_WEEK_BUTTON+i] setAccessibilityValue:@"unselect"];
            }
        }else{
            [[superView viewWithTag:TAG_WEEK_BUTTON+7] setBackgroundColor:[UIColor whiteColor]];
            [[superView viewWithTag:TAG_WEEK_BUTTON+7] setAccessibilityValue:@"unselect"];
        }
    }
}


#pragma mark -定时器开始时间
-(void)startTimeButtonClickEvent:(BFPaperButton *)sender{
    UIView *dateSelectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_CGSIZE_WIDTH, 200)];
    [dateSelectView setBackgroundColor:[UIColor whiteColor]];
    [sender.superview.superview addSubview:dateSelectView];
    [dateSelectView setUserInteractionEnabled:YES];
    
    UILabel *showDateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    [showDateLabel setBackgroundColor:[UIColor clearColor]];
    [showDateLabel setFont:[UIFont systemFontOfSize:12]];
    [dateSelectView addSubview:showDateLabel];
    
    
    UIDatePicker *datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0,dateSelectView.frame.size.width, dateSelectView.frame.size.height/2)];
    [datePicker setDatePickerMode:UIDatePickerModeTime];
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    [datePicker setTintColor:[UIColor blueColor]];
    [datePicker setTag:TAG_DATE_PICKER];
    [dateSelectView addSubview:datePicker];
    
    //时间保存按钮
    BFPaperButton *saveTimeButton = [[BFPaperButton alloc] initWithFrame:CGRectMake(5, dateSelectView.frame.size.height - 44, dateSelectView.frame.size.width - 10, 44) raised:YES];
    [saveTimeButton setBackgroundColor:[UIColor paperColorGray]];
    [saveTimeButton setTitleFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.f]];
    [saveTimeButton setTitleColor:[UIColor paperColorOrange] forState:UIControlStateNormal];
    [saveTimeButton setTitle:NSLocalizedString(@"sure", @"确定") forState:UIControlStateNormal];
    [saveTimeButton setTag:(sender.tag + 1)];
    [saveTimeButton addTarget:self action:@selector(saveTimeButtonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [dateSelectView addSubview:saveTimeButton];
}

/**
 *  保存时间设置
 *
 *  @param sender
 */
-(void)saveTimeButtonClickEvent:(BFPaperButton *)sender{
    NSInteger tag = TAG_START_TIME_BUTTON;
    if ((sender.tag-1)==TAG_START_TIME_BUTTON) {
        tag = TAG_START_TIME_BUTTON;
    }
    if ((sender.tag-1)==TAG_END_TIME_BUTTON) {
         tag = TAG_END_TIME_BUTTON;
    }
    UIDatePicker *datePicker = (UIDatePicker *)[self.window viewWithTag:TAG_DATE_PICKER];
    BFPaperButton *startTimeButton = (BFPaperButton *)[self.window viewWithTag:tag];
    DLog(@"%@",[self stringFromDate:[datePicker date]]);
    [startTimeButton setTitle:[self stringFromDate:[datePicker date]] forState:UIControlStateNormal];
    [sender.superview removeFromSuperview];
}

@end
