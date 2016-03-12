//
//  TDO.h
//  TDO
//  To convert data to objects
//  Created by lxf on 15/4/17.
//  Copyright (c) 2015年 lxf. All rights reserved.
//
//仅支持真机调试，不支持模拟器
// Only supports device debugging, do not support the simulator
#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    EnumControlOfLocal = 0,
    EnumControlOfRemote
} EnumControl;

@interface TDO : NSObject
/*获得配置数据
 -(NSArray *)SmartConfigSetSSID:(NSString *)ssid andSetPassWord:(NSString *)password;
 传入参数:ssid        WIFI账号   NSString
 password   WIFI密码   NSString
 返回值:NSString类型的IP地址数组 需要转化为NSData发送
 */
/* Obtain configuration data
 -(NSArray *)SmartConfigSetSSID:(NSString *)ssid andSetPassWord:(NSString *)password;
 Incoming Parameters : ssid        WIFI Account   NSS tring
 password   WIFI Password   NSString
 Returning value : the IP address array of NSString type must be transformed into NSData to send
 */

-(NSArray *)SmartConfigSetSSID:(NSString *)ssid andSetPassWord:(NSString *)password;
/*发现设备协议
 -(NSData *)FindSwitch:(NSString *)LocalMac andRemoteMac:(NSString *)RemoteMac andStatus:(int)statusNum andSerial:(int) Serial;
 传入参数：LocalMac  手机端mac  NSString   格式00:00:00:00:00:00
 RemoteMac  设备端mac NSString   格式00:00:00:00:00:00
 statusNum  设备状态  int         本地为0 远程为1
 Serial     序列号    int        用来标识这个包,返回数据与Serial相对应,范围0-65535
 返回值:NSData
 */
/*device protocol discovered
 -(NSData *)FindSwitch:(NSString *)LocalMac andRemoteMac:(NSString *)RemoteMac andStatus:(int)statusNum andSerial:(int) Serial;
 Incoming Parameters：LocalMac  Cellphone mac  NSString
 Format 00:00:00:00:00:00
 RemoteMac  Device mac NSString   Format 00:00:00:00:00:00
 statusNum  Device status  int          on-site 0 off-site 为1
 Serial     Serial Number    int      This is used to identify the package , and the returning data corresponds to Serial corresponds, range 0-65535
 Returning data :NSData
 */
-(NSData *)FindSwitch:(NSString *)LocalMac andRemoteMac:(NSString *)RemoteMac andStatus:(int)statusNum andSerial:(int) Serial;
/*解析设备发现数据
 -(NSDictionary *)SimpleEquipmentData:(NSData *)data;
 传入参数:data  NSData 获取到的设备发现数据  长度必须为96或136 否则返回nil
 返回值:NSDictionary 包含以下数据
 Mac 设备Mac地址 NSString
 Type 设备类型 0插座 int
 Open 开关状态 0关闭 1开启 int
 Lock 锁定 0未锁定  1被锁定 int
 Authority 权限人数 int
 TotalNumber 总人数 int
 Number 在线人数 int
 Serial 序列号，用来标识这个包 int 插座主动发送的设备发现数据为Serial为100
 */
/* Analytical device discovered data
 -(NSDictionary *)SimpleEquipmentData:(NSData *)data;
 Incoming parameters :data  the device acquired by NSData discovered data, length 96 or 136, otherwise return to nil
 Returning value :NSDictionary contain the following data
 Mac device Mac address NSString
 Type device type 0 socket int
 Open socket status 0 off 1on int
 Lock locked 0 unlocked  1 unlocked int
 Authority number with authority int
 Total Number int
 Number online int
 Serial Serial number, to identify this package int socket send voluntarily, device finds the data of serial is 100
 */
