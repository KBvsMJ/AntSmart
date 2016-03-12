//
//  YXMWiFiSwitchTableViewCell.h
//  SmartHome
//  用于用户远程或局域网内关闭路由器的wifi功能，必须先开启远程控制之后才能关闭wifi，否则关闭了wifi之后将无法开启；
//  Created by iroboteer on 15/6/25.
//  Copyright (c) 2015年 iroboteer. All rights reserved.
//

#import "YXMWiFiSwitchTableViewCell.h"

@implementation YXMWiFiSwitchTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *cellView = [self getCellView];
        [self.contentView addSubview:cellView];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+(CGFloat)getCellWidth{
    return SCREEN_CGSIZE_WIDTH;
}

+(CGFloat)getCellHeight{
    return 55;
}

-(UIView *)getCellView{
    UIView *cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [YXMWiFiSwitchTableViewCell getCellWidth], [YXMWiFiSwitchTableViewCell getCellHeight])];
    _promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 180, 44)];
    [_promptLabel setText:@"无线网WiFi已开启"];
    [_promptLabel setTextColor:[UIColor blackColor]];
    [_promptLabel setFont:[UIFont systemFontOfSize:18]];
    [cellView addSubview:_promptLabel];
    
    _wifiSwitch = [[UISwitch alloc]initWithFrame:CGRectMake([YXMWiFiSwitchTableViewCell getCellWidth]-80, 10, 80, 44)];
    [_wifiSwitch setOn:YES];
    [cellView addSubview:_wifiSwitch];
    return cellView;
}

@end
