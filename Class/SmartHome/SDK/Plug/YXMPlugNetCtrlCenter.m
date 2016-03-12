//
//  YXMPlugNetCtrlCenter.m
//  SmartHome
//
//  Created by iroboteer on 15/5/4.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMPlugNetCtrlCenter.h"
#import "MyTool.h"
#import "TDO.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "YXMDeviceInfoModel.h"
#import "YXMTimerModel.h"
#import "YXMDatabaseOperation.h"
#import "YXMDeviceInfoModel.h"
#import "YXMDeviceInfoModel.h"
#import "Config.h"

@implementation YXMPlugNetCtrlCenter

@synthesize socketObjectDict = _socketObjectDict;


#pragma mark - AsyncSocketDelegateMethod


- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    DNetLog(@"已经连接%s %d", __FUNCTION__, __LINE__);
    NSString *sPlugIP = [sock connectedHost];
    if ([[_socketObjectDict allKeys] indexOfObject:sPlugIP]!=NSNotFound) {
        AsyncSocket *sendSocket = [_socketObjectDict objectForKey:sPlugIP];
        if (sendSocket) {
            [sendSocket readDataWithTimeout: -1 tag: 0];
        }
    }
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    DNetLog(@"写数据完成%s %d, tag = %ld", __FUNCTION__, __LINE__, tag);

    
    NSString *sPlugIP = [sock connectedHost];
    if ([[_socketObjectDict allKeys] indexOfObject:sPlugIP]!=NSNotFound) {
        AsyncSocket *sendSocket = [_socketObjectDict objectForKey:sPlugIP];
        if (sendSocket) {
            [sendSocket readDataWithTimeout: -1 tag: tag];
        }
    }
}

// 这里必须要使用流式数据
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *sPlugIP = [sock connectedHost];
    DLog(@"返回的数据 tag=%ld,sPlugIP=%@",tag,sPlugIP);

    if ([[_socketObjectDict allKeys] indexOfObject:sPlugIP]!=NSNotFound) {
        AsyncSocket *sendSocket = [_socketObjectDict objectForKey:sPlugIP];
        if (sendSocket) {
            [sendSocket readDataWithTimeout: -1 tag: tag];
        }
    }
    
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
    DNetLog(@"返回的数据 tag=%ld,sPlugIP=%@",tag,sPlugIP);
    if ([[_socketObjectDict allKeys] indexOfObject:sPlugIP]!=NSNotFound) {
        AsyncSocket *sendSocket = [_socketObjectDict objectForKey:sPlugIP];
        [sendSocket runLoopModes];
        [sendSocket setDelegate:nil];
        [sendSocket disconnect];
        [_socketObjectDict removeObjectForKey:sPlugIP];
    }
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    DNetLog(@"%s %d", __FUNCTION__, __LINE__);
    NSString *sPlugIP = [sock connectedHost];
    DNetLog(@"返回的数据 tag=%ld,sPlugIP=%@",tag,sPlugIP);
    if ([[_socketObjectDict allKeys] indexOfObject:sPlugIP]!=NSNotFound) {
        AsyncSocket *sendSocket = [_socketObjectDict objectForKey:sPlugIP];
        [sendSocket runLoopModes];
        [sendSocket setDelegate:nil];
        [sendSocket disconnect];
        [_socketObjectDict removeObjectForKey:sPlugIP];
    }

    
}

/**
 *  开启广播监听
 */
-(void)initBrodcast{
    if (!_socketObjectDict) {
        _socketObjectDict = [[NSMutableDictionary alloc]init];
    }
    if (!_globalDeviceLocalIPArray) {
        _globalDeviceLocalIPArray = [[NSMutableArray alloc]init];
    }
    @try {
        _myBroadcast = [AsyncSocketReceiveBroadcast sharedManager];
        BOOL startReceive = [_myBroadcast initReceivePlayerBroadcastIp:^(NSString *smartDeviceIP){
        }];
        DTLog(@"%d",startReceive);
    }
    @catch (NSException *exception) {
        DNetLog(@"广播异常 = %@",exception);
    }
    @finally {
        
    }
}

/**
 *  启动网络连接
 */
