//
//  HADeviceCollectionViewCell.m
//  Paper
//
//  Created by iroboteer on 15/3/14.
//  Copyright (c) 2015年 Heberti Almeida. All rights reserved.
//

#import "HADeviceCollectionViewCell.h"
#import "YXMTimerTableViewCell.h"
#import <BFPaperButton.h>
#import "UIColor+BFPaperColors.h"
#import "Config.h"
#import "STAlertView.h"

#import <CoreText/CoreText.h>
#import "NSString+WPAttributedMarkup.h"
#import "WPAttributedStyleAction.h"
#import "WPHotspotLabel.h"

#import "YXMDatabaseOperation.h"

#import <iToast/iToast.h>

#import "MyTool.h"
#import "TDO.h"
#import "YXMDeviceInfoModel.h"
#import "YXMTimerModel.h"
#import "YXMDeviceInfoModel.h"

#include <stdio.h>

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
//定时器名称的文本框
#define TAG_TIMER_NAME_TEXTFIELD 100070
//定时器项目
#define TAG_REMOVE_TIMER 100080
#define TAG_REMOVE_TIMER_END 100880
#define STATE_OF_SET 0.30f

//是否开启中继
#define TAG_START_AP_SWITCH 100990


@interface HADeviceCollectionViewCell () <UICollisionBehaviorDelegate, UIDynamicAnimatorDelegate,IGLDropDownMenuDelegate>

// UIDynamicAnimators
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (nonatomic, strong) UISnapBehavior *swipeableViewSnapBehavior;
@property (strong, nonatomic) UIAttachmentBehavior *swipeableViewAttachmentBehavior;
@property (strong, nonatomic) UIAttachmentBehavior *anchorViewAttachmentBehavior;
// AnchorView
@property (strong, nonatomic) UIView *anchorContainerView;
@property (strong, nonatomic) UIView *anchorView;
@property (nonatomic) BOOL isAnchorViewVisiable;
// ContainerView
@property (strong, nonatomic) UIView *reuseCoverContainerView;
@property (strong, nonatomic) UIView *containerView;
@property (nonatomic, strong) IGLDropDownMenu *dropDownMenu;
@end

@implementation HADeviceCollectionViewCell
@synthesize data = _data;
@synthesize currentIndex = _currentIndex;

-(void)setData:(YXMDeviceInfoModel *)data{
    if (data) {
        if (data!=_data) {
            _data = data;
            @try {
                //插座头像
                NSString *sDeviceHead = data.device_head;
                if ([sDeviceHead length]<1) {
                    sDeviceHead = @"virtual_device";
                }
                [_deviceHeadImageView setImage:[UIImage imageNamed:sDeviceHead]];
                
                //插座名称
                NSString *sDeviceName = data.device_name;
                if ([sDeviceName length]<1) {
                    sDeviceName = @"智能插座";
                }
                [_deviceNameLabel setText:sDeviceName];
                
                //改变设备电源按钮的图片
                //改变设备对象中对应的数据
                NSInteger iDeviceState = data.device_state;
                switch (iDeviceState) {
                    case EnumDevicePowerStateOpen:
                    {
                        [_swithButton setBackgroundImage:[UIImage imageNamed:@"switch_open"] forState:UIControlStateNormal];
                    }
                        break;
                    case EnumDevicePowerStateClose:
                    {
                        [_swithButton setBackgroundImage:[UIImage imageNamed:@"switch_close"] forState:UIControlStateNormal];
                    }
                        break;
                    default:
                        break;
                }
                
                //插座网络的状态
                NSInteger netState = data.device_net_state;
                //如果插座最后更新时间与当前时间的差大于5秒，则判定插座网络离线
                CGFloat timeDifference = [[NSDate date] timeIntervalSince1970]-[data.device_last_updatetime timeIntervalSince1970];
                DLog(@"timeDifference = %lf",timeDifference);
                if (timeDifference<20) {
                    netState = EnumDeviceNetStateLocalOnline;
                }else{
                    netState = EnumDeviceNetStateLocalOffline;
                }
                
                //改变设备电源按钮的提示文字
                NSString *sStateLabelText = [self devicePowerStateStr:iDeviceState];
                NSString *sPowerAndNetState = [NSString stringWithFormat:@"<body>%@</body><green>|</green><body>%@</body>",sStateLabelText,[self deviceNetStateStr:netState]];
                [_devicePowerStateAndNetStateLabel setAttributedText:[sPowerAndNetState attributedStringWithStyleBook:_styleOfDevicePowerStateAndNetStateLabel]];
                
                //刷新定时器列表
                [_timerTableView reloadData];
                
                //打印插座的IP地址
                DTLog(@"device_ip = %@",data.device_local_ip);
                
                if (data.device_local_ip) {
                    char IpAddress[30];
                    char const *s = [data.device_local_ip cStringUsingEncoding:NSUTF8StringEncoding];
                    memcpy(IpAddress, s, (strlen(s)+1));
                    if(IsFormatValid(IpAddress) && IsValueValid(IpAddress))
                    {
                        if(![_mySocket isDisconnected])
                        {
                            [_mySocket disconnect];
                        }
                        _mySocket = data.device_socket;
                        if (_mySocket==nil) {
                            _mySocket = [[AsyncSocket alloc]init];
                        }
                        
                        [_mySocket setDelegate:self];
                        [_mySocket connectToHost:data.device_local_ip onPort:PORT_OF_GET_SERVICE_IP withTimeout:-1 error:nil];
                        [_mySocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
                    }
                }
            

            }
            @catch (NSException *exception) {
                DLog(@"%@",exception);
            }
            @finally {
                
            }
        }
    }
}

-(YXMDeviceInfoModel *)data{
    return _data;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _styleOfDevicePowerStateAndNetStateLabel = @{@"body":[UIFont fontWithName:@"HelveticaNeue" size:14.0],
                                                                  @"bold":[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0],
                                                                  @"green": [UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000]};
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 4;
        self.clipsToBounds = YES;
        [self setUserInteractionEnabled:YES];
        [self initCellView];
        [self setSmallCellViewLayout];

        //向上拖动到一定的高度的时候执行删除设备的动作
        UIPanGestureRecognizer *handlePan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        [handlePan setMinimumNumberOfTouches:2];
        [self addGestureRecognizer:handlePan];
        
//        _readSmartDeviceInfoTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(readSmartDeviceInfoFromNetwork:) userInfo:nil repeats:YES];
    }
    return self;
}



-(void)initCellView{
    _largeLayout = [[HACollectionViewLargeLayout alloc]init];
    _smallLayout = [[HACollectionViewSmallLayout alloc]init];
    [self initSmallCellView];
    [self initlargeCellView];
}

/**
 *  隐藏除了开关之外的其他视图
 */
-(void)hiddenOtherView{
    [_timerView setHidden:YES];
    [_coulometryView setHidden:YES];
    [_moreView setHidden:YES];
}

