//
//  AsyncSocketReceiveBroadcast.h
//  接收插座端的广播信息，从广播中得到基本的信息，如果设备的ip地址，设备的mac地址，设备的开关状态
//
//  Created by Yixingman on 13-11-28.
//
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
@class TDO;

typedef void (^ReceiveBroadcastBlock)(NSString *smartDeviceIP);

@interface AsyncSocketReceiveBroadcast : NSObject<GCDAsyncUdpSocketDelegate>
{
    ReceiveBroadcastBlock _playerBroadcastBlock;
    //网络数据格式化
    TDO *toConvertDataToObjects;
}
+ (AsyncSocketReceiveBroadcast *)sharedManager;
@property (nonatomic, strong) ReceiveBroadcastBlock broadcastBlock;
-(BOOL)initReceivePlayerBroadcastIp:(ReceiveBroadcastBlock)block;
-(BOOL)startUDPSocket;
-(void)closeUDPSocket;
@end
