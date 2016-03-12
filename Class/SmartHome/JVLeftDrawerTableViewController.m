//
//  JVLeftDrawerTableViewController.m
//  JVFloatingDrawer
//  
//  Created by yixingman on 2015-01-15.
//  Copyright (c) 2015 antbang. All rights reserved.
//

#import "JVLeftDrawerTableViewController.h"
#import "JVLeftDrawerTableViewCell.h"
#import "AppDelegate.h"
#import "JVFloatingDrawerViewController.h"
#import "YXMUserManagerViewController.h"
#import "UIView+Shadow.h"
#import <UIImageView+WebCache.h>


enum {
    kJVMachineManagerIndex = 0, //主页面
    kJVRouterManagerIndex = 1, //路由器管理
    kJVAboutPageIndex = 2, //关于页面
    kJVPushMessageList = 3 //推送消息列表
};



static const CGFloat kJVTableViewTopInset = 80.0;//表格的高度
static NSString * const kJVDrawerCellReuseIdentifier = @"JVDrawerCellReuseIdentifier";
static NSString * const kJVHeadImageCellReuseIdentifier = @"JVHeadImageCellReuseIdentifier";


@interface JVLeftDrawerTableViewController ()

@end

@implementation JVLeftDrawerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(kJVTableViewTopInset, 0.0, 0.0, 0.0);
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


/**
 *  读取用户的基本信息（用户头像和用户名称）
 */
-(void)loadUserBaseInfo{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *uid = [ud objectForKey:@"uid"];
    NSString *username = [ud objectForKey:@"username"];
    if (uid) {
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/uc_server/avatar.php?uid=%@&type=real&size=middle",URL_DOMAIN,uid]] placeholderImage:[UIImage imageNamed:@"home_headMan"]];
        [_loginLabel setText:username];
        [_exitButton setHidden:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:kJVMachineManagerIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JVLeftDrawerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJVDrawerCellReuseIdentifier forIndexPath:indexPath];
    
    if(indexPath.row == kJVMachineManagerIndex)  {
        cell.titleText = NSLocalizedString(@"zhinengshebeiguanli", @"智能设备管理");
        cell.iconImage = [UIImage imageNamed:@"supportlist"];
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(cell.iconImageView.frame.origin.x, cell.frame.size.height-1, cell.frame.size.width-cell.iconImageView.frame.origin.x*2, 1)];
        [line1 setBackgroundColor:[UIColor clearColor]];
        for (int i=0; i<line1.frame.size.width*2; i++) {
            UIView *dot = [[UIView alloc]initWithFrame:CGRectMake(i*0.5, 0, 0.5f, 1)];
            if (i<line1.frame.size.width) {
                [dot setBackgroundColor:[UIColor colorWithWhite:0.851 alpha:((i)/(line1.frame.size.width))]];
            }else{
                [dot setBackgroundColor:[UIColor colorWithWhite:0.851 alpha:((line1.frame.size.width*2-(i))/(line1.frame.size.width))]];
            }
            [line1 addSubview:dot];
        }

        [cell addSubview:line1];
    }else if(indexPath.row == kJVRouterManagerIndex)  {
        cell.titleText = NSLocalizedString(@"luyouqiguanli", @"路由器管理");
        cell.iconImage = [UIImage imageNamed:@"router"];
        
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(cell.iconImageView.frame.origin.x, cell.frame.size.height-1, cell.frame.size.width-cell.iconImageView.frame.origin.x*2, 1)];
        [line2 setBackgroundColor:[UIColor clearColor]];
        for (int i=0; i<line2.frame.size.width*2; i++) {
            UIView *dot = [[UIView alloc]initWithFrame:CGRectMake(i*0.5, 0, 0.5f, 1)];
            if (i<line2.frame.size.width) {
                [dot setBackgroundColor:[UIColor colorWithWhite:0.851 alpha:((i)/(line2.frame.size.width))]];
            }else{
                [dot setBackgroundColor:[UIColor colorWithWhite:0.851 alpha:((line2.frame.size.width*2-(i))/(line2.frame.size.width))]];
            }
            [line2 addSubview:dot];
        }
        [cell addSubview:line2];
    }else if(indexPath.row == kJVAboutPageIndex)  {
        cell.titleText = NSLocalizedString(@"guanyu", @"关于");
        cell.iconImage = [UIImage imageNamed:@"aboutUs_icon"];
        UIView *line3 = [[UIView alloc]initWithFrame:CGRectMake(cell.iconImageView.frame.origin.x, cell.frame.size.height-1, cell.frame.size.width-cell.iconImageView.frame.origin.x*2, 1)];
        [line3 setBackgroundColor:[UIColor clearColor]];
        for (int i=0; i<line3.frame.size.width*2; i++) {
            UIView *dot = [[UIView alloc]initWithFrame:CGRectMake(i*0.5, 0, 0.5f, 1)];
            if (i<line3.frame.size.width) {
                [dot setBackgroundColor:[UIColor colorWithWhite:0.851 alpha:((i)/(line3.frame.size.width))]];
            }else{
                [dot setBackgroundColor:[UIColor colorWithWhite:0.851 alpha:((line3.frame.size.width*2-(i))/(line3.frame.size.width))]];
            }
            [line3 addSubview:dot];
        }
        
        [cell addSubview:line3];
    }else if(indexPath.row == kJVPushMessageList)  {
        cell.titleText = NSLocalizedString(@"remoteNoteMessageList", @"通知");
        cell.iconImage = [UIImage imageNamed:@"rating_star_full_icon"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *destinationViewController = nil;
    if(indexPath.row == kJVMachineManagerIndex) {
        destinationViewController = [[AppDelegate globalDelegate] drawerSettingsViewController];
    } else if(indexPath.row == kJVRouterManagerIndex) {
        destinationViewController = [[AppDelegate globalDelegate] routerManagerViewController];
    }else if(indexPath.row == kJVAboutPageIndex)  {
        destinationViewController = [[AppDelegate globalDelegate] githubViewController];
    }else if(indexPath.row == kJVPushMessageList)  {
        destinationViewController = [[AppDelegate globalDelegate] pushMsgNavCtrl];
    }
    
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:destinationViewController];
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