-(NSDictionary *)SimpleEquipmentData:(NSData *)data;
/*查询指令协议数据,可查询设备所有信息
 -(NSData *)WriteQuerySwitchData:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *) LocalMac andSerial:(int) Serial;
 传入参数:LocalMac   手机端mac  NSString 格式00:00:00:00:00:00
 RemoteMac  设备端mac  NSString 格式00:00:00:00:00:00
 statusNum  设备状态 int  本地为0 远程为1
 Serial     用来标识这个包 int 返回数据与Serial相对应,范围0-65535
 返回值:NSData
 */
/* Check command protocol data, capable of checking all the data device
 -(NSData *)WriteQuerySwitchData:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *) LocalMac andSerial:(int) Serial;
 Incoming  parameters :Local Mac   Cellphone mac  NSString Format 00:00:00:00:00:00
 RemoteMac  device mac  NSString Format 00:00:00:00:00:00
 statusNum  device status  int  on-site 0 off-site 1
 Serial     This is used to identify the package , and the returning data corresponds to Serial corresponds, range 0-65535
 Returning value :NSData
 */
-(NSData *)WriteQuerySwitchData:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *) LocalMac andSerial:(int) Serial;
/*解析设备所有数据
 -(NSDictionary *)AllEquipmentData:(NSData *)data;
 传入参数:data  NSData 获取到的设备查询数据  长度必须为956或996 否则返回nil
 返回值：NSDictionary 包含以下数据
 Mac 设备Mac地址 NSString
 Open 开关状态 0关闭 1开启
 Lock 锁定状态 int 1上锁  0未锁
 Electricity 用电量 double
 Power 功率 double
 Serial 序列号，用来标识这个包 int
 Time 定时时间列表 NSString 每个元素为 NSDictionary{
 ID 定时id int  0-7
 Use 是否使用该定时 1使用 0不使用
 OpenEnabled 是否启用开启时间 1为启用 0为禁用 int;
 OpenHours 开启小时数 int;
 OpenMinutes 开启分钟数 int;
 CloseEnabled 是否启用关闭时间 1为启用 0为禁用 int;
 CloseHours 关闭小时数 int;
 CloseMinutes 关闭分钟数 int;
 Remarks 备注 NSString;
 Cycle 周期 int 需要转为2进制 11111111为单次 执行完后定时消失 01111111为每天 后7位分别代表日六五四三二一 例如周日周一执行为01000001
 }
 User 定时时间列表 NSString 每个元素为 NSDictionary{
 Admin 管理员 1管理员 0不是 int
 Default  默认权限  0是 1不是 int
 Grade 控制 1可控 0可看 int
 PhoneMac 手机用户mac NSString
 Status 状态 1在线 0离线 int
 }
 */
/*Parse all the device data
 -(NSDictionary *)AllEquipmentData:(NSData *)data;
 Incoming parameter:data the device acquired by NSData discovered data, length 96 or 136, otherwise return to nil
 Returning value：NSDictionary contains the following data
 Mac device Mac address NSString
 Open socket status 0 off  1 on
 Lock locking status int 1locked  0 unlocked
 Electricity Electricity double
 Power power double
 Serial serial number，used to Identify this package int
 Time  timer list  NSString each element NSDictionary{
 ID Timer id int  0-7
 Use whether to use the time  1yes  0 no
 Open Enabled Whether to enable opening time 1 enable 0 disable int;
 OpenHours Open hours  int;
 OpenMinutes open minutes  int;
 CloseEnabled Whether to enable closing time  1 enable 0 disable int;
 CloseHours close hours  int;
 CloseMinutes close minutes int;
 Remarks remarkes NSString;
 Cycle cycle  int needs to be transformed into a binary, each time 11111111
 Timer disappears after being set. each day 01111111 the last seven number represents Sunday, Saturday, Friday, Thursday, Wednesday, Tuesday, Monday. For example, Sunday and Monday being set, 01000001
 }
 User Timer list NSString each element  NSDictionary{
 Admin administrator 1yes 0no  int
 Default  Authority default  0 yes  1 no int
 Grade Control  1 control  0 check  int
 PhoneMac cellphone user mac NSString
 Status status 1 online 0 offline int
 }
 */
