//
//  YXMPushNotiTableViewCell.h
//  SmartHome
//
//  Created by iroboteer on 6/16/15.
//  Copyright (c) 2015 iroboteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXMPushNotiModel.h"

@interface YXMPushNotiTableViewCell : UITableViewCell
{
    UIImageView *_pushNotiReadFlagImageView;
    UILabel *_pushNotiTitleLabel;
    
    YXMPushNotiModel *_pushData;
}

@property (nonatomic,strong) YXMPushNotiModel *pushData;
-(UIView *)getCellView;
@end
