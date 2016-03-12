//
//  YXMWiFiSwitchViewController.m
//  SmartHome
//
//  Created by iroboteer on 15/6/25.
//  Copyright (c) 2015年 iroboteer. All rights reserved.
//

#import "YXMWiFiSwitchViewController.h"
#import "YXMWiFiSwitchTableViewCell.h"
#import "YXMWiFiTimeSwitchTableViewCell.h"

@interface YXMWiFiSwitchViewController ()

@end

@implementation YXMWiFiSwitchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WiFi开关";
    
    _switchTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, SCREEN_CGSIZE_WIDTH, SCREEN_CGSIZE_HEIGHT) style:UITableViewStyleGrouped];
    _switchTableView.delegate = self;
    _switchTableView.dataSource = self;
    [self.view addSubview:_switchTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return @"WiFi开关";
    }
    if (section==1) {
        return @"定时设置";
    }
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"pushNotiCell";
    static NSString *reuseIdentifier1 = @"pushNotiCell1";
    if (indexPath.section==0) {
        YXMWiFiSwitchTableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (!cell1) {
            cell1 = [[YXMWiFiSwitchTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        }
        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell1;
    }
    if (indexPath.section==1) {
        YXMWiFiTimeSwitchTableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier1];
        if (!cell2) {
            cell2 = [[YXMWiFiTimeSwitchTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier1];
        }
        cell2.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell2;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return  [YXMWiFiSwitchTableViewCell getCellHeight];
    }
    if (indexPath.section==1) {
        return [YXMWiFiTimeSwitchTableViewCell getCellHeight];
    }
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


@end