-(NSDictionary *)AllEquipmentData:(NSData *)data;

/*控制开关
 -(NSData *)SetGPIOData:(int) onoff andStatus:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *) LocalMac andSerial:(int) Serial;
 传入参数:
 onoff 开关 0关 1开 int
 Status 本地0  远程1  int
 RemoteMac 设备mac地址
 LocalMac 手机mac地址
 Serial 序列号，用来标识这个包 int 0-65535
 */
/*control on/off status
 -(NSData *)SetGPIOData:(int) onoff andStatus:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *) LocalMac andSerial:(int) Serial;
 Incoming parameter:
 onoff on/off 0off 1on  int
 Status on-site 0  off-site 1  int
 RemoteMac device mac address
 LocalMac cellphone mac address
 Serial Serial number，used to identify this package int 0-65535
 */
-(NSData *)SetGPIOData:(int) onoff andStatus:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *) LocalMac andSerial:(int) Serial;

/*控制指令返回数据解析
 -(NSDictionary *)BackEquipmentData:(NSData *)data;
 传入参数:data NSData 控制指令返回的数据 长度为100或60
 返回值:
 Error  int -10000表示密码错误，-10001表示mac地址错误,-10002为校验码错误，-10003为长度错误（长度小于头长度或者整个包的长度和头包含的长度不匹配），-10004为权限检查没通过。其他表示控制成功 并且1表示插座打开 0表示关闭
 Lock 锁定 int 0代表未锁 1代表锁定
 Mac 设备mac地址 NSString
 Serial 序列号，用来标识这个包 int
 */
/* control command returns data analysis
 -(NSDictionary *)BackEquipmentData:(NSData *)data;
 Incoming parameters:data NSData  Control command returns data, length 100 or 60
 Returning value :
 Error  int    -10000 wrong password, -10001 wrong mac address, -10002 wrong security code, -10003 wrong length( the length is short than the length of data head, or the length of the package does not corresponds to the length of the data head ), -10004 authority check failed. otherwise, control succeeded, 1 socket on, 0 socket off.
 
 Lock lock int 0 unlocked 1 locked
 Mac device mac address NSString
 Serial Serial number, used to identify this package int
 */

-(NSDictionary *)BackEquipmentData:(NSData *)data;

/*锁定指令
 -(NSData *)SetLockData:(BOOL) Lock andStatus:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *)LocalMac andSerial:(int) Serial;
 传入参数:
 Lock 锁定 YES锁 NO解锁 BOOL
 Status 本地0  远程1  int
 RemoteMac 设备mac地址
 LocalMac 手机mac地址
 Serial 序列号，用来标识这个包 int 0-65535
 */
/*locking command
 -(NSData *)SetLockData:(BOOL) Lock andStatus:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *)LocalMac andSerial:(int) Serial;
 Incoming parameters:
 Lock lock YES lock NO unlock BOOL
 Status on-site 0  off-site 1  int
 RemoteMac device mac address
 LocalMac local cellphone mac address
 Serial Serial number, used to identify this package int 0-65535
 */
-(NSData *)SetLockData:(BOOL) Lock andStatus:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *)LocalMac andSerial:(int) Serial;

