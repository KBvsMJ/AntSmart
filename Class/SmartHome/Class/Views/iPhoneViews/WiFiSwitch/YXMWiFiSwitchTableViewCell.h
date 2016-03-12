//
//  YXMWiFiSwitchTableViewCell.h
//  SmartHome
//  用于用户远程或局域网内关闭路由器的wifi功能，必须先开启远程控制之后才能关闭wifi，否则关闭了wifi之后将无法开启；
//  Created by iroboteer on 15/6/25.
//  Copyright (c) 2015年 iroboteer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YXMWiFiSwitchTableViewCell : UITableViewCell
{
    UILabel *_promptLabel;
    UISwitch *_wifiSwitch;
}
-(UIView*)getCellView;
+(CGFloat)getCellWidth;

+(CGFloat)getCellHeight;
@end
