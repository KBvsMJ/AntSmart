//
//  YXMRelayViewController.h
//  SmartHome
//
//  Created by iroboteer on 15/4/4.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownListView.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "YXMNetChannelDataObjet.h"

@interface YXMRelayViewController : UIViewController<kDropDownListViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    //搜索到的信号
    NSMutableArray *arryList;
    DropDownListView * Dropobj;
    YXMRouterEntity *_selectedRouter;
    //点击开始选择想要中继的wifi的按钮
    UIButton *selectSSIDButton;
    //确定开始配置按钮
    UIButton *configButton;
    UISwitch *_extraSwitch;
}
@end
