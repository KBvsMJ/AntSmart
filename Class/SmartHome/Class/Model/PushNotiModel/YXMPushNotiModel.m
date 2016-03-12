//
//  YXMPushNotiModel.m
//  SmartHome
//
//  Created by iroboteer on 6/16/15.
//  Copyright (c) 2015 iroboteer. All rights reserved.
//

#import "YXMPushNotiModel.h"

@implementation YXMPushNotiModel
-(instancetype)init{
    self = [super init];
    if (self) {
        self.pushNotiIsRead = @"bg_link_ok";
    }
    return self;
}
@end
