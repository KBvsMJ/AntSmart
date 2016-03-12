//
//  YXMRightMenuViewController.h
//  SmartHome
//
//  Created by iroboteer on 15/5/3.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ConfigViewController;

@interface YXMRightMenuViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_myTableView;
    NSMutableArray *_tableDataSourceArray;
    
    

}

@end