-(void)setSmallCellViewLayout{
    
    CGFloat horizontalDeviceButtonSpace = (15.0/320.0)*SCREEN_CGSIZE_WIDTH;
    CGFloat deviceButtonWidth = _smallLayout.itemSize.width-(horizontalDeviceButtonSpace*2);
    CGFloat deviceButtonX = horizontalDeviceButtonSpace;
    CGFloat deviceButtonY = horizontalDeviceButtonSpace;
    _deviceHeadImageView.frame = CGRectMake(deviceButtonX, deviceButtonY, deviceButtonWidth, deviceButtonWidth);
    //end
    
    /******设备的名称******/
    float hSpace = 10;
    if (SCREEN_CGSIZE_HEIGHT<481) {
        hSpace = 0;
    }
    _deviceNameLabel.frame = CGRectMake(0, _deviceHeadImageView.frame.origin.y + _deviceHeadImageView.frame.size.height, _smallLayout.itemSize.width,30);
    //end
    
    //设备的电源状态和网络状态
    CGRect rectDevicePowerStateAndNetStateLabel = CGRectMake(0, _deviceNameLabel.frame.origin.y + _deviceNameLabel.frame.size.height, _smallLayout.itemSize.width,30);
    [_devicePowerStateAndNetStateLabel setFrame:rectDevicePowerStateAndNetStateLabel];

    [_deviceHeadImageView setHidden:NO];
    [_segmentView setHidden:YES];
    [_controlView setHidden:YES];
    [self hiddenOtherView];
    [_deviceNameLabel setFont:[UIFont systemFontOfSize:18]];
    

    //改变设备电源按钮的图片
    //改变设备对象中对应的数据
    NSInteger iDeviceState = _data.device_state;
    switch (iDeviceState) {
        case EnumDevicePowerStateOpen:
        {
            [_swithButton setBackgroundImage:[UIImage imageNamed:@"switch_open"] forState:UIControlStateNormal];
        }
            break;
        case EnumDevicePowerStateClose:
        {
            [_swithButton setBackgroundImage:[UIImage imageNamed:@"switch_close"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    
    //改变设备电源按钮的提示文字
    NSString *sStateLabelText = [self devicePowerStateStr:iDeviceState];
    NSString *sPowerAndNetState = [NSString stringWithFormat:@"<body>%@</body><green>|</green><body>%@</body>",sStateLabelText,[self deviceNetStateStr:_data.device_net_state]];
    [_devicePowerStateAndNetStateLabel setAttributedText:[sPowerAndNetState attributedStringWithStyleBook:_styleOfDevicePowerStateAndNetStateLabel]];
    [_devicePowerStateAndNetStateLabel setHidden:NO];
    
    //设备名称不可以点击
    [_deviceNameLabel setUserInteractionEnabled:NO];

    DLog(@"***************进入设备缩略图,可查看设备状态!");
    _isLargeView = NO;
}

-(void)setLargeCellViewLayout{
    [_deviceHeadImageView setHidden:YES];
    [_segmentView setHidden:NO];

    HACollectionViewLargeLayout *largeLayout = [[HACollectionViewLargeLayout alloc]init];
    [_deviceNameLabel setFrame:CGRectMake(0, 5, largeLayout.itemSize.width, 30)];
    [_deviceNameLabel setFont:[UIFont boldSystemFontOfSize:25]];
    [_controlView setHidden:NO];

    //改变设备电源按钮的图片
    //改变设备对象中对应的数据
    NSInteger iDeviceState = _data.device_state;
    switch (iDeviceState) {
        case EnumDevicePowerStateOpen:
        {
            [_swithButton setBackgroundImage:[UIImage imageNamed:@"switch_open"] forState:UIControlStateNormal];
        }
            break;
        case EnumDevicePowerStateClose:
        {
            [_swithButton setBackgroundImage:[UIImage imageNamed:@"switch_close"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    
    //改变设备电源按钮的提示文字
    NSString *sStateLabelText = [self devicePowerStateStr:iDeviceState];
    NSString *sPowerAndNetState = [NSString stringWithFormat:@"<body>%@</body><green>|</green><body>%@</body>",sStateLabelText,[self deviceNetStateStr:_data.device_net_state]];
    [_devicePowerStateAndNetStateLabel setAttributedText:[sPowerAndNetState attributedStringWithStyleBook:_styleOfDevicePowerStateAndNetStateLabel]];
    [_devicePowerStateAndNetStateLabel setHidden:YES];
    
    [_segmentView selectItemOfIndex:_data.device_selectIndex];

    DLog(@"***************进入设备详情,可控制开关!");
    _isLargeView = YES;
    
    //保存初始化的frame
    myFrame = CGRectMake(largeLayout.sectionInset.top, largeLayout.sectionInset.left, largeLayout.itemSize.width, largeLayout.itemSize.height);
    
    //设备名称可以点击
    [_deviceNameLabel setUserInteractionEnabled:YES];
}



/**
 *  初始化首页collection中item缩小时候的视图
 */
-(void)initSmallCellView{
    /******设备的头像******/
    
    CGFloat horizontalDeviceButtonSpace = (15.0/_smallLayout.itemSize.width)*self.frame.size.width;
    CGFloat deviceButtonWidth = self.frame.size.width-(horizontalDeviceButtonSpace*2);
    CGFloat deviceButtonX = horizontalDeviceButtonSpace;
    CGFloat deviceButtonY = horizontalDeviceButtonSpace;
    _deviceHeadImageView = [[UIImageView alloc]initWithFrame:CGRectMake(deviceButtonX, deviceButtonY, deviceButtonWidth, deviceButtonWidth)];
    [_deviceHeadImageView setImage:[UIImage imageNamed:@"virtual_device"]];
    _deviceHeadImageView.clipsToBounds = YES;
    _deviceHeadImageView.layer.cornerRadius = 4;
    [self addSubview:_deviceHeadImageView];
    //end
    
    /******设备的名称******/
    float hSpace = 10;
    if (SCREEN_CGSIZE_HEIGHT<481) {
        hSpace = 0;
    }
    _deviceNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, _deviceHeadImageView.frame.origin.y + _deviceHeadImageView.frame.size.height, self.frame.size.width,30)];
    [_deviceNameLabel setBackgroundColor:[UIColor clearColor]];
    [_deviceNameLabel setFont:[UIFont systemFontOfSize:20]];
    [_deviceNameLabel setTextAlignment:NSTextAlignmentCenter];
    [_deviceNameLabel setText:@""];
    [_deviceNameLabel setUserInteractionEnabled:NO];
    UITapGestureRecognizer *nameLabelTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(nameLabelTapAction:)];
    [_deviceNameLabel addGestureRecognizer:nameLabelTapGesture];
    [self addSubview:_deviceNameLabel];
    //end
    
    //设备的电源状态和网络状态
    CGRect rectDevicePowerStateAndNetStateLabel = CGRectMake(0, _deviceNameLabel.frame.origin.y + _deviceNameLabel.frame.size.height, _smallLayout.itemSize.width,30);
    _devicePowerStateAndNetStateLabel = [[UILabel alloc]initWithFrame:rectDevicePowerStateAndNetStateLabel];
    [_devicePowerStateAndNetStateLabel setBackgroundColor:[UIColor clearColor]];
    [_devicePowerStateAndNetStateLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [_devicePowerStateAndNetStateLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_devicePowerStateAndNetStateLabel];
    

    //设置边框为0.7宽的绿色
    [self.layer setBorderColor:[UIColor colorWithRed:0.463 green:0.773 blue:0.051 alpha:1.000].CGColor];
    [self.layer setBorderWidth:0.7];
    //end
}

/**
 *  初始化首页collection中item放大时候的视图
 */
-(void)initlargeCellView{
    
    //分段按钮，开关控制，定时控制，电量统计三项功能
    _segmentView = [[RFSegmentView alloc] initWithFrame:CGRectMake(10,40, SCREEN_CGSIZE_WIDTH - 30, 60) items:@[@"开关控制",@"定时控制",@"电量统计",@"更多"]];
    _segmentView.tintColor = [UIColor colorWithRed:0.467 green:0.784 blue:0.055 alpha:1.000];
    _segmentView.delegate = self;
    
    [self addSubview:_segmentView];
    
    //初始化开关控制的视图
    [self initControlView];
    //初始化定时控制的视图
    [self initTimerView];
    //初始化电量统计的视图
    [self initCoulometryView];
    //更多界面的视图
    [self initMoreView];
    //默认显示开关控制按钮
    [self hiddenOtherView];
}

/**
 *  初始化更多视图
 */
-(void)initMoreView{
    _moreView = [[UIView alloc]initWithFrame:CGRectMake(0, _segmentView.frame.origin.y+_segmentView.frame.size.height, _largeLayout.itemSize.width, SCREEN_CGSIZE_HEIGHT - (_segmentView.frame.origin.y+_segmentView.frame.size.height) - 84)];
    [_moreView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_moreView];
    
    //开始时间
    UILabel *startTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 20, SCREEN_CGSIZE_WIDTH/3, 44)];
    [startTimeLabel setBackgroundColor:[UIColor clearColor]];
    [startTimeLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [startTimeLabel setText:@"信号增强"];
    [_moreView addSubview:startTimeLabel];
    //开始时间是否启用
    UISwitch *startTimeSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(_moreView.frame.size.width - 80 , 20, 80, 20)];
    [startTimeSwitch setTag:TAG_START_AP_SWITCH];
    [startTimeSwitch addTarget:self action:@selector(updateAPSwitch:) forControlEvents:UIControlEventValueChanged];
    [startTimeSwitch setOn:YES];
    [_moreView addSubview:startTimeSwitch];
}

/**
 *  分段控制按钮的回调方法
 *
 *  @param index 点击对应的控制按钮的索引
 */
- (void)segmentViewSelectIndex:(NSInteger)index
{
    DLog(@"current index is %d",(int)index);
    switch (index) {
        case 0:
        {
            //开关控制
            [_controlView setHidden:NO];
            [_timerView setHidden:YES];
            [_coulometryView setHidden:YES];
            [_moreView setHidden:YES];
        }
            break;
        case 1:
        {
            //定时设置
            [_controlView setHidden:YES];
            [_timerView setHidden:NO];
            [_coulometryView setHidden:YES];
            [_moreView setHidden:YES];
        }
            break;
        case 2:
        {
            //电量统计
            [_controlView setHidden:YES];
            [_timerView setHidden:YES];
            [_coulometryView setHidden:NO];
            [_moreView setHidden:YES];
        }
            break;
        case 3:
        {
            //电量统计
            [_controlView setHidden:YES];
            [_timerView setHidden:YES];
            [_coulometryView setHidden:YES];
            [_moreView setHidden:NO];
        }
            break;
        default:
            break;
    }
    [_data setDevice_selectIndex:index];
}

/**
 *  开关控制视图
 */
-(void)initControlView{
    
    _controlView = [[UIView alloc]initWithFrame:CGRectMake(0, _segmentView.frame.origin.y+_segmentView.frame.size.height, _largeLayout.itemSize.width, SCREEN_CGSIZE_HEIGHT - (_segmentView.frame.origin.y+_segmentView.frame.size.height) - 84)];
    [_controlView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_controlView];
    
    
    //beging
    /***开关按钮***/
    _swithButton = [[UIButton alloc]initWithFrame:CGRectMake(_largeLayout.itemSize.width/4.0, _largeLayout.itemSize.width/4.0, _largeLayout.itemSize.width/2.0, _largeLayout.itemSize.width/2.0)];
    //改变设备电源按钮的图片
    //改变设备对象中对应的数据
    NSInteger iDeviceState = _data.device_state;
    switch (iDeviceState) {
        case EnumDevicePowerStateOpen:
        {
            [_swithButton setBackgroundImage:[UIImage imageNamed:@"switch_open"] forState:UIControlStateNormal];
        }
            break;
        case EnumDevicePowerStateClose:
        {
            [_swithButton setBackgroundImage:[UIImage imageNamed:@"switch_close"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    
    //改变设备电源按钮的提示文字
    NSString *sStateLabelText = [self devicePowerStateStr:iDeviceState];
    NSString *sPowerAndNetState = [NSString stringWithFormat:@"<body>%@</body><green>|</green><body>%@</body>",sStateLabelText,[self deviceNetStateStr:_data.device_net_state]];
    [_devicePowerStateAndNetStateLabel setAttributedText:[sPowerAndNetState attributedStringWithStyleBook:_styleOfDevicePowerStateAndNetStateLabel]];
    
    
    [_swithButton addTarget:self action:@selector(swithStateChange:) forControlEvents:UIControlEventTouchUpInside];
    [_controlView addSubview:_swithButton];
    //end
    
    
}

//初始化定时控制的视图
-(void)initTimerView{
    _timerView = [[UIView alloc]initWithFrame:CGRectMake(0, _segmentView.frame.origin.y+_segmentView.frame.size.height, _largeLayout.itemSize.width, SCREEN_CGSIZE_HEIGHT - (_segmentView.frame.origin.y+_segmentView.frame.size.height) - 84)];
    [_timerView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_timerView];
    //添加按钮
    BFPaperButton *addTimerButton = [[BFPaperButton alloc] initWithFrame:CGRectMake(30, 0, _timerView.frame.size.width-60, 44) raised:NO];
    [addTimerButton setTitleFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.f]];
    [addTimerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addTimerButton setTitle:@"添加定时" forState:UIControlStateNormal];
    [addTimerButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [addTimerButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [addTimerButton setAccessibilityValue:_data.device_id];
    [addTimerButton addTarget:self action:@selector(addTimerItem:) forControlEvents:UIControlEventTouchUpInside];
    [_timerView addSubview:addTimerButton];
    //end
    
    //定时项目的列表
    _timerTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, addTimerButton.frame.origin.y + addTimerButton.frame.size.height, _timerView.frame.size.width, _timerView.frame.size.height - addTimerButton.frame.size.height)];
    _timerTableView.delegate = self;
    _timerTableView.dataSource = self;
    [_timerTableView setBackgroundColor:[UIColor clearColor]];
    [_timerTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_timerView addSubview:_timerTableView];
}

//初始化电量统计的视图
-(void)initCoulometryView{
    _coulometryView = [[UIView alloc]initWithFrame:CGRectMake(0, _segmentView.frame.origin.y+_segmentView.frame.size.height, _largeLayout.itemSize.width, SCREEN_CGSIZE_HEIGHT - (_segmentView.frame.origin.y+_segmentView.frame.size.height) - 84)];
    [_coulometryView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_coulometryView];
    
    //当前功率
    _currentKWLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 10, _coulometryView.frame.size.width, 30)];
    [_currentKWLabel setFont:[UIFont systemFontOfSize:16]];
    [_currentKWLabel setText:@"当前功率 500W"];
    [_currentKWLabel setBackgroundColor:[UIColor clearColor]];
    [_coulometryView addSubview:_currentKWLabel];
    [_currentKWLabel setUserInteractionEnabled:YES];
    //end

    //电量统计柱状图
    _chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(20, 150, _coulometryView.frame.size.width-40, 150)
                                              withSource:self
                                               withStyle:UUChartBarStyle];
    [_chartView showInView:_coulometryView];
    //电量统计的日期
    _statisticsLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 120, 100, 30)];
    [_statisticsLabel setBackgroundColor:[UIColor clearColor]];
    [_statisticsLabel setText:@"今日电量统计"];
    [_statisticsLabel setFont:[UIFont systemFontOfSize:12]];
    [_coulometryView addSubview:_statisticsLabel];
    
    NSArray *dataArray = @[@{@"title":@"日统计图"},
                           @{@"title":@"月统计图"},
                           @{@"title":@"年统计图"}];
    NSMutableArray *dropdownItems = [[NSMutableArray alloc] init];
    for (int i = 0; i < dataArray.count; i++) {
        NSDictionary *dict = dataArray[i];
        IGLDropDownItem *item = [[IGLDropDownItem alloc] init];
        [item setText:dict[@"title"]];
        [dropdownItems addObject:item];
    }
    
    self.dropDownMenu = [[IGLDropDownMenu alloc] init];
    self.dropDownMenu.menuText = @"日统计图";
    self.dropDownMenu.dropDownItems = dropdownItems;
    self.dropDownMenu.paddingLeft = 3;
    [self.dropDownMenu setFrame:CGRectMake(_currentKWLabel.frame.origin.x+(_currentKWLabel.frame.size.width-131), _currentKWLabel.frame.origin.y, 86, 30)];
    self.dropDownMenu.delegate = self;
    
    [self setUpParamsForDemo1];
    
    [self.dropDownMenu reloadView];
    
    [_coulometryView addSubview:self.dropDownMenu];
}

- (void)setUpParamsForDemo1
{
    self.dropDownMenu.type = IGLDropDownMenuTypeStack;
    self.dropDownMenu.gutterY = 5;
}




/**
 *  开关的状态切换
 *
 *  @param sender 开关按钮
 */
-(void)swithStateChange:(UIButton *)sender{
    //根据用户操作的状态去向插座设备发送开或者关的命令
    if (_data.device_net_state == EnumDeviceNetStateLocalOffline) {
        [[[iToast makeText:NSLocalizedString(@"device_offline_ctrl_error", @"")]
          setGravity:iToastGravityCenter] show:iToastTypeError];
        return;
    }
    //改变设备电源按钮的图片
    //改变设备对象中对应的数据
    NSInteger iDeviceState = _data.device_state;
    switch (iDeviceState) {
        case EnumDevicePowerStateOpen:
        {
            [_data setDevice_state:EnumDevicePowerStateClose];
            [_swithButton setBackgroundImage:[UIImage imageNamed:@"switch_close"] forState:UIControlStateNormal];
        }
            break;
        case EnumDevicePowerStateClose:
        {
            [_data setDevice_state:EnumDevicePowerStateOpen];
            [_swithButton setBackgroundImage:[UIImage imageNamed:@"switch_open"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    
    //改变设备电源按钮的提示文字
    NSString *sStateLabelText = [self devicePowerStateStr:iDeviceState];
    NSString *sPowerAndNetState = [NSString stringWithFormat:@"<body>%@</body><green>|</green><body>%@</body>",sStateLabelText,[self deviceNetStateStr:_data.device_net_state]];
    [_devicePowerStateAndNetStateLabel setAttributedText:[sPowerAndNetState attributedStringWithStyleBook:_styleOfDevicePowerStateAndNetStateLabel]];
    //设备状态改变的回调
    [self sendCmdOpenOrClosePower:_data];
    [self.delegate cellStateChange:_data andIndex:_currentIndex];
}

/**
 *  添加定时控制的操作
 *
 *  @param sender 添加定时按钮对象
 */
-(void)addTimerItem:(UIButton *)sender{
    DLog(@"点击了添加按钮");
    //弹出实时控制添加界面
    [self createAddTimerView:nil];
    //隐藏导航栏上的主页按钮
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_COLLECTIONVIEW_SIZE_CHANGE object:nil userInfo:[NSDictionary dictionaryWithObject:@"small" forKey:@"size"]];
}

/**
 *  创建定时器新增界面
 */
-(void)createAddTimerView:(YXMTimerModel *)data{
    if (!data) {
        YXMTimerModel *oTimer = [[YXMTimerModel alloc]init];
        [oTimer setTimer_name:[NSString stringWithFormat:@"定时名称%d",1]];
//        [oTimer setTimer_id:[NSString stringWithFormat:@"%d%d",1,1]];
        [oTimer setTimer_period:@""];
        [oTimer setTimer_isactive:YES];
        [oTimer setTimer_start_hour:@"15"];
        [oTimer setTimer_start_minutes:@"18"];
        [oTimer setTimer_start_isuse:@"YES"];
        [oTimer setTimer_close_hour:@"16"];
        [oTimer setTimer_close_minutes:@"19"];
        [oTimer setTimer_close_isuse:@"YES"];
        data = oTimer;
    }
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.superview.superview.frame.size.width, self.superview.superview.frame.size.height)];
    [self.superview.superview addSubview:bgView];
    [bgView setBackgroundColor:[UIColor whiteColor]];
    UIView *addTimerView = [[UIView alloc]initWithFrame:CGRectMake(20, 20, self.superview.superview.frame.size.width-20*2, self.superview.superview.frame.size.height-40)];
    [addTimerView setBackgroundColor:[UIColor whiteColor]];
    [bgView addSubview:addTimerView];
    //定时器名称
    UILabel *timerNamePromptLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, SCREEN_CGSIZE_WIDTH, 30)];
    [timerNamePromptLabel setBackgroundColor:[UIColor clearColor]];
    [timerNamePromptLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [timerNamePromptLabel setText:@"定时器名称"];
    [addTimerView addSubview:timerNamePromptLabel];
    UITextField *timerNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, timerNamePromptLabel.frame.origin.y+timerNamePromptLabel.frame.size.height, addTimerView.frame.size.width, 44)];
    [timerNameTextField setPlaceholder:@"请输入定时器名称"];
    [timerNameTextField setTextColor:[UIColor blackColor]];
    [timerNameTextField setFont:[UIFont systemFontOfSize:14]];
    [timerNameTextField.layer setBorderColor:[UIColor grayColor].CGColor];
    [timerNameTextField.layer setBorderWidth:0.5];
    timerNameTextField.delegate = self;
    [timerNameTextField setTag:TAG_TIMER_NAME_TEXTFIELD];
    if (data) {
        [timerNameTextField setText:data.timer_name];
    }
    [addTimerView addSubview:timerNameTextField];
    
    //开始时间
    UILabel *startTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, timerNameTextField.frame.origin.y + timerNameTextField.frame.size.height, SCREEN_CGSIZE_WIDTH/3, 44)];
    [startTimeLabel setBackgroundColor:[UIColor clearColor]];
    [startTimeLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [startTimeLabel setText:@"开启时间"];
    [addTimerView addSubview:startTimeLabel];
    //开始时间显示和设置按钮
    BFPaperButton *startTimeButton = [[BFPaperButton alloc] initWithFrame:CGRectMake(startTimeLabel.frame.size.width+startTimeLabel.frame.origin.x, startTimeLabel.frame.origin.y, SCREEN_CGSIZE_WIDTH/3, 44) raised:NO];
    [startTimeButton setTitleFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.f]];
    [startTimeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [startTimeButton setTag:TAG_START_TIME_BUTTON];
    [startTimeButton setTitle:[self stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    [startTimeButton addTarget:self action:@selector(startTimeButtonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    if (data) {
        [startTimeButton setTitle:[NSString stringWithFormat:@"%@:%@",data.timer_start_hour,data.timer_start_minutes] forState:UIControlStateNormal];
    }
    [addTimerView addSubview:startTimeButton];
    //开始时间是否启用
    UISwitch *startTimeSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(startTimeButton.frame.origin.x + startTimeButton.frame.size.width , startTimeButton.frame.origin.y+10, 80, 20)];
    [startTimeSwitch setTag:TAG_START_TIME_SWITCH];
    [startTimeSwitch addTarget:self action:@selector(updateEndSwitch:) forControlEvents:UIControlEventValueChanged];
    [startTimeSwitch setOn:YES];
    [addTimerView addSubview:startTimeSwitch];
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, startTimeSwitch.frame.origin.y + startTimeSwitch.frame.size.height+5, addTimerView.frame.size.width, 0.5)];
    [line1 setBackgroundColor:[UIColor grayColor]];
    [addTimerView addSubview:line1];
    //开始时间 end
    
    //结束时间
    UILabel *endTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, startTimeLabel.frame.origin.y + startTimeLabel.frame.size.height, SCREEN_CGSIZE_WIDTH/3, 44)];
    [endTimeLabel setBackgroundColor:[UIColor clearColor]];
    [endTimeLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [endTimeLabel setText:@"关闭时间"];
    [addTimerView addSubview:endTimeLabel];
    //结束时间显示和设置按钮
    BFPaperButton *endTimeButton = [[BFPaperButton alloc] initWithFrame:CGRectMake(endTimeLabel.frame.size.width+endTimeLabel.frame.origin.x, endTimeLabel.frame.origin.y, SCREEN_CGSIZE_WIDTH/3, 44) raised:NO];
    [endTimeButton setTitleFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.f]];
    [endTimeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [endTimeButton setTag:TAG_END_TIME_BUTTON];
    [endTimeButton setTitle:[self stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    [endTimeButton addTarget:self action:@selector(startTimeButtonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    if (data) {
        [endTimeButton setTitle:[NSString stringWithFormat:@"%@:%@",data.timer_close_hour,data.timer_close_minutes] forState:UIControlStateNormal];
    }
    [addTimerView addSubview:endTimeButton];
    //结束时间是否启用
    UISwitch *endTimeSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(endTimeButton.frame.origin.x + endTimeButton.frame.size.width , endTimeButton.frame.origin.y+10, 80, 20)];
    [endTimeSwitch setTag:TAG_END_TIME_SWITCH];
    [endTimeSwitch addTarget:self action:@selector(updateEndSwitch:) forControlEvents:UIControlEventValueChanged];
    [endTimeSwitch setOn:YES];
    [addTimerView addSubview:endTimeSwitch];
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, endTimeSwitch.frame.origin.y + endTimeSwitch.frame.size.height+5, addTimerView.frame.size.width, 0.5)];
    [line2 setBackgroundColor:[UIColor grayColor]];
    [addTimerView addSubview:line2];
    //结束时间 end
    
    //周期
    UILabel *periodLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, endTimeLabel.frame.origin.y + endTimeLabel.frame.size.height, SCREEN_CGSIZE_WIDTH/3, 44)];
    [periodLabel setBackgroundColor:[UIColor clearColor]];
    [periodLabel setFont:[UIFont systemFontOfSize:18]];
    [periodLabel setText:@"周期设置"];
    [addTimerView addSubview:periodLabel];
    UIView *weekSettingView = [[UIView alloc]initWithFrame:CGRectMake(0, periodLabel.frame.origin.y + periodLabel.frame.size.height, addTimerView.frame.size.width, 44)];
    CGRect wframe = CGRectMake(0, 0, weekSettingView.frame.size.width, weekSettingView.frame.size.height);
    [weekSettingView addSubview:[self createWeekButton:data.timer_period andFrame:wframe]];
    [addTimerView addSubview:weekSettingView];
    
    //保存设置按钮
    BFPaperButton *removeTimerViewOfButton = [[BFPaperButton alloc] initWithFrame:CGRectMake(0, weekSettingView.frame.origin.y + weekSettingView.frame.size.height + 44, addTimerView.frame.size.width, 44) raised:NO];
    [removeTimerViewOfButton setTitleFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.f]];
    [removeTimerViewOfButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [removeTimerViewOfButton setTitle:NSLocalizedString(@"saveandexit", @"保存") forState:UIControlStateNormal];
    if (data) {
        [removeTimerViewOfButton setAccessibilityValue:data.timer_id];
    }
    [removeTimerViewOfButton addTarget:self action:@selector(removeTimerViewOfButtonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [removeTimerViewOfButton setBackgroundColor:[UIColor colorWithRed:0.216 green:0.667 blue:0.263 alpha:1.000]];
    [addTimerView addSubview:removeTimerViewOfButton];
    //取消按钮
    BFPaperButton *cancelTimerViewOfButton = [[BFPaperButton alloc] initWithFrame:CGRectMake(0, removeTimerViewOfButton.frame.origin.y + removeTimerViewOfButton.frame.size.height + 20, addTimerView.frame.size.width, 44) raised:NO];
    [cancelTimerViewOfButton setTitleFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.f]];
    [cancelTimerViewOfButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelTimerViewOfButton setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
    [cancelTimerViewOfButton addTarget:self action:@selector(cancelViewOfButtonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [cancelTimerViewOfButton setBackgroundColor:[UIColor colorWithWhite:0.906 alpha:1.000]];
    [addTimerView addSubview:cancelTimerViewOfButton];
}


/**
 *  点击保存并退出按钮的动作
 *
 *  @param sender 保存并退出按钮
 */
-(void)removeTimerViewOfButtonClickEvent:(BFPaperButton *)sender{
    NSString *timer_id = sender.accessibilityValue;
    [sender setAccessibilityValue:nil];
    if ([self saveTimerData:timer_id]) {
        [sender.superview.superview removeFromSuperview];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_COLLECTIONVIEW_SIZE_CHANGE object:nil userInfo:[NSDictionary dictionaryWithObject:@"large" forKey:@"size"]];
}


/**
 *  点击取消按钮的动作
 *
 *  @param sender 取消按钮
 */
-(void)cancelViewOfButtonClickEvent:(BFPaperButton *)sender{
    [sender.superview.superview removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_COLLECTIONVIEW_SIZE_CHANGE object:nil userInfo:[NSDictionary dictionaryWithObject:@"large" forKey:@"size"]];
}


#pragma mark 定时器列表
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *indentiferString = [NSString stringWithFormat:@"%d%d",(int)indexPath.row,(int)indexPath.section];
    YXMTimerTableViewCell *timerItemCell = [tableView dequeueReusableCellWithIdentifier:indentiferString];
    
    if (!timerItemCell) {
        timerItemCell = [[YXMTimerTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentiferString];
    }
    
    [timerItemCell setData:[_data.device_timerlist objectAtIndex:indexPath.row]];
    [timerItemCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    UILongPressGestureRecognizer *removeGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(removeCellAction:)];
    
    removeGestureRecognizer.minimumPressDuration = 0.5;
    [removeGestureRecognizer setAccessibilityValue:[NSString stringWithFormat:@"%d",(int)indexPath.row]];
    [timerItemCell addGestureRecognizer:removeGestureRecognizer];
    return timerItemCell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    @try {
        NSInteger rowNumber = 0;
        if (_data.device_timerlist) {
            if ([_data.device_timerlist isKindOfClass:[NSArray class]]) {
                rowNumber = [_data.device_timerlist count];
            }
        }
        return rowNumber;
    }
    @catch (NSException *exception) {
        return 0;
    }
    @finally {
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    YXMTimerModel *oneData = [_data.device_timerlist objectAtIndex:indexPath.row];
    [self createAddTimerView:oneData];
    DLog(@"编辑定时器");
}

#pragma mark - 柱状图相关
//生成测试数据
- (NSArray *)getXTitles:(int)num
{
    NSMutableArray *xTitles = [NSMutableArray array];
    switch (_chartTypeIndex) {
        case 0:
        {
            for (int i=0; i<num; i=i+2) {
                NSString * str = [NSString stringWithFormat:@"%d-%d",i,i+1];
                [xTitles addObject:str];
            }
        }
            break;
        case 1:
        {
            for (int i=0; i<num; i++) {
                NSString * str = [NSString stringWithFormat:@"%d",i+1];
                [xTitles addObject:str];
            }
        }
            break;
        case 2:
        {
            for (int i=0; i<num; i++) {
                NSString * str = [NSString stringWithFormat:@"201%d",i+1];
                [xTitles addObject:str];
            }
        }
            break;
            
        default:
        {
//            for (int i=0; i<num; i=i+2) {
//                NSString * str = [NSString stringWithFormat:@"%d-%d",i,i+1];
//                [xTitles addObject:str];
//            }
        }
            break;
    }
    
    
    return xTitles;
}

/**
 *  年月日折线视图的选择
 *
 *  @param index 年月日按钮点击后反馈的索引
 */
-(void)selectedItemAtIndex:(NSInteger)index{
    DTLog(@"index = %d",(int)index);
    _chartTypeIndex = index;
    switch (_chartTypeIndex) {
        case 0:
        {
            _statisticsLabel.text = @"每两小时统计一次";
        }
            break;
        case 1:
        {
            _statisticsLabel.text = @"每月统计一次";
        }
            break;
        case 2:
        {
            _statisticsLabel.text = @"每年统计一次";
        }
            break;
            
        default:
            break;
    }
    [_chartView removeFromSuperview];
    _chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(20, 150, _coulometryView.frame.size.width-40, 150)
                                                   withSource:self
                                                    withStyle:UUChartBarStyle];
    
    [_chartView showInView:_coulometryView];
}


//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    int xLabelNumber = 24;
    switch (_chartTypeIndex) {
        case 0:
        {
            xLabelNumber = 24;
        }
            break;
        case 1:
        {
            xLabelNumber = 12;
        }
            break;
        case 2:
        {
            xLabelNumber = 5;
        }
            break;
        default:
        {
//            xLabelNumber = 24;
        }
            break;
    }
    return [self getXTitles:xLabelNumber];
}
//数值多重数组
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    NSArray *ary4 = @[@"22",@"44",@"15",@"40",@"160",@"22",@"44",@"15",@"40",@"42",@"80",@"12"];
    switch (_chartTypeIndex) {
        case 0:
        {
            ary4 = @[@"22",@"44",@"15",@"40",@"160",@"22",@"44",@"15",@"40",@"42",@"80",@"12"];
        }
            break;
        case 1:
        {
            ary4 = @[@"55",@"22",@"15",@"40",@"160",@"180",@"11",@"15",@"40",@"42",@"80",@"12"];
        }
            break;
        case 2:
        {
            ary4 = @[@"22",@"44",@"15",@"160",@"180"];
        }
            break;
        default:
        {
//            ary4 = @[@"22",@"44",@"15",@"40",@"160",@"22",@"44",@"15",@"40",@"42",@"80",@"12"];
        }
            break;
    }
    return @[ary4];
}

//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[UUGreen,UURed,UUBrown];
}
//显示数值范围
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    return CGRangeMake(160, 0);
}

