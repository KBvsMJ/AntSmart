//
//  Config.m
//  SmartHome
//
//  Created by iroboteer on 15/4/9.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "Config.h"

//设置语言为调用哪个函数的函数名
NSString  *languageString;


CGFloat _globalTopViewHeight;
NSMutableArray *_globalDeviceLocalIPArray;
@implementation Config

/*自定义默认语言的方法*/
+ (NSString *)DPLocalizedString:(NSString *)translation_key {
    NSString * s = NSLocalizedString(translation_key, nil);
    NSString * path;
    if ([languageString isEqual:@"zh-Hans"]) {
        path = [[NSBundle mainBundle] pathForResource:@"zh-Hans" ofType:@"lproj"];
    }else if ([languageString isEqual:@"zh-Hant"]){
        path = [[NSBundle mainBundle] pathForResource:@"zh-Hans" ofType:@"lproj"];
    }else if ([languageString isEqual:@"en"]){
        path = [[NSBundle mainBundle] pathForResource:@"zh-Hans" ofType:@"lproj"];
    }
    
    NSBundle * languageBundle = [NSBundle bundleWithPath:path];
    s = [languageBundle localizedStringForKey:translation_key value:@"" table:nil];
    return s;
}

@end