-(void)startSocket{
    @try {
        for (NSString *sIPAddress in _globalDeviceLocalIPArray) {
            if (![_socketObjectDict objectForKey:sIPAddress]) {
                AsyncSocket *socket = [[AsyncSocket alloc]initWithDelegate:self];
                [socket connectToHost:sIPAddress onPort:PORT_OF_GET_SERVICE_IP withTimeout:-1 error:nil];
                [socket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
                [_socketObjectDict setObject:socket forKey:sIPAddress];
            }
        }
    }
    @catch (NSException *exception) {
        DNetLog(@"启动网络连接 = %@",exception);
    }
    @finally {
        
    }
    
}

/**
 * 启动广播监听和网络通信对象
 */
-(void)start{
    [self initBrodcast];
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
    if ([[_socketObjectDict allKeys] indexOfObject:plugIP]!=NSNotFound) {
        AsyncSocket *sendSocket = [_socketObjectDict objectForKey:plugIP];
        if (sendSocket) {
            [sendSocket writeData:udpPacketData withTimeout:-1 tag:1];
        }
    }
}

/**
 *  发送查询远程设备的命令
 */
-(void)sendCmdRemoteReConfig{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *sRemoteMac = [ud objectForKey:KEY_PLUG_MAC];
    NSString *sLocalMac = [MyTool readLocalMac];
        if (sRemoteMac) {
        if (!toConvertDataToObjects) {
            toConvertDataToObjects = [[TDO alloc]init];
        }
        NSData *udpPacketData = [toConvertDataToObjects FindSwitch:sLocalMac andRemoteMac:sRemoteMac andStatus:1 andSerial:4];
        DNetLog(@"查询远程的插座的命令 = %@",udpPacketData);
//        [_sendPlayerSocket writeData:udpPacketData withTimeout:-1 tag:5];
    }
}


-(void)savePlugInfoToDatabaseWithDict:(NSDictionary *)dict{
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    NSString *sRemoteMac = [dict objectForKey:KEY_PLUG_MAC];
//    if (sRemoteMac) {
//        [ud setObject:sRemoteMac forKey:KEY_PLUG_MAC];
//    }
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
        if ([[_socketObjectDict allKeys] indexOfObject:plugIP]!=NSNotFound) {
            AsyncSocket *sendSocket = [_socketObjectDict objectForKey:plugIP];
            if (sendSocket) {
                [sendSocket writeData:udpPacketData withTimeout:-1 tag:1];
            }
        }
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
        NSString *sPlugIP = oneData.device_local_ip;
        if ([[_socketObjectDict allKeys] indexOfObject:sPlugIP]!=NSNotFound) {
            AsyncSocket *sendSocket = [_socketObjectDict objectForKey:sPlugIP];
            if (sendSocket) {
                [sendSocket writeData:udpPacketData withTimeout:-1 tag:6];
            }
        }
        
    }
}

/**
 *  保存插座数据到数据库
 *
 *  @param dict 插座数据的字典
 */
-(void)savePlugData:(NSDictionary *)dict{
    YXMDeviceInfoModel *plug = [[YXMDeviceInfoModel alloc]init];
//    plug.device_head = @"virtual_device";
//    plug.device_name = @"Smart Plug";
    plug.device_net_state = EnumDeviceNetStateLocalOnline;
    
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
    }else{
        plug.device_local_ip = @"";
    }
    
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
    [db savePlugDeviceWithModelData:plug];
}

/**
 *  读取所有的插座的信息，通过本地存储的IP
 */
-(void)snedReconfigWithAllIP{
    NSArray *allDeviceIPArray = [_socketObjectDict allKeys];
    for (NSString *deviceIP in allDeviceIPArray) {
        [self sendCmdReConfigWithPlugIP:deviceIP];
    }
    if ([allDeviceIPArray count]<1) {
        YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
        [db openDatabase];
        [db setAllDeviceNetStateWithOffline];
    }
}

/**
 *  通过插座的mac地址去删除数据库里的插座数据
 *
 *  @param plugMac 插座的mac地址
 */
-(BOOL)deletePlugDataWithPlugMac:(NSString *)plugMac{
    return YES;
}
@end
