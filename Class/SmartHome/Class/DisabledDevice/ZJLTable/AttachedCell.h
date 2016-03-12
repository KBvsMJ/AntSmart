//
//  AttachedCell.h
//  NT
//
//  Created by Kohn on 14-5-27.
//  Copyright (c) 2014年 Pem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <STAlertView/STAlertView.h>
#import "ZJLViewController.h"
#import "YXMDeviceEntity.h"

@interface AttachedCell : UITableViewCell<UIAlertViewDelegate>
{
    UIButton *b2;
}
@property (retain, nonatomic) UIImageView *imageLine;
@property (retain,nonatomic) NSString *device_id;
@property (retain,atomic) NSString *device_ip;
@property (nonatomic, strong) STAlertView *stAlertView;
@property (nonatomic,strong) ZJLViewController *ctrl;

-(void)setDeviceData:(YXMDeviceEntity *)deviceEntity;
@end