/*设置定时
 -(NSData *)SetTimingControlData:(int) idnumber andWeek:(int) Week andEnableOpenTime:(BOOL) EnableOpenTime andOpenHour:(int) OpenHour andOpenMinute:(int) OpenMinute andEnableCloseTime:(BOOL) EnableCloseTime andCloseHour:(int) CloseHour andCloseMinute:(int) CloseMinute andLabel:(NSString *) label andUse:(int) use andStatus:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *) LocalMac andSerial:(int) Serial;
 传入参数：
 idnumber 定时器id 0-7  int －1为最近空定时器
 Week 定时周期 需要转为10进制 11111111为单次 执行完后定时消失 01111111为每天 后7位分别代表日六五四三二一 例如周日周一执行为01000001 int
 RemoteMac 设备mac地址
 LocalMac 手机mac地址
 Serial 序列号，用来标识这个包 int 0-65535
 EnableOpenTime 是否启用开启时间 YES启用 NO不启用
 OpenHour 开启小时 int
 OpenMinute 开启分钟 int
 EnableCloseTime 是否启用关闭时间 YES启用 NO不启用
 CloseHour 关闭小时 int
 CloseMinute 关闭分钟 int
 label 备注 NSString  有字数限制
 use 是否使用该定时  0为不使用  1为使用
 Status 本地0  远程1  int
 */
/*set timer
 -(NSData *)SetTimingControlData:(int) idnumber andWeek:(int) Week andEnableOpenTime:(BOOL) EnableOpenTime andOpenHour:(int) OpenHour andOpenMinute:(int) OpenMinute andEnableCloseTime:(BOOL) EnableCloseTime andCloseHour:(int) CloseHour andCloseMinute:(int) CloseMinute andLabel:(NSString *) label andUse:(int) use andStatus:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *) LocalMac andSerial:(int) Serial;
 Incoming parameter：
 idnumber Timer id 0-7  int －1 vacant timer lately
 Week timer cycle, needs to be transformed into a binary, each time 11111111
 Timer disappears after being set. each day 01111111 the last seven number represents Sunday, Saturday, Friday, Thursday, Wednesday, Tuesday, Monday. For example, Sunday and Monday being set, 01000001
 
 RemoteMac device mac address
 LocalMac Local cellphone mac address
 Serial Serial number, used to identify this package int 0-65535
 EnableOpenTime whether to enable opening time YES  NO
 OpenHour open hour int
 OpenMinute open minute int
 EnableCloseTime whether to enable closing time YES yes NO no
 CloseHour close hour int
 CloseMinute close minute  int
 label label  NSString  with word limit
 use whether to use this timer  0 no   1 yes
 Status on-site 0  off-site 1  int
 */
-(NSData *)SetTimingControlData:(int) idnumber andWeek:(int) Week andEnableOpenTime:(BOOL) EnableOpenTime andOpenHour:(int) OpenHour andOpenMinute:(int) OpenMinute andEnableCloseTime:(BOOL) EnableCloseTime andCloseHour:(int) CloseHour andCloseMinute:(int) CloseMinute andLabel:(NSString *) label andUse:(int) use andStatus:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *) LocalMac andSerial:(int) Serial;

/*删除定时
 -(NSData *)DeleteTimingControlData:(int) idnumber andStatus:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *) LocalMac andSerial:(int) Serial;
 传入参数:
 idnumber 定时器id 0-7 int
 RemoteMac 设备mac地址 NSString
 LocalMac 手机mac地址 NSString
 Serial 序列号，用来标识这个包 int 0-65535
 Status 本地0  远程1  int
 */
/*delete timer
 -(NSData *)DeleteTimingControlData:(int) idnumber andStatus:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *) LocalMac andSerial:(int) Serial;
 Incoming parameters:
 idnumber timer id 0-7 int
 RemoteMac device mac address NSString
 LocalMac Local cellphone mac address NSString
 Serial Serial number, used to identify this package int 0-65535
 Status on-site 0  off-site 1  int
 */

-(NSData *)DeleteTimingControlData:(int) idnumber andStatus:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *) LocalMac andSerial:(int) Serial;
/*设置管理员
 - (NSData *)setAdminSelfandStatus:(int) Status andRemoteMac:(NSString *)RemoteMac andLocalMac:(NSString *)LocalMac andSerial:(int)Serial;
 传入参数:
 RemoteMac 设备mac地址
 LocalMac 手机mac地址
 Serial 序列号，用来标识这个包 int 0-65535
 Status 本地0  远程1  int
 */
