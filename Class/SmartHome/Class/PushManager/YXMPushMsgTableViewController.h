//
//  YXMPushMsgTableViewController.h
//  SmartHome
//
//  Created by iroboteer on 6/15/15.
//  Copyright (c) 2015 iroboteer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXMBaseViewController.h"
#import "YXMPushNotiModel.h"
#import "UITableViewCell+Delete.h"

@interface YXMPushMsgTableViewController : YXMBaseViewController<UITableViewDelegate,UITableViewDataSource,DeleteCellDelegate>
{
    UITableView *_msgTableView;
    NSMutableArray *_msgTableArray;
}
@end
