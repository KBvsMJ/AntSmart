//
//  YXMNetChnnelDataObjet.h
//  SmartHome
//
//  Created by iroboteer on 15/4/26.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXMRouterEntity.h"

@interface YXMNetChannelDataObjet : NSObject

@property (nonatomic,strong) NSString *channelsName;
@property (nonatomic,strong) NSArray *channelInnerRouterArray;
@property BOOL isIncludeCurrentDevice;
@end
