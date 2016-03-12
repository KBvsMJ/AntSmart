//
//  YXMMyRouterModel.m
//  SmartHome
//
//  Created by iroboteer on 6/3/15.
//  Copyright (c) 2015 iroboteer. All rights reserved.
//

#import "YXMMyRouterModel.h"

@implementation YXMMyRouterModel
-(NSString *)description{
    return [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",self.mrouter_id,self.mrouter_name,self.mrouter_lan_ip,self.mrouter_lan_mac,self.mrouter_wan_mac,self.mrouter_wan_ip,self.mrouter_hardware_version,self.mrouter_software_version,self.mrouter_lan_mask,self.mrouter_dns1,self.mrouter_geteway];
}
@end
