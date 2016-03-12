//
//  UserModel.h
//  Project_Aidu
//
//  Created by macmini_01 on 14-11-20.
//  Copyright (c) 2014年 Vooda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property(nonatomic,copy) NSString *UserID;
@property(nonatomic,copy) NSString *NickName;
@property(nonatomic,copy) NSString *Url;
@property(nonatomic,copy) NSString *Sex;
@property(nonatomic,copy) NSString *BirthDay;
@property(nonatomic,copy) NSString *Stature;  //身高
@property(nonatomic,copy) NSString *Weights;
@property(nonatomic,copy) NSString *Hobby;    //爱好
@property(nonatomic,copy) NSString *Type;     //登录类型
@property(nonatomic,copy) NSString *AddTime;  //注册时间

- (id)initWithDictionary:(NSDictionary *)dict;
@end