#pragma mark 折线图专享功能

//标记数值区域
- (CGRange)UUChartMarkRangeInLineChart:(UUChart *)chart
{
    return CGRangeMake(160, 0);
}

//判断显示横线条
- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    return NO;
}

//判断显示最大最小值
- (BOOL)UUChart:(UUChart *)chart ShowMaxMinAtIndex:(NSInteger)index
{
    return NO;
}


#pragma mark -UITextField
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -定时器开始时间
-(void)startTimeButtonClickEvent:(BFPaperButton *)sender{
    UIView *dateSelectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_CGSIZE_WIDTH, SCREEN_CGSIZE_HEIGHT)];
    [dateSelectView setBackgroundColor:[UIColor whiteColor]];
    [sender.superview.superview addSubview:dateSelectView];
    
    UILabel *showDateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    [showDateLabel setBackgroundColor:[UIColor clearColor]];
    [showDateLabel setFont:[UIFont systemFontOfSize:12]];
    [dateSelectView addSubview:showDateLabel];
    

    UIDatePicker *datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 44,dateSelectView.frame.size.width, dateSelectView.frame.size.height/2)];
    [datePicker setDatePickerMode:UIDatePickerModeTime];
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    [datePicker setTintColor:[UIColor blueColor]];
    [datePicker setTag:TAG_DATE_PICKER];
    [dateSelectView addSubview:datePicker];
    
    //时间保存按钮
    BFPaperButton *saveTimeButton = [[BFPaperButton alloc] initWithFrame:CGRectMake(5, dateSelectView.frame.size.height - 64 - 54, dateSelectView.frame.size.width - 10, 44) raised:YES];
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
    }else{
        tag = TAG_END_TIME_BUTTON;
    }
    UIDatePicker *datePicker = (UIDatePicker *)[self.window viewWithTag:TAG_DATE_PICKER];
    BFPaperButton *startTimeButton = (BFPaperButton *)[self.window viewWithTag:tag];
    DLog(@"%@",[self stringFromDate:[datePicker date]]);
    [startTimeButton setTitle:[self stringFromDate:[datePicker date]] forState:UIControlStateNormal];
    [sender.superview removeFromSuperview];
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
    float dayButtonWidth = oneWeekView.frame.size.width/8.0f;
    NSArray *periodArray = nil;
    if (period) {
        NSString *p = [[NSString alloc]initWithString:period];
        DTLog(@"p=%@",p);
        periodArray = [p componentsSeparatedByString:@","];
        DTLog(@"pa=%@",periodArray);
    }else{
        periodArray = [[NSArray alloc]init];
    }
    
    
    for (int i=0; i<8; i++) {
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


/**
 *  是否启用开始或结束时间
 *
 *  @param sender 开关按钮
 */
-(void)updateEndSwitch:(UISwitch *)sender{
    UIColor *buttonTinColor = [UIColor blackColor];
    if (sender.on) {
        buttonTinColor = [UIColor blackColor];
    }else{
        buttonTinColor = [UIColor grayColor];
    }
    if (sender.tag==TAG_START_TIME_SWITCH) {
        BFPaperButton *startTimeButton = (BFPaperButton *)[self.window viewWithTag:TAG_START_TIME_BUTTON];
        [startTimeButton setEnabled:sender.on];
        [startTimeButton setTitleColor:buttonTinColor forState:UIControlStateNormal];
    }else{
        BFPaperButton *startTimeButton = (BFPaperButton *)[self.window viewWithTag:TAG_END_TIME_BUTTON];
        [startTimeButton setEnabled:sender.on];
        [startTimeButton setTitleColor:buttonTinColor forState:UIControlStateNormal];
    }
}

/**
 *  保存定时器到定时器列表
 */
-(BOOL)saveTimerData:(NSString *)timerid{
    YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
    [db openDatabase];
    YXMTimerModel *timerObject = [[YXMTimerModel alloc]init];
    //定时器名称
    NSString *timerName = ((UITextField *)[self.window viewWithTag:TAG_TIMER_NAME_TEXTFIELD]).text;
    if ([timerName length]<1) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"定时器名称不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return YES;
    }
    //开始时间
    BFPaperButton *startTimeButton = ((BFPaperButton *)[self.window viewWithTag:TAG_START_TIME_BUTTON]);
    NSString *startTimeHour = @"";
    NSString *startTimeMinutes = @"";
    if (startTimeButton.enabled) {
        NSString *startTime = startTimeButton.titleLabel.text;
        NSArray *timeArr0 = [startTime componentsSeparatedByString:@":"];
        startTimeHour = [timeArr0 firstObject];
        startTimeMinutes = [timeArr0 lastObject];
    }
    //结束时间
    BFPaperButton *endTimeButton = ((BFPaperButton *)[self.window viewWithTag:TAG_END_TIME_BUTTON]);
    NSString *endTimeHour = @"";
    NSString *endTimeMinutes = @"";
    if (endTimeButton.enabled) {
        NSString *endTime = endTimeButton.titleLabel.text;
        NSArray *timeArr = [endTime componentsSeparatedByString:@":"];
        endTimeHour = [timeArr firstObject];
        endTimeMinutes = [timeArr lastObject];
    }
    //周期
    NSMutableString *period = [[NSMutableString alloc]init];
    for (int i=0; i<8; i++) {
        BFPaperButton *oneDayButton = (BFPaperButton*)[self.window viewWithTag:(TAG_WEEK_BUTTON + i)];
        if ([oneDayButton.accessibilityValue isEqualToString:@"select"]) {
            if ([period length]<1) {
                [period appendString:[NSString stringWithFormat:@"%d",i]];
            }else{
                [period appendString:[NSString stringWithFormat:@",%d",i]];
            }
        }
    }
    [timerObject setTimer_name:timerName];
    [timerObject setTimer_start_hour:startTimeHour];
    [timerObject setTimer_start_minutes:startTimeMinutes];
    [timerObject setTimer_close_hour:endTimeHour];
    [timerObject setTimer_close_minutes:endTimeMinutes];
    [timerObject setTimer_period:period];
    [timerObject setTimer_isactive:YES];
    NSInteger index = 0;
    NSInteger localIndex = 0;
    if ([timerid length]>1) {
        for (YXMTimerModel *one in _data.device_timerlist) {
            if ([one.timer_id isEqualToString:timerid]) {
                [timerObject setTimer_id:timerid];
                [timerObject setTimer_isactive:one.timer_isactive];
                localIndex = index;
            }
            index ++;
        }
        [_data.device_timerlist replaceObjectAtIndex:localIndex withObject:timerObject];
        [db deleteTimerDataWithPlugMac:timerObject.timer_id andMac:_data.device_id];
        [db replaceOrInsertTimerWithData:timerObject];
    }else{
        [timerObject setTimer_id:[NSString stringWithFormat:@"3%d",((int)[_data.device_timerlist count])+1]];
        [_data.device_timerlist addObject:timerObject];
        [db replaceOrInsertTimerWithData:timerObject];
    }
    
    
    [_timerTableView reloadData];
    return YES;
}

