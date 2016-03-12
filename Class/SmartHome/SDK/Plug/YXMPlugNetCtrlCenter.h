//
//  YXMPlugNetCtrlCenter.h
//  SmartHome
//  插座网络通信控制中心
//  Created by iroboteer on 15/5/4.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "AsyncSocketReceiveBroadcast.h"
@class TDO;
@class YXMTimerModel;
@class YXMDeviceInfoModel;

@interface YXMPlugNetCtrlCenter : NSObject<AsyncSocketDelegate>
{

    //监听广播
    AsyncSocketReceiveBroadcast *_myBroadcast;
    //网络数据格式化
    TDO *toConvertDataToObjects;
    //同步时间
    BOOL isSynchronousTime;
    //网络处理对象
    NSMutableDictionary *_socketObjectDict;
}
@property (strong,nonatomic) NSMutableDictionary *socketObjectDict;
/**
 * 启动广播监听和网络通信对象
 */
-(void)start;

/**
 * 读设备内的配置信息,只包含包头
 */
-(void)sendCmdReConfigWithPlugIP:(NSString *)plugIP;


/**
 *  使插座的时间与手机的时间同步
 */
-(void)sendCmdSettingPlugClockWithPlugIP:(NSString *)plugIP;


/**
 *  打开或者关闭插座的继电器开关
 */
-(void)sendCmdOpenOrClosePower:(YXMDeviceInfoModel *)oneData;

/**
 *  通过插座的mac地址去删除数据库里的插座数据
 *
 *  @param plugMac 插座的mac地址
 */
-(BOOL)deletePlugDataWithPlugMac:(NSString *)plugMac;

/**
 *  发送查询远程设备的命令
 */
-(void)sendCmdRemoteReConfig;

/**
 *  读取所有的插座的信息，通过本地存储的IP
 */
-(void)snedReconfigWithAllIP;
@end