/*set the administrator
 - (NSData *)setAdminSelfandStatus:(int) Status andRemoteMac:(NSString *)RemoteMac andLocalMac:(NSString *)LocalMac andSerial:(int)Serial;
 Incoming parameters :
 RemoteMac device mac address
 LocalMac Local cellphone mac address
 Serial Serial number, used to identify this package  int 0-65535
 Status on-site0  off-site 1  int
 */
- (NSData *)setAdminSelfandStatus:(int) Status andRemoteMac:(NSString *)RemoteMac andLocalMac:(NSString *)LocalMac andSerial:(int)Serial;
/*成为管理员后，设置所有用户的默认权限
 - (NSData *)setUserDefaultControllable:(BOOL)controllable Lookable:(BOOL)look andStatus:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *)LocalMac andSerial:(int)Serial;
 传入参数:
 RemoteMac 设备mac地址
 LocalMac 手机mac地址
 Serial 序列号，用来标识这个包 int 0-65535
 Status 本地0  远程1  int
 controllable  YES  look NO 为默认可控
 controllable  NO  look YES 为默认可看
 */
/* give all user certain default authority after becoming the administrator
 - (NSData *)setUserDefaultControllable:(BOOL)controllable Lookable:(BOOL)look andStatus:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *)LocalMac andSerial:(int)Serial;
 Incoming parameters:
 RemoteMac Device mac address
 LocalMac Mac address of local cellphone
 Serial Serial number, used to identify this package int 0-65535
 Status on-site 0  off-site 1  int
 controllable  YES  look NO with default control function
 controllable  NO  look YES with default check function
 */
- (NSData *)setUserDefaultControllable:(BOOL)controllable Lookable:(BOOL)look andStatus:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *)LocalMac andSerial:(int)Serial;

/*对指定的用户设定权限
 - (NSData *)setUserAuthorityIsControl:(BOOL)controllable lookable:(BOOL)look andStatus:(int)statusNum andRemoteMac:(NSString *)RemoteMac andLocalMac:(NSString *)LocalMac andRemotePhone:(NSString *)phoneMac andSerial:(int)Serial;
 传入参数:
 RemoteMac 设备mac地址
 LocalMac 本机mac地址
 phoneMac 需要设置权限的手机mac地址
 Serial 序列号，用来标识这个包 int 0-65535
 Status 本地0  远程1  int
 controllable  YES  look NO 设置为可控
 controllable  NO  look YES 设置为可看
 */
/*give specific users certain authority
 - (NSData *)setUserAuthorityIsControl:(BOOL)controllable lookable:(BOOL)look andStatus:(int)statusNum andRemoteMac:(NSString *)RemoteMac andLocalMac:(NSString *)LocalMac andRemotePhone:(NSString *)phoneMac andSerial:(int)Serial;
 Incoming parameters:
 RemoteMac device mac address
 LocalMac local cellphone mad address
 phoneMac Mac address of the cellphone asking for authority
 Serial Serial number, used to identify this package int 0-65535
 Status on-site 0  off-site 1  int
 controllable  YES  look NO with control permission
 controllable  NO  look YES with check permission
 */
- (NSData *)setUserAuthorityIsControl:(BOOL)controllable lookable:(BOOL)look andStatus:(int)statusNum andRemoteMac:(NSString *)RemoteMac andLocalMac:(NSString *)LocalMac andRemotePhone:(NSString *)phoneMac andSerial:(int)Serial;

//设置插座时间为手机时间
/*
 RemoteMac 设备mac地址
 LocalMac 手机mac地址
 Serial 序列号，用来标识这个包 int 0-65535
 Status 本地0  远程1  int
 */

-(NSData *)SetPhoneTimeToSwitch:(int) Status andRemoteMac:(NSString *) RemoteMac andLocalMac:(NSString *)LocalMac andSerial:(int)Serial;
@end