/**
 *  长按cell触发删除定时器的动作
 *
 *  @param gestureRecognizer 长按事件
 */
-(void)removeCellAction:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan)
        
    {
        DLog(@"ssseeeeee");
    }
    
    else if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
        
    {
        DLog(@"mimimimimimi");
        NSInteger cellRowIndex = [gestureRecognizer.accessibilityValue integerValue];
        NSArray *deviceTimerList =  _data.device_timerlist;
        YXMTimerModel *oneTimer = [deviceTimerList objectAtIndex:cellRowIndex];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"是否确认删除定时项%@",oneTimer.timer_name] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert setTag:TAG_REMOVE_TIMER+cellRowIndex];
        alert.delegate = self;
        [alert show];
    }
    
    else if(gestureRecognizer.state == UIGestureRecognizerStateChanged)
        
    {
        DLog(@"lostllllllll");
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ((alertView.tag>=TAG_REMOVE_TIMER)&&(alertView.tag<TAG_REMOVE_TIMER_END)) {
        if (buttonIndex==1) {
            DLog(@"准备删除定时器");
            NSInteger cellRowIndex = alertView.tag - TAG_REMOVE_TIMER;
            [_data.device_timerlist removeObjectAtIndex:cellRowIndex];
            [_timerTableView reloadData];
            [self.delegate cellStateChange:_data andIndex:_currentIndex];
        }
        if (buttonIndex==0) {
            DLog(@"取消删除定时器");
        }
    }
}

