//
//  YXMDatabaseOperation.h
//  SmartHome
//
//  Created by iroboteer on 15/4/18.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "YXMMacFilterObject.h"
@class YXMDeviceInfoModel;
@class YXMTimerModel;
@class YXMMyRouterModel;
@class YXMPushNotiModel;

@interface YXMDatabaseOperation : NSObject
-(BOOL)openDatabase;
+(YXMDatabaseOperation *)sharedManager;

-(BOOL)excuteSqlString:(NSString *)sqlString;


/**
 *  查询所有设备列表
 *
 *  @return 返回设备列表数组
 */
-(NSArray *)selectAllDeviceListWithRouterID:(NSString *)routerID;
/**
 *  更新设备的别名
 *
 *  @param name     别名
 *  @param deviceid 设备编号也就是mac地址
 *
 *  @return 返回更新结果
 */
-(BOOL)updateDeviceNickname:(NSString *)name withId:(NSString *)deviceid;
/**
 *  更新在线状态
 *
 *  @param state     设备在线状态
 *  @param deviceid  设备编号也就是mac地址
 *
 *  @return 返回更新结果
 */
-(BOOL)updateDeviceOnline:(NSString *)state withId:(NSString *)deviceid;

/**
 *  查询设备是否已经在本地存在
 *
 *  @param deviceid 设备的编号也就是mac地址
 *
 *  @return 返回是否查询到结果的布尔值
 */
-(BOOL)deviceExistWithDeviceID:(NSString *)deviceid;

/**
 *  查询已经被使用的过滤通道
 *
 *  @return 返回已经被使用的过滤通道集合
 */
-(NSSet *)isUsingCurNum;

/**
 *  通过mac地址去禁用设备上网
 *
 *  @param macAddress 设备的mac地址
 */
-(void)disableDeviceWithMacAddress:(NSString *)macAddress;


/**
 *  通过设备的mac地址查询设备的ip地址
 *
 *  @param deviceID 设备mac地址
 *
 *  @return 设备ip地址
 */
-(NSString *)getDeviceIPWithDeviceID:(NSString *)deviceID;

/**
 *  通过mac地址获得mac过滤项的对象
 *
 *  @param macAddress mac地址
 */
-(YXMMacFilterObject *)getOneFileterWithMacAddress:(NSString *)macAddress;

/**
 *  根据通道去删除mac过滤项目
 *
 *  @param channel 通道数
 *
 *  @return 返回是否删除成功
 */
-(BOOL)deleteFilterWithChannel:(NSString *)channel;

/**
 *  解禁设备的mac地址过滤
 *
 *  @param macAddress mac地址
 *
 *  @return 是否成功解禁
 */
-(void)enableDeviceWithMacAddress:(NSString *)macAddress;

/**
 *  存储插座设备信息到本地数据库中
 *
 *  @param model 插座数据对象
 */
-(BOOL)savePlugDeviceWithModelData:(YXMDeviceInfoModel *)model;

/**
 *  更新或者插入定时器数据
 *
 *  @param timer 定时器对象
 *
 *  @return 是否更新数据成功
 */
-(BOOL)replaceOrInsertTimerWithData:(YXMTimerModel *)timer;

/**
 *  查询本地以及配置的所有插座数据
 *
 *  @return 插座数据集
 */
-(NSArray*)readAllPlugData;

/**
 *  更新设备的别名
 *
 *  @param deviceMac 通过设备的mac地址去判断
 */
-(BOOL)updateSmartDeviceNickname:(NSString*)deviceName WithDeviceMac:(NSString *)deviceMac;

/**
 *  设置所有设备为离线状态
 */
-(BOOL)setAllDeviceNetStateWithOffline;

/**
 *  更新设备电源状态
 *
 *  @param data 设备数据对象
 *
 *  @return 更新成功与否
 */
-(BOOL)updatedevicePowerState:(YXMDeviceInfoModel *)data;

/**
 *  读取已经添加的设备的数量
 *
 *  @return 设备数量
 */
-(NSInteger)readDeviceCount;

/**
 *  通过插座的mac地址去删除数据库里的插座数据
 *
 *  @param plugMac 插座的mac地址
 */
-(BOOL)deletePlugDataWithPlugMac:(NSString *)plugMac;


/**
 *  通过设备的mac地址查询数据库中是否有此设备了
 *
 *  @param macAddress mac地址
 *
 *  @return 返回是否查询到了
 */
-(BOOL)findDataWithDeviceMac:(NSString *)macAddress;

/**
 *  使用设备的mac与ip去判断数据是否存在,如果不存在，则证明设备的ip地址已经做了更改了，需要更新设备的ip地址
 *
 *  @param ipAddress  设备的ip地址
 *  @param macAddress 设备的mac地址
 *
 *  @return 返回是否查询到数据
 */
-(BOOL)findDataWithDeviceIPAndMac:(NSString *)ipAddress andMac:(NSString *)macAddress;


/**
 *  根据设备的mac地址去更新设备的ip地址
 *
 *  @param ipAddress  设备的ip地址
 *  @param macAddress 设备的mac地址
 *
 *  @return 更新是否成功的返回值
 */
-(BOOL)updateDeviceLocalIP:(NSString *)ipAddress andMacAddress:(NSString *)macAddress;


/**
 *  更新设备信息到数据库
 *
 *  @param model 设备数据对象
 *
 *  @return 返回是否更新成功
 */
-(BOOL)updateDeviceInfoWithObj:(YXMDeviceInfoModel *)model;


/**
 *  根据设备的mac地址去查询数据库中的设备信息
 *
 *  @param deviceid 设备的mac地址
 *
 *  @return 设备的信息对象
 */
-(YXMDeviceInfoModel *)readOneDeviceInfoWithDeviceID:(NSString *)deviceid;

/**
 *  保存管理过的路由器的信息到数据库
 *
 *  @param routerObj 路由器对象
 *
 *  @return 返回是否保存成功
 */
-(BOOL)saveMyRouterWithObj:(YXMMyRouterModel *)model;


#pragma mark -推送通知相关
/**
 *  保存推送过来的数据
 *
 *  @param model 推送消息数据
 *
 *  @return 是否保存成功
 */
-(BOOL)savePushData:(YXMPushNotiModel *)model;

/**
 *  通过推送消息的id去删除本地数据
 *
 *  @param 推送消息的id
 *
 *  @return 返回是否删除成功
 */
-(BOOL)deletePushMsgWithMsgID:(NSString *)msgid;

/**
 *  更新推送通知的阅读状态为已经阅读
 *
 *  @param msgid 推送通知的编号
 *
 *  @return 是否更新成功
 */
-(BOOL)updatePushDataToReadWithPushMsgID:(NSString *)msgid;

/**
 *  查询本地存储的所有推送通知
 *
 *  @return 返回的推送通知对象数组
 */
-(NSArray *)selectAllPushMsgData;

/**
 *  通过插座的mac地址和定时器编号去删除数据库里的插座的定时数据
 *
 *  @param plugMac 插座的mac地址
 */
-(BOOL)deleteTimerDataWithPlugMac:(NSString *)timerid andMac:(NSString *)pmac;
@end
