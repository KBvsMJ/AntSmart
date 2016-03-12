//
//  UserModel.m
//  Project_Aidu
//
//  Created by macmini_01 on 14-11-20.
//  Copyright (c) 2014年 Vooda. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

@synthesize UserID;
@synthesize NickName;
@synthesize Url;
@synthesize Sex;
@synthesize BirthDay;
@synthesize Stature;
@synthesize Weights;
@synthesize Hobby;
@synthesize Type;
@synthesize AddTime;

-(id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.UserID   = [dict objectForKey:@"UserID"];
        self.NickName = [dict objectForKey:@"NickName"];
        self.Url      = [dict objectForKey:@"Url"];
        self.Sex      = [dict objectForKey:@"Sex"];
        self.BirthDay = [dict objectForKey:@"BirthDay"];
        self.Stature  = [dict objectForKey:@"Stature"];
        self.Weights  = [dict objectForKey:@"Weights"];
        self.Hobby    = [dict objectForKey:@"Hobby"];
        self.Type     = [dict objectForKey:@"Type"];
        self.AddTime  = [dict objectForKey:@"AddTime"]; // "2014/12/23 10:19:56"
    }
    return self;
}
@end