/**
 *  设备名称被点击，触发修改设备名称动作
 *
 *  @param gesture 单击手势
 */
-(void)nameLabelTapAction:(UITapGestureRecognizer *)gesture{
    if (!_isLargeView) {
        return;
    }
    self.changeNameAlertView = [[STAlertView alloc]initWithTitle:[NSString stringWithFormat:@"修改设备名称"] message:[NSString stringWithFormat:@"请输入新的设备名称,长度在1到10个字符之间。"] textFieldHint:@"新的设备名称" textFieldValue:self.data.device_id cancelButtonTitle:[Config DPLocalizedString:@"cancel"] otherButtonTitle:[Config DPLocalizedString:@"sure"] cancelButtonBlock:^{
        DLog(@"取消")
    } otherButtonBlock:^(NSString *result) {
        DLog(@"%@",result);
        if (([result length]>1)&&([result length]<18)) {
            YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
            [db openDatabase];
            NSString *nickname = [[NSString alloc]initWithString:result];
            
            BOOL modifyResult = [db updateSmartDeviceNickname:nickname WithDeviceMac:self.data.device_id];
            if (!modifyResult) {
                [[[iToast makeText:NSLocalizedString(@"modify_device_name_data_error", @"")]
                  setGravity:iToastGravityCenter] show:iToastTypeError];
            }else{
                //修改名称成功之后刷新数据
                [_deviceNameLabel setText:nickname];
                //通知主界面更新数据集
                NSDictionary *deviceNameAndIDDict = [[NSDictionary alloc]initWithObjectsAndKeys:nickname,@"device_name",self.data.device_id,@"device_id",nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_CHANGE_DEVICE_NICKNAME object:nil userInfo:deviceNameAndIDDict];
            }
        }else{
            [[[iToast makeText:NSLocalizedString(@"modify_device_name_length_error", @"")]
              setGravity:iToastGravityCenter] show:iToastTypeError];
        }
        
    }];
    [self.changeNameAlertView show];
}

