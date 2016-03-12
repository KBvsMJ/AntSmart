//
//  YXMPushMsgTableViewController.m
//  SmartHome
//
//  Created by iroboteer on 6/15/15.
//  Copyright (c) 2015 iroboteer. All rights reserved.
//

#import "YXMPushMsgTableViewController.h"
#import "YXMPushNotiTableViewCell.h"
#import "NewsWebViewController.h"
#import "YXMDatabaseOperation.h"


@interface YXMPushMsgTableViewController ()
{
    NewsWebViewController *newsCtrl;
}
@end

@implementation YXMPushMsgTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configNavigationBar];
    self.title = @"通知";
    
    _msgTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, SCREEN_CGSIZE_WIDTH, SCREEN_CGSIZE_HEIGHT-86) style:UITableViewStylePlain];
    _msgTableView.delegate = self;
    _msgTableView.dataSource = self;
    [self.view addSubview:_msgTableView];
    
    // 下一个界面的返回按钮
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"返回";
    [temporaryBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadTableViewData];
}



/**
 *  加载表格的数据
 */
-(void)loadTableViewData{
    @try {
        if (!_msgTableArray) {
            _msgTableArray = [[NSMutableArray alloc]init];
        }
        
        YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
        [db openDatabase];
        NSArray *selectPushArray = [db selectAllPushMsgData];
        if ([selectPushArray count]>0) {
            [_msgTableArray removeAllObjects];
            [_msgTableArray setArray:selectPushArray];
            [_msgTableView reloadData];
        }
    }
    @catch (NSException *exception) {
        DTLog(@"%@",exception);
    }
    @finally {
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_msgTableArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"pushNotiCell";
    YXMPushNotiTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[YXMPushNotiTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    NSInteger index = [indexPath row];
    [cell setPushData:[_msgTableArray objectAtIndex:index]];
    [cell enableDeleteMethod:YES];
    [cell setDeleteDelegate:self];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    YXMPushNotiTableViewCell *cell = (YXMPushNotiTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.row;
    YXMPushNotiModel *data = [_msgTableArray objectAtIndex:index];
    if (!newsCtrl) {
        newsCtrl = [[NewsWebViewController alloc]init];
    }
    [newsCtrl reloadWebviewurl:data.pushNotiURL andTitle:data.pushNotiTitle];
    [self.navigationController pushViewController:newsCtrl animated:YES];
}


/**
 *  删除cell中的一行的动作
 *
 *  @param cell cell
 */
- (void)deleteAction:(UITableViewCell *)cell {
    NSIndexPath* indexPath = [_msgTableView indexPathForCell:cell];
    NSInteger index = indexPath.row;
    YXMPushNotiModel *data = (YXMPushNotiModel *)[_msgTableArray objectAtIndex:index];
    [_msgTableArray removeObjectAtIndex:index];
    [_msgTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:(UITableViewRowAnimationFade)];
    YXMDatabaseOperation *db = [YXMDatabaseOperation sharedManager];
    [db openDatabase];
    [db deletePushMsgWithMsgID:data.pushNotiID];
    
}
@end
