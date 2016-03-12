//
//  Config.h
//  SmartHome
//
//  Created by iroboteer on 15/4/9.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//设置语言为调用哪个函数的函数名
extern NSString  *languageString;

extern CGFloat _globalTopViewHeight;
extern NSMutableArray *_globalDeviceLocalIPArray;

@interface Config : NSObject
/*自定义默认语言的方法*/
+ (NSString *)DPLocalizedString:(NSString *)translation_key;
@end