/**
 *  当cell处于放大状态的时候触发拖动手势
 *
 *  @param recognizer 触发手势
 */
-(void)handlePan:(UIPanGestureRecognizer *)recognizer {
    if (!_isLargeView) {
        return;
    }
    [self handleUpDownGesture:recognizer];
}


/**
 *  上下拖动cell视图，当拖动超过屏幕的60%的时候则删除设备
 *
 *  @param sender 触发手势
 */
- (void)handleUpDownGesture:(UIPanGestureRecognizer *)sender
{
    CGPoint point = [sender translationInView:self];
    if (sender.state == UIGestureRecognizerStateBegan) {
        
    }
    
    if (sender.state == UIGestureRecognizerStateChanged){
        DLog(@"point.x = %f,point.y = %f",point.x,point.y);
        DLog(@"frame.x = %f,frame.y = %f",self.frame.origin.x,self.frame.origin.y);
        
        
        sender.view.center = CGPointMake(sender.view.center.x, sender.view.center.y + point.y);
        [sender setTranslation:CGPointMake(0, 0) inView:self];

        
    }
    
    if (sender.state == UIGestureRecognizerStateEnded){
        int iOriginY = self.frame.origin.y;
        DLog(@"iOriginY = %d",iOriginY);
        DLog(@"myframe.x = %f,myframe.y = %f,%f,%f",myFrame.origin.x,myFrame.origin.y-64,myFrame.size.width,myFrame.size.height);
        if (iOriginY<-sender.view.frame.size.height*0.6) {
            [self.delegate deleteDeviceCell:self.currentIndex];
        }else{
            [UIView animateWithDuration:0.5 animations:^{
                self.frame = CGRectMake(self.frame.origin.x, myFrame.origin.y-64, myFrame.size.width, myFrame.size.height);
            }];
            
        }
    }

    
}


/**
 *  将网络状态的数据转换为本地字符串
 *
 *  @param iNetState 网络状态的枚举值
 *
 *  @return 本地化的网络状态字符串
 */
