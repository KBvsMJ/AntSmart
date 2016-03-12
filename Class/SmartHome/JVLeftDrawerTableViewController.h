//
//  JVLeftDrawerTableViewController.h
//  JVFloatingDrawer
//
//  Created by yixingman on 2015-01-15.
//  Copyright (c) 2015 antbang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YXMUserManagerViewController;
@interface JVLeftDrawerTableViewController : UITableViewController
{
    UIImageView *_headImageView;
    UILabel *_loginLabel;
    YXMUserManagerViewController *_usermanagerCtrl;
    UIButton *_exitButton;
}
@end
