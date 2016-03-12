//
//  YXM_RouterAuthenticationModel.h
//  SmartHome
//
//  Created by iroboteer on 15/4/16.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YXM_RouterAuthenticationModel : NSObject
+ (YXM_RouterAuthenticationModel *)sharedManager;
-(void)loginRouter;
@end