-(NSString *)deviceNetStateStr:(NSInteger )iNetState{
    NSString *sNetStateLabelText = nil;
    switch (iNetState) {
        case EnumDeviceNetStateLocalOnline:
        {
            sNetStateLabelText = [Config DPLocalizedString:@"device_net_state_localonline"];
        }
            break;
        case EnumDeviceNetStateLocalOffline:
        {
            sNetStateLabelText = [Config DPLocalizedString:@"device_net_state_offline"];
        }
            break;
        case EnumDeviceNetStateRemoteOnline:
        {
            sNetStateLabelText = [Config DPLocalizedString:@"device_net_state_remoteonline"];
        }
            break;
        default:
//        {
//            sNetStateLabelText = [Config DPLocalizedString:@"device_net_state_offline"];
//        }
            break;
    }
    return sNetStateLabelText;
}

/**
 *  将电源状态数据本地化
 *
 *  @param iPowerState 电源状态
 *
 *  @return 电源状态对应的本地化字符串
 */
-(NSString *)devicePowerStateStr:(NSInteger )iPowerState{
    NSString *sPowerStateLabelText = nil;
    switch (iPowerState) {
        case EnumDevicePowerStateOpen:
        {
            sPowerStateLabelText = [Config DPLocalizedString:@"plugpoweropen"];
        }
            break;
        case EnumDevicePowerStateClose:
        {
            sPowerStateLabelText = [Config DPLocalizedString:@"plugpowerclose"];
        }
            break;
        default:
        {
            sPowerStateLabelText = [Config DPLocalizedString:@"plugpowerclose"];
        }
            break;
    }
    return sPowerStateLabelText;
}


#pragma mark - AsyncSocketDelegateMethod


- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    DNetLog(@"已经连接%s %d", __FUNCTION__, __LINE__);
    [sock readDataWithTimeout: -1 tag: 0];
    _data.device_net_state = EnumDeviceNetStateLocalOnline;
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    DNetLog(@"写数据完成%s %d, tag = %ld", __FUNCTION__, __LINE__, tag);
    [sock readDataWithTimeout: -1 tag: tag];
    _data.device_net_state = EnumDeviceNetStateLocalOnline;
}


- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *sPlugIP = [sock connectedHost];
    DTLog(@"返回的数据 tag=%ld,sPlugIP=%@",tag,sPlugIP);

    
    if (data) {
        if (!toConvertDataToObjects) {
            toConvertDataToObjects = [[TDO alloc]init];
        }
        NSMutableDictionary *findDict = [[NSMutableDictionary alloc]initWithDictionary:[toConvertDataToObjects AllEquipmentData:data]];
        [findDict setObject:sPlugIP forKey:KEY_PLUG_LOCAL_IP];
        
        //同步时间
        if (!isSynchronousTime) {
            [self sendCmdSettingPlugClockWithPlugIP:sPlugIP];
            isSynchronousTime = YES;
        }
        [self savePlugData:findDict];
    }
}

