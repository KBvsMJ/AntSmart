//
//  YXMRightMenuViewController.m
//  SmartHome
//
//  Created by iroboteer on 15/5/3.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMRightMenuViewController.h"
#import "AppDelegate.h"
#import "ConfigViewController.h"
#import "JVFloatingDrawerViewController.h"

@interface YXMRightMenuViewController ()

@end
static const CGFloat kJVTableViewTopInset = 80.0;
@implementation YXMRightMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_myTableView setDelegate:self];
    [_myTableView setDataSource:self];
    _myTableView.backgroundColor = [UIColor clearColor];
    _myTableView.contentInset = UIEdgeInsetsMake(kJVTableViewTopInset, 0.0, 0.0, 0.0);

    [self.view addSubview:_myTableView];
    
    _tableDataSourceArray = [[NSMutableArray alloc]initWithObjects:@"添加新设备",@"模式设置",@"推荐购买", nil];
    _myTableView.tableFooterView=[[UIView alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"myRightCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [_tableDataSourceArray objectAtIndex:indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_tableDataSourceArray count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        [self intoConfigPlugView];
    }
}

/**
 *  进入插座配置页面
 */
-(void)intoConfigPlugView{
    [[AppDelegate globalDelegate] toggleRightDrawer:self animated:YES];
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:[[AppDelegate globalDelegate] configNavCtrl]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}

@end
