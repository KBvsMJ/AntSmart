//
//  YXMUserManagerViewController.h
//  SmartHome
//
//  Created by iroboteer on 15/3/19.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeSpinnerTenDot.h"
#import "UIColor+flat.h"

@interface YXMUserManagerViewController : UIViewController<UIWebViewDelegate,FeSpinnerTenDotDelegate>
{
    NSInteger index;
}
@property (strong,nonatomic) UIWebView *loginWebView;
@property (strong, nonatomic) FeSpinnerTenDot *spinner;
@property (strong, nonatomic) NSArray *arrTitile;

@end
