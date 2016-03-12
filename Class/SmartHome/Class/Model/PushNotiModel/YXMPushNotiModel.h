//
//  YXMPushNotiModel.h
//  SmartHome
//
//  Created by iroboteer on 6/16/15.
//  Copyright (c) 2015 iroboteer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YXMPushNotiModel : NSObject
@property (nonatomic,strong) NSString *pushNotiTitle;//通知的标题
@property (nonatomic,strong) NSString *pushNotiIsRead;//通知是否已读
@property (nonatomic,strong) NSString *pushNotiURL;//通知的真实数据的URL
@property (nonatomic,strong) NSDate *pushNoteReceiveDate;//客户端接收通知的时间
@property (nonatomic,strong) NSString *pushNotiID;//通知的编号
@end
