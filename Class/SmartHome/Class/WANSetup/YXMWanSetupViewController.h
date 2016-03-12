//
//  YXMWanSetupViewController.h
//  SmartHome
//
//  Created by iroboteer on 15/4/9.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseButton.h"
#import "TableViewWithBlock.h"
#import "SelectionCell.h"
#import "Config.h"

typedef NS_ENUM(NSInteger, WANOfSetupMethod) {
    WANOfSetupADSL = 0,
    WANOfSetupAuto,
    WANOfSetupStatic
};

@interface YXMWanSetupViewController : UIViewController<UITextFieldDelegate>
{
    UIScrollView *_baseView;
    CGRect rectSaveConfigButton;
    BaseButton *saveConfigButton;
    CGRect rectBaseView;
    /*选择上网方式*/
    BOOL sizeIsOpend;//判断下拉tableView是否打开
    UIImageView *sizeImageView;
    UITextField *sizeTextField;
    BaseButton *sizeButton;
    TableViewWithBlock *sizeTableBlock;
    UILabel *sizeLabel;
    NSArray *sizeArray;
    
    //选定的上网方式
    NSInteger setWANMethod;
    //宽带账号
    UITextField *_adslTextField;
    //宽带密码
    UITextField *_adslPwdTextField;
    //IP地址
    UITextField *_ipAddressTextField;
    //子网掩码
    UITextField *_maskAddressTextField;
    //网关
    UITextField *_getwayTextField;
    //dns
    UITextField *_dnsTextField;
    //备用dns
    UITextField *_spareDnsTextField;
    
    UIView *_adslView;
    UIView *_autoView;
    UIView *_staticView;
    
    //键盘的高度
    CGFloat keyboardhight;
    CGFloat keyboardHeight;
    
    WANOfSetupMethod myMethod;
}
@end
