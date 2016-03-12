//
//  AttachedCell.m
//  NT
//
//  Created by Kohn on 14-5-27.
//  Copyright (c) 2014年 Pem. All rights reserved.
//

#import "AttachedCell.h"
#import "UIButton+Create.h"
#import "Config.h"
#import "YXMDatabaseOperation.h"
#import "IPHelpler.h"
#import <iToast/iToast.h>

#define TAG_DISABLE_DEVICE_ALERT_VIEW 100090 //禁用设备
#define TAG_ENABLE_DEVICE_ALERT_VIEW 100095 //解禁设备

@implementation AttachedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //分割线
        _imageLine = [[UIImageView alloc]initWithFrame:CGRectMake(60, 39, SCREEN_CGSIZE_WIDTH-60, 1)];
        [self.contentView addSubview:_imageLine];
        
        UIButton *b1 = [UIButton createButtonWithFrame:CGRectMake(70, 9, 50, 20) Title:@"命名" Target:self Selector:@selector(btnAction:)];
        
        b1.tag = 100;
        
        b2 = [UIButton createButtonWithFrame:CGRectMake(130, 9, 50, 20) Title:@"禁用" Target:self Selector:@selector(btnAction:)];
        b2.tag = 200;
        
        UIButton *b3 = [UIButton createButtonWithFrame:CGRectMake(190, 9, 50, 20) Title:@"限速" Target:self Selector:@selector(btnAction:)];
        b3.tag = 300;
        
        UIButton *b4 = [UIButton createButtonWithFrame:CGRectMake(250, 9, 50, 20) Title:@"详情" Target:self Selector:@selector(btnAction:)];
        
        b4.tag = 400;
        
        [self.contentView addSubview:b1];
//        YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
//        NSString *deviceip = [db getDeviceIPWithDeviceID:self.device_id];
//        NSString *localip = [IPHelpler localIP];
//        DLog(@"deviceip = %@,localip = %@",deviceip,localip);
//        if (![deviceip isEqualToString:localip]) {
            [self.contentView addSubview:b2];
//        }
        
//        [self.contentView addSubview:b3];
//        [self.contentView addSubview:b4];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}


- (void)btnAction:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 100:
        {
            __block NSString *nickname = @"";
            __block YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
            [db openDatabase];
            DLog(@">>>>>>>>>>重命名%@",self.device_id);
            self.stAlertView = [[STAlertView alloc]initWithTitle:@"请输入设备名称" message:@"" textFieldHint:@"" textFieldValue:@"" cancelButtonTitle:[Config DPLocalizedString:@"cancel"] otherButtonTitle:[Config DPLocalizedString:@"sure"] cancelButtonBlock:^{
                
            } otherButtonBlock:^(NSString *result) {
                DLog(@"result = %@",result);
                if (result) {
                    if ([result length]>1) {
                        [db updateDeviceNickname:result withId:self.device_id];
                    }
                }
                
                [self.ctrl reloadTableView];
                
            }];
            [self.stAlertView show];
            
        }
            break;
        case 200:
        {
            DLog(@"准备禁用或解禁设备");
            YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
            [db openDatabase];
            if ([db getOneFileterWithMacAddress:self.device_id]) {
                //解禁设备
                UIAlertView *disableDeviceAlert = [[UIAlertView alloc]initWithTitle:@"确定要解禁设备么？" message:[NSString stringWithFormat:@"点击确定后将解禁MAC地址为%@的设备，设备会自动重启，稍后请手动重新连接WiFi。",self.device_id] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [disableDeviceAlert setTag:TAG_ENABLE_DEVICE_ALERT_VIEW];
                [disableDeviceAlert show];
            }else{
                UIAlertView *disableDeviceAlert = [[UIAlertView alloc]initWithTitle:@"确定要禁用设备么？" message:@"点击确定后路由器将自动重启，稍后请手动重新连接WiFi。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [disableDeviceAlert setTag:TAG_DISABLE_DEVICE_ALERT_VIEW];
                [disableDeviceAlert show];
            }
            
        }
            break;
        case 300:
        {
            NSLog(@">>>>>>>>>>图片");
        }
            break;
        case 400:
        {
            NSLog(@">>>>>>>>>>表情");
        }
            break;
        case 500:
        {
            NSLog(@">>>>>>>>>>文件");
        }
            break;
            
        default:
            break;
    }
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == TAG_DISABLE_DEVICE_ALERT_VIEW) {
        if (buttonIndex == 1) {
            DLog(@"确定禁用设备");
            YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
            [db openDatabase];
            NSSet *usingCurNumSet = [db isUsingCurNum];
            if ([usingCurNumSet count]>10) {
                [[[iToast makeText:NSLocalizedString(@"禁用设备最多支持10台,已经超出了限制,请先解禁一台设备后再试", @"")]
                  setGravity:iToastGravityCenter] show:iToastTypeError];
            }else{
                [db disableDeviceWithMacAddress:self.device_id];
                [[[iToast makeText:NSLocalizedString(@"禁用设备成功,局域网内的客户端将断开重连！", @"")]
                  setGravity:iToastGravityCenter] show:iToastTypeError];
            }
        }
    }
    if (alertView.tag == TAG_ENABLE_DEVICE_ALERT_VIEW) {
        if (buttonIndex ==1) {
            DLog(@"确定解禁设备");
            YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
            [db openDatabase];
            [db enableDeviceWithMacAddress:self.device_id];
            [[[iToast makeText:NSLocalizedString(@"解禁设备成功,局域网内的客户端将断开重连！", @"")]
              setGravity:iToastGravityCenter] show:iToastTypeError];
        }
    }
}


-(void)setDeviceData:(YXMDeviceEntity *)deviceEntity{
    YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
    [db openDatabase];
    NSString *device_ip = [db getDeviceIPWithDeviceID:deviceEntity.device_id];
    NSString *localip = [IPHelpler localIP];
    DLog(@"deviceip = %@,localip = %@",device_ip,localip);

    [b2 setHidden:[device_ip isEqualToString:localip]];
    if ([db getOneFileterWithMacAddress:deviceEntity.device_id]) {
        [b2 setTitle:@"解禁" forState:UIControlStateNormal];
    }else{
        [b2 setTitle:@"禁用" forState:UIControlStateNormal];
    }

}
@end