-(NSTimeInterval)onSocket:(AsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length{
    return 0;
}

-(NSTimeInterval)onSocket:(AsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length{
    return 0;
}




- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    DNetLog(@"%s %d, err = %@,port=%d,host=%@", __FUNCTION__, __LINE__, err,[sock localPort],[sock localHost]);
    NSString *sPlugIP = [sock connectedHost];
    DNetLog(@"返回的数据 sPlugIP=%@",sPlugIP);
    _data.device_net_state = EnumDeviceNetStateLocalOffline;
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    DNetLog(@"%s %d", __FUNCTION__, __LINE__);
    NSString *sPlugIP = [sock connectedHost];
    DNetLog(@"onSocketDidDisconnectsPlugIP=%@,%@",sPlugIP,_data.device_local_ip);
    _data.device_net_state = EnumDeviceNetStateLocalOffline;
}



/**
 *  使插座的时间与手机的时间同步
 */
-(void)sendCmdSettingPlugClockWithPlugIP:(NSString *)plugIP{
    /*校准插座时间为手机时间
     -(NSData *)SetPhoneTimeToSwitch:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *)LocalMac andSerial:(int)Serial;
     传入参数:
     RemoteMac 设备mac地址
     LocalMac 手机mac地址
     Serial 序列号，用来标识这个包 int 0-65535
     Status 本地0  远程1  int
     */
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *sRemoteMac = [ud objectForKey:KEY_PLUG_MAC];
    NSString *sLocalMac = [MyTool readLocalMac];
    if (sRemoteMac) {
        if (!toConvertDataToObjects) {
            toConvertDataToObjects = [[TDO alloc]init];
        }
        NSData *udpPacketData = [toConvertDataToObjects SetPhoneTimeToSwitch:0 andRemoteMac:sRemoteMac andLocalMac:sLocalMac andSerial:5];
        DNetLog(@"同步手机的时间到插座的命令 = %@",udpPacketData);
        [_mySocket writeData:udpPacketData withTimeout:-1 tag:1];
    }
}
/**
 *  打开或者关闭插座的继电器开关
 */
-(void)sendCmdOpenOrClosePower:(YXMDeviceInfoModel *)oneData{
    int iDeviceState = (int)oneData.device_state;
    NSString *sRemoteMac = nil;
    if (oneData.device_mac_address) {
        sRemoteMac = oneData.device_mac_address;
    }
    
    NSString *sLocalMac = [MyTool readLocalMac];
    if (sRemoteMac) {
        if (!toConvertDataToObjects) {
            toConvertDataToObjects = [[TDO alloc]init];
        }
        NSData *udpPacketData = [toConvertDataToObjects SetGPIOData:iDeviceState andStatus:0 andRemoteMac:sRemoteMac andLocalMac:sLocalMac andSerial:1];
        DNetLog(@"开关插座继电器的命令 = %@",udpPacketData);
        [_mySocket writeData:udpPacketData withTimeout:-1 tag:6];
        
    }
}

/**
 *  保存插座数据到数据库
 *
 *  @param dict 插座数据的字典
 */
-(void)savePlugData:(NSDictionary *)dict{
    YXMDeviceInfoModel *plug = [[YXMDeviceInfoModel alloc]init];
    
    
    NSString *sDevice_id = [dict objectForKey:KEY_PLUG_MAC];
    if (sDevice_id) {
        plug.device_id = sDevice_id;
    }else{
        plug.device_id = @"";
    }
    if ([sDevice_id length]<1) {
        return;
    }
    
    NSString *sDevice_electricity = [dict objectForKey:KEY_PLUG_ELECTRICITY];
    if (sDevice_electricity) {
        plug.device_electricity = sDevice_electricity;
    }else{
        plug.device_electricity = @"";
    }
    
    NSString *sDevice_lock = [dict objectForKey:KEY_PLUG_LOCK];
    if (sDevice_lock) {
        plug.device_lock = sDevice_lock;
    }else{
        plug.device_lock = @"";
    }
    
    NSString *sDevice_mac_address = [dict objectForKey:KEY_PLUG_MAC];
    if (sDevice_mac_address) {
        plug.device_mac_address = sDevice_mac_address;
    }else{
        plug.device_mac_address = @"";
    }
    
    //插座是否打开
    NSString *sDevice_state = [dict objectForKey:KEY_PLUG_OPEN];
    if (sDevice_state) {
        plug.device_state = [sDevice_state integerValue];
    }else{
        plug.device_state = 0;
    }
    
    NSString *sDevice_show_power = [dict objectForKey:KEY_PLUG_POWER];
    if (sDevice_show_power) {
        plug.device_show_power = sDevice_show_power;
    }else{
        plug.device_show_power = @"";
    }
    
    NSString *sDevice_local_ip = [dict objectForKey:KEY_PLUG_LOCAL_IP];
    if (sDevice_local_ip) {
        plug.device_local_ip = sDevice_local_ip;
        plug.device_net_state = EnumDeviceNetStateLocalOnline;
    }else{
        plug.device_local_ip = @"";
        plug.device_net_state = EnumDeviceNetStateLocalOffline;
    }
    
    plug.device_last_updatetime = [NSDate date];
    
    NSArray *timerArray = [dict objectForKey:KEY_PLUG_TIME];
    plug.device_timerlist = [[NSMutableArray alloc]init];
    for (NSDictionary *dict in timerArray) {
        YXMTimerModel *timer = [[YXMTimerModel alloc]init];
        timer.timer_of_device_mac = plug.device_mac_address;
        
        NSString *sTimer_id = [dict objectForKey:KEY_PLUG_ID];
        if (sTimer_id) {
            timer.timer_id = sTimer_id;
        }else{
            timer.timer_id = @"";
        }
        
        NSString *sTimer_start_isuse = [dict objectForKey:KEY_PLUG_OpenEnabled];
        if (sTimer_start_isuse) {
            timer.timer_start_isuse = sTimer_start_isuse;
        }else{
            timer.timer_start_isuse = @"";
        }
        
        NSString *sTimer_start_hour = [dict objectForKey:KEY_PLUG_OpenHours];
        if (sTimer_start_hour) {
            timer.timer_start_hour = sTimer_start_hour;
        }else{
            timer.timer_start_hour = @"";
        }
        
        NSString *sTimer_start_minutes = [dict objectForKey:KEY_PLUG_OpenMinutes];
        if (sTimer_start_minutes) {
            timer.timer_start_minutes = sTimer_start_minutes;
        }else{
            timer.timer_start_minutes = @"";
        }
        
        NSString *sTimer_close_isuse = [dict objectForKey:KEY_PLUG_CloseEnabled];
        if (sTimer_close_isuse) {
            timer.timer_close_isuse = sTimer_close_isuse;
        }else{
            timer.timer_close_isuse = @"";
        }
        
        NSString *sTimer_close_hour = [dict objectForKey:KEY_PLUG_CloseHours];
        if (sTimer_close_hour) {
            timer.timer_close_hour = sTimer_close_hour;
        }else{
            timer.timer_close_hour = @"";
        }
        
        NSString *sTimer_close_minutes = [dict objectForKey:KEY_PLUG_CloseMinutes];
        if (sTimer_close_minutes) {
            timer.timer_close_minutes = sTimer_close_minutes;
        }else{
            timer.timer_close_minutes = @"";
        }
        
        NSString *sTimer_period = [dict objectForKey:KEY_PLUG_Cycle];
        if (sTimer_period) {
            timer.timer_period = sTimer_period;
        }else{
            timer.timer_period = @"";
        }
        
        NSString *sTimer_mark = [dict objectForKey:KEY_PLUG_Remarks];
        if (sTimer_mark) {
            timer.timer_mark = sTimer_mark;
        }else{
            timer.timer_mark = @"";
        }
        
        BOOL bTimer_isactive = [[dict objectForKey:KEY_PLUG_Use] boolValue];
        if (bTimer_isactive) {
            timer.timer_isactive = YES;
        }else{
            timer.timer_isactive = NO;
        }
        
        timer.timer_name = sTimer_id;
        
        [plug.device_timerlist addObject:timer];
    }
    YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
    [db openDatabase];
    YXMDeviceInfoModel *tempData = [db readOneDeviceInfoWithDeviceID:plug.device_id];
    [plug setDevice_name:tempData.device_name];
    [plug setDevice_head:tempData.device_head];
    [db updateDeviceInfoWithObj:plug];
    [self setData:plug];
    [self.delegate cellStateChange:plug andIndex:_currentIndex];
}



/**
 *  通过插座的mac地址去删除数据库里的插座数据
 *
 *  @param plugMac 插座的mac地址
 */
-(BOOL)deletePlugDataWithPlugMac:(NSString *)plugMac{
    return YES;
}

/**
 *  从网络中读取插座等职能设备的信息
 *
 *  @param timer 定时器周期为1.5秒执行
 */
-(void)readSmartDeviceInfoFromNetwork:(NSTimer *)timer{
    if (_data.device_local_ip) {
        if (_data.device_net_state == EnumDeviceNetStateLocalOnline) {
            char IpAddress[30];
            char const *s = [_data.device_local_ip cStringUsingEncoding:NSUTF8StringEncoding];
            memcpy(IpAddress, s, (strlen(s)+1));
            if(IsFormatValid(IpAddress) && IsValueValid(IpAddress))
            {
                [self sendCmdReConfigWithPlugIP:_data.device_local_ip];
            }
        }
        if (_data.device_net_state == EnumDeviceNetStateLocalOffline) {
            DLog(@"_data.device_local_ip = %@",_data.device_local_ip);
            YXMDeviceInfoModel *plug = [[YXMDeviceInfoModel alloc]init];
            YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
            [db openDatabase];
            YXMDeviceInfoModel *tempData = [db readOneDeviceInfoWithDeviceID:_data.device_id];
            [plug setDevice_name:tempData.device_name];
            [plug setDevice_head:tempData.device_head];
            
            plug.device_id = _data.device_id;
            plug.device_state = _data.device_state;//设备的电源状态
            plug.device_net_state = _data.device_net_state;//设备的网络状态
            plug.device_mac_address = _data.device_mac_address;
            plug.device_show_power = _data.device_show_power;
            plug.device_electricity = _data.device_electricity;
            plug.device_open_time = _data.device_open_time;
            plug.device_close_time = _data.device_close_time;
            plug.device_lock = _data.device_lock;
            plug.device_local_ip = _data.device_local_ip;
            plug.device_last_updatetime = _data.device_last_updatetime;
            plug.device_selectIndex = _data.device_selectIndex;//分段选择按钮被选择的索引
            plug.device_timerlist = _data.device_timerlist;
            [self setData:plug];
        }
        if (_data.device_net_state == EnumDeviceNetStateRemoteOnline) {
        }
    
    }
}

/**
 * 读设备内的配置信息,只包含包头
 */
-(void)sendCmdReConfigWithPlugIP:(NSString *)plugIP{
    int byteLength = 56;
    Byte outdate[byteLength];
    memset(outdate, 0x00, byteLength);
    outdate[0]=0x01;//version//版本号目前为1
    outdate[1]=0x01;//type//命令类型1为发送类型,2为应答类型
    outdate[2]=0x03; //cmd//命令字//命令字，不同的调用有不同的命令字
    outdate[3]=0x01;//flags//标志位flags等于1标示需要回复
    outdate[4]=0x38;//len//整个包的长度两个byte
    outdate[8]=0x01;//serial//序列号，用来标识这个包
    outdate[12]=0x5c;//checkCode//检查码
    outdate[13]=0x6c;//checkCode//检查码
    outdate[14]=0x5c;//checkCode//检查码
    outdate[15]=0x6c;//checkCode//检查码
    //MAC地址//低48位为发送端的mac地址，高16位为0
    NSString *tempString = [MyTool readUUID];
    NSString *tempString1 = [tempString substringWithRange:NSMakeRange([tempString length]-12, 12)];
    NSMutableString *localMacString = [[NSMutableString alloc]init];
    for (int i=0; i<[tempString1 length]; i++) {
        if (i!=0) {
            if (i%2==0) {
                [localMacString appendFormat:@":"];
            }
        }
        NSString *macsub = [[tempString1 substringWithRange:NSMakeRange(i, 2)] lowercaseString];
        outdate[(48+i/2)]=strtoul([[NSString stringWithFormat:@"0x%@",macsub] UTF8String],0,0);
        [localMacString appendFormat:@"%@",macsub];
        i++;
    }
    
    NSData *udpPacketData = [[NSData alloc] initWithBytes:outdate length:byteLength];
    DLog(@"读设备内的配置信息,只包含包头 = %@",udpPacketData);
    [_mySocket writeData:udpPacketData withTimeout:-1 tag:1];
    
//    if (!toConvertDataToObjects) {
//        toConvertDataToObjects = [[TDO alloc]init];
//    }
//    NSString *sRemoteMac = nil;
//    if (_data.device_mac_address) {
//        sRemoteMac = _data.device_mac_address;
//    }
//    NSString *sLocalMac = nil;
//    if ([MyTool readLocalMac]) {
//        sLocalMac = [MyTool readLocalMac];
//    }
//
//    NSData *tDOData = [toConvertDataToObjects FindSwitch:sLocalMac andRemoteMac:sRemoteMac andStatus:EnumControlOfRemote andSerial:_data.device_selectIndex];
//    DTLog(@"tDOData = %@",tDOData);
//    [_mySocket writeData:tDOData withTimeout:-1 tag:1];
}



bool IsDigit(char Digit)
{
    bool Flag = false;
    if(Digit >= '0' && Digit <= '9')
    {
        Flag = true;
    }
    return Flag;
}

bool IsFormatValid(char IP[])
{
    int DotCnt = 0;
    bool Flag = false;
    while(*IP != '\0')
    {
        if(*IP == '.')
        {
            DotCnt++;
        }
        else if(!IsDigit(*IP))
        {
            return false;
        }
        Flag = true;
        IP++;
    }
    if(DotCnt == 3)
    {
        return Flag;
    }
    else
    {
        return false;
    }
}

bool IsValueValid(char IP[])
{
//    int Len = 0;
    int Integer = 0;
    while(*IP != '\0')
    {
        if(IsDigit(*IP))
        {
            Integer = Integer*10 + *IP - '0';
        }
        else
        {
            if(Integer > 255)
            {
                return false;
            }
            Integer = 0;
        }
        IP++;
    }
    return true;
}


#pragma mark - 中继开关处理函数
/**
 *  是否开启插座的中继功能
 *
 *  @param apswitch 开关
 */
-(void)updateAPSwitch:(UISwitch *)apswitch{
    
}
@end
