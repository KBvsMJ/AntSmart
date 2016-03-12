//
//  HADeviceCollectionViewCell.h
//  Paper
//
//  Created by iroboteer on 15/3/14.
//  Copyright (c) 2015年 Heberti Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXMDeviceInfoModel.h"
#import "RFSegmentView.h"
#import "HACollectionViewLargeLayout.h"
#import "HACollectionViewSmallLayout.h"
#import "UUChart.h"
#import "AsyncSocket.h"
#import "IGLDropDownMenu.h"

@class TDO;
@class YXMTimerModel;
@class YXMDeviceInfoModel;

@class STAlertView;

@protocol CellStateChangeDelegate <NSObject>

/**
 *  开关按钮状态改变时的处理方法
 *
 *  @param oneData 状态改变的数据
 *  @param index   对应的索引
 */
-(void)cellStateChange:(YXMDeviceInfoModel *)oneData andIndex:(NSIndexPath *)index;
/**
 *  根据索引去删除设备单元视图
 *
 *  @param currentCellIndexPath 当前视图的索引
 */
-(void)deleteDeviceCell:(NSIndexPath *)currentCellIndexPath;

@end

@interface HADeviceCollectionViewCell : UICollectionViewCell<RFSegmentViewDelegate,UITableViewDelegate,UITableViewDataSource,UUChartDataSource,UITextFieldDelegate,UIAlertViewDelegate,AsyncSocketDelegate>
{
    //item的布局
    HACollectionViewLargeLayout *_largeLayout;
    //设备头像
    UIImageView *_deviceHeadImageView;
    //关闭按钮
    UIButton *_deviceCloseButton;
    //设备的名称
    UILabel *_deviceNameLabel;

    //设备的电源状态和网络状态
    NSDictionary *_styleOfDevicePowerStateAndNetStateLabel;
    UILabel *_devicePowerStateAndNetStateLabel;
    
    //分段控制器
    RFSegmentView* _segmentView;
    
    //开关控制
    UIView *_controlView;
    //定时控制
    UIView *_timerView;
    
    //电量统计
    UIView *_coulometryView;
    //电量统计柱状图
    UUChart *_chartView;
    //电量统计图选择的类型
    NSInteger _chartTypeIndex;
    //显示电量统计的当前日期的标签
    UILabel *_statisticsLabel;
    
    //更多视图
    UIView *_moreView;
    //开关按钮
    UIButton *_swithButton;
    //当前功率
    UILabel *_currentKWLabel;
    //定时列表
    UITableView *_timerTableView;
    
    //当前cell的索引
    NSIndexPath *_currentIndex;
    //缩小的布局
    HACollectionViewSmallLayout *_smallLayout;
    //插座信息对象
    YXMDeviceInfoModel *_data;
    //当前视图是否是大视图
    BOOL _isLargeView;
    //当前视图的frame
    CGRect myFrame;
    
    //网络连接对象
    AsyncSocket *_mySocket;
    //网络数据格式化
    TDO *toConvertDataToObjects;
    //同步时间
    BOOL isSynchronousTime;
    //读取设备信息的定时器
    NSTimer *_readSmartDeviceInfoTimer;
}
@property (weak,nonatomic) id<CellStateChangeDelegate> delegate;
@property (strong,nonatomic) NSIndexPath *currentIndex;
@property (strong,nonatomic) YXMDeviceInfoModel *data;
//修改插座的名称
@property (strong,nonatomic) STAlertView *changeNameAlertView;

/**
 *  Enable this to rotate the views behind the top view. Default to YES.
 */
@property (nonatomic) BOOL isRotationEnabled;
/**
 *  Magnitude of the rotation in degrees
 */
@property (nonatomic) float rotationDegree;
/**
 *  Relative vertical offset of the center of rotation. From 0 to 1. Default to 0.3.
 */
@property (nonatomic) float rotationRelativeYOffsetFromCenter;
/**
 *  Magnitude in points per second.
 */
@property (nonatomic) CGFloat escapeVelocityThreshold;

@property (nonatomic) CGFloat relativeDisplacementThreshold;
/**
 *  Magnitude of velocity at which the swiped view will be animated.
 */
@property (nonatomic) CGFloat pushVelocityMagnitude;
/**
 *  Center of swipable Views. This property is animated.
 */
@property (nonatomic) CGPoint swipeableViewsCenter;
/**
 *  Swiped views will be destroyed when they collide with this Rect
 */
@property (nonatomic) CGRect collisionRect;
/**
 *  Mangintude of rotation for swiping views manually
 */
@property (nonatomic) CGFloat manualSwipeRotationRelativeYOffsetFromCenter;


-(void)setSmallCellViewLayout;
-(void)setLargeCellViewLayout;
@end
