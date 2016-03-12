//
//  AsyncSocketReceiveBroadcast.h
//  接收插座端的广播信息，从广播中得到基本的信息，如果设备的ip地址，设备的mac地址，设备的开关状态
//
//  Created by Yixingman on 13-11-28.
//
//

#import "AsyncSocketReceiveBroadcast.h"
#import "TDO.h"
#import "MyTool.h"


#define FORMAT(format,...)[NSString stringWithFormat:(format),##__VA_ARGS__]

@interface AsyncSocketReceiveBroadcast ()
{
    GCDAsyncUdpSocket *_udpSocket;
}

@end

@implementation AsyncSocketReceiveBroadcast
@synthesize broadcastBlock = _broadcastBlock;


+ (AsyncSocketReceiveBroadcast *)sharedManager
{
    static AsyncSocketReceiveBroadcast *sharedAsyncSocketReceiveBroadcastInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAsyncSocketReceiveBroadcastInstance = [[self alloc] init];
    });
    return sharedAsyncSocketReceiveBroadcastInstance;
}


-(BOOL)initReceivePlayerBroadcastIp:(ReceiveBroadcastBlock)block
{
    self.broadcastBlock = block;
    return [self startUDPSocket];
}

-(BOOL)startUDPSocket{
    @try {
        if (!_udpSocket) {
            _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
            
            int port = PORT_OF_GET_SERVICE_IP;
            NSError *error = nil;
            BOOL bindAndRecResult = NO;
            bindAndRecResult = [_udpSocket bindToPort:port error:&error];
            if (error) {
                DNetLog(@"%@",FORMAT(@"Error bindToPort server (recv): %@", error));
            }
            if (bindAndRecResult) {
                bindAndRecResult = [_udpSocket beginReceiving:&error];
                if (error) {
                    [_udpSocket close];
                    DNetLog(@"%@",FORMAT(@"Error starting server (recv): %@", error));
                }
            }
            if(!bindAndRecResult){
                self.broadcastBlock(nil);
            }
            return bindAndRecResult;
        }else{
            return YES;
        }
    }
    @catch (NSException *exception) {
        DNetLog(@"exception = %@",exception);
    }
    @finally {
        
    }
}


-(void)closeUDPSocket{
    [_udpSocket close];
}



-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{
    self.broadcastBlock(nil);
    if (error) {
        DLog(@"%@",FORMAT(@"Error didNotConnect : %@", error));
    }
}

-(void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    self.broadcastBlock(nil);
    if (error) {
        DLog(@"%@",FORMAT(@"Error udpSocketDidClose : %@", error));
    }
}


-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{

}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    DLog(@"address = %@",[[NSString alloc] initWithData:address encoding:NSUTF8StringEncoding]);
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    if (error) {
        self.broadcastBlock(nil);
        DLog(@"%@",FORMAT(@"Error didNotSendDataWithTag : %@", error));
    }
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *sHostIP = nil;
    uint16_t iPort = 0;
    [GCDAsyncUdpSocket getHost:&sHostIP port:&iPort fromAddress:address];
    if (sock.localPort == PORT_OF_GET_SERVICE_IP) {
        if (!toConvertDataToObjects) {
            toConvertDataToObjects = [[TDO alloc]init];
        }
        //过滤ip地址
        NSString *sIPAddress = [MyTool filterIPAddress:sHostIP];
        //在接受的广播中包含的信息
        NSMutableDictionary *findDict = [[NSMutableDictionary alloc]initWithDictionary:[toConvertDataToObjects SimpleEquipmentData:data]];
        DTLog(@"findDict = %@",findDict);
        //将发送信息的设备的ip地址附加到信息中
        if (sIPAddress) {
            [findDict setObject:sIPAddress forKey:KEY_PLUG_LOCAL_IP];
        }
        //接受到网络上的信息后通知主界面的处理函数
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_NEW_DEVICE_INSERT object:nil userInfo:findDict];
    }
	[_udpSocket sendData:data toAddress:address withTimeout:-1 tag:0];
}

@end
