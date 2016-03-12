//
//  ZJLViewController.m
//  zhanKaiTableView
//
//  Created by 张欣琳 on 14-2-11.
//  Copyright (c) 2014年 张欣琳. All rights reserved.
//

#import "ZJLViewController.h"
#import "MainCell.h"
#import "AttachedCell.h"
#import "YXMDeviceListModel.h"
#import "YXMDatabaseOperation.h"
#import "YXMDeviceEntity.h"
#import "Config.h"
#import "IPHelpler.h"

@interface ZJLViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableDictionary *dic;//存对应的数据
    NSMutableArray *selectedArr;//二级列表是否展开状态
    NSMutableArray *titleDataArray;
    NSArray *dataArray;//数据源，显示每个cell的数据
    NSMutableDictionary *stateDic;//三级列表是否展开状态
    NSMutableArray *grouparr0;
    NSMutableArray *grouparr1;
    NSMutableArray *grouparr2;
    NSMutableArray *grouparr3;
    NSMutableArray *grouparr4;
    NSMutableArray *grouparr5;
}

@end

@implementation ZJLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [Config DPLocalizedString:@"terminal_device_list"];
    
    
    dic = [[NSMutableDictionary alloc] init];
    selectedArr = [[NSMutableArray alloc] init];
    [selectedArr addObject:@"0"];
    dataArray = [[NSArray alloc] init];
    
    //tableView
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_CGSIZE_WIDTH,SCREEN_HEIGHT) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    //不要分割线
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    [self initDataSource];
    
    //刷新列表的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:NOTI_REFRESH_DEVICE_LIST object:nil];
}


/**
 *  初始化终端列表的数据
 */
-(void)initDataSource
{
    [self startDejalBezelActivityView:nil];
    titleDataArray = [[NSMutableArray alloc] initWithObjects:@"默认分组", nil];
    NSMutableArray *onlineArray = [[NSMutableArray alloc]initWithCapacity:0];
    NSMutableArray *offlineArray = [[NSMutableArray alloc]initWithCapacity:0];
    NSMutableArray *selfArray = [[NSMutableArray alloc]initWithCapacity:1];
    YXMDeviceListModel *deviceList = [YXMDeviceListModel sharedManager];
    [deviceList deviceList:^(NSArray *blockDeviceListArray) {
        grouparr0 = [[NSMutableArray alloc]init];
        for (YXMDeviceEntity *device in blockDeviceListArray) {
            NSString *groupName = device.device_group;
            if ([groupName length]<1) {
                groupName = @"0";
            }
            NSString *name = device.device_nickname;
            if ([name length]<1) {
                name = device.device_name;
            }
            NSMutableDictionary *nameAndStateDic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"MainCell",@"cell",name,@"name",device.device_mac,@"mac",@"NO",@"state",device.device_online,@"online",device,@"entity", nil];
            if ([device.device_ip isEqualToString:[IPHelpler localIP]]) {
                [selfArray addObject:nameAndStateDic];
            }else{
                if ([device.device_online boolValue]) {
                    [onlineArray addObject:nameAndStateDic];
                }else{
                    [offlineArray addObject:nameAndStateDic];
                }
            }
        }
        [grouparr0 addObjectsFromArray:selfArray];
        [grouparr0 addObjectsFromArray:onlineArray];
        [grouparr0 addObjectsFromArray:offlineArray];
        [dic setValue:grouparr0 forKey:@"0"];
        DLog(@"dic = %@",dic);
        [_tableView reloadData];
        [self stopDegalBezeActivityView];
    }];
    
    
    
    return;
}

#pragma mark----tableViewDelegate
//返回几个表头
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return titleDataArray.count;
}

//每一个表头下返回几行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *string = [NSString stringWithFormat:@"%d",section];
    
    if ([selectedArr containsObject:string]) {
        
        UIImageView *imageV = (UIImageView *)[_tableView viewWithTag:20000+section];
        imageV.image = [UIImage imageNamed:@"buddy_header_arrow_down@2x.png"];
        
        NSArray *array1 = dic[string];
        return array1.count;
    }
    return 0;
}

//设置表头的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

//Section Footer的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.2;
}

//设置view，将替代titleForHeaderInSection方法
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_CGSIZE_WIDTH, 30)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, tableView.frame.size.width-20, 30)];
    titleLabel.text = [titleDataArray objectAtIndex:section];
    [view addSubview:titleLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 12, 15, 15)];
    imageView.tag = 20000+section;

    //判断是不是选中状态
    NSString *string = [NSString stringWithFormat:@"%d",section];
    
    if ([selectedArr containsObject:string]) {
        imageView.image = [UIImage imageNamed:@"buddy_header_arrow_down@2x.png"];
    }
    else
    {
        imageView.image = [UIImage imageNamed:@"buddy_header_arrow_right@2x.png"];
    }
    [view addSubview:imageView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, SCREEN_CGSIZE_WIDTH, 40);
    button.tag = 100+section;
    [button addTarget:self action:@selector(doButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 39, SCREEN_CGSIZE_WIDTH, 1)];
    lineImage.image = [UIImage imageNamed:@"line.png"];
    [view addSubview:lineImage];
   
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indexStr = [NSString stringWithFormat:@"%d",indexPath.section];
    
    if ([dic[indexStr][indexPath.row][@"cell"] isEqualToString:@"MainCell"])
    {
        return 60;
    }
    else
        return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //当前是第几个表头
    NSString *indexStr = [NSString stringWithFormat:@"%d",indexPath.section];
    
    if ([dic[indexStr][indexPath.row][@"cell"] isEqualToString:@"MainCell"]) {
        
        static NSString *CellIdentifier = @"MainCell";
    
        MainCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[MainCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        if ([selectedArr containsObject:indexStr]) {
            cell.Headerphoto.image = [UIImage imageNamed:@"icon_pc_visitor"];
            cell.nameLabel.text = dic[indexStr][indexPath.row][@"name"];
            cell.IntroductionLabel.text = dic[indexStr][indexPath.row][@"mac"];
            NSString *onlineStateStr = dic[indexStr][indexPath.row][@"online"];
            NSString *onlineText = @"在线";
            if ([onlineStateStr boolValue]) {
                onlineText = @"在线";
                YXMDeviceEntity *entity = dic[indexStr][indexPath.row][@"entity"];
                if ([entity.device_ip isEqualToString:[IPHelpler localIP]]) {
                    onlineText = @"本机";
                }
            }else{
                onlineText = @"离线";
            }
            cell.networkLabel.text = onlineText;
            //@"在线"
        }
        
        if (indexPath.row == dataArray.count-1) {
            cell.imageLine.image = nil;
        }
        else
            cell.imageLine.image = [UIImage imageNamed:@"line.png"];
        
        return cell;
    }
    else if([dic[indexStr][indexPath.row][@"cell"] isEqualToString:@"AttachedCell"]){
        
        static NSString *CellIdentifier = @"AttachedCell";
        
        AttachedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        
        if (cell == nil) {
            cell = [[AttachedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.imageLine.image = [UIImage imageNamed:@"line.png"];
            
            
            
            [cell setCtrl:self];
        }
        
        [cell setDevice_id:dic[indexStr][indexPath.row][@"mac"]];
        [cell setDeviceData:dic[indexStr][indexPath.row][@"entity"]];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *indexStr = [NSString stringWithFormat:@"%d",indexPath.section];
    
    NSIndexPath *path = nil;
    
    if ([dic[indexStr][indexPath.row][@"cell"] isEqualToString:@"MainCell"]) {
        path = [NSIndexPath indexPathForItem:(indexPath.row+1) inSection:indexPath.section];
    }
    else
    {
        path = indexPath;
    }
    
    if ([dic[indexStr][indexPath.row][@"state"] boolValue]) {
        
        // 关闭附加cell
        NSMutableDictionary *dd = dic[indexStr][indexPath.row];
        NSString *name = dd[@"name"];
        NSString *mac = dd[@"mac"];
        NSString *online = dd[@"online"];
        YXMDeviceEntity *device = dd[@"entity"];
        
        NSMutableDictionary *nameAndStateDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"MainCell",@"cell",name,@"name",@"NO",@"state",mac,@"mac",online,@"online",device,@"entity",nil];
        
        switch (indexPath.section) {
            case 0:
            {
                grouparr0[(path.row-1)] = nameAndStateDic;
                [grouparr0 removeObjectAtIndex:path.row];
            }
                break;
            default:
                break;
        }
        
         [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:@[path]  withRowAnimation:UITableViewRowAnimationMiddle];
        [_tableView endUpdates];
        
    }
    else
    {
        // 打开附加cell
        NSMutableDictionary *dd = dic[indexStr][indexPath.row];
        NSString *name = dd[@"name"];
        NSString *mac = dd[@"mac"];
        NSString *online = dd[@"online"];
        YXMDeviceEntity *device = dd[@"entity"];
        
        NSMutableDictionary *nameAndStateDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"MainCell",@"cell",name,@"name",mac,@"mac",@"YES",@"state",online,@"online",device,@"entity",nil];

        switch (indexPath.section) {
            case 0:
            {
                grouparr0[(path.row-1)] = nameAndStateDic;
                NSMutableDictionary *nameAndStateDic1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"AttachedCell",@"cell",@"YES",@"state",name,@"name",mac,@"mac",device,@"entity",nil];
                [grouparr0 insertObject:nameAndStateDic1 atIndex:path.row];
            }
                break;
            default:
                break;
        }
        
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationMiddle];
        [_tableView endUpdates];
        
    }
}

-(void)doButton:(UIButton *)sender
{
    NSString *string = [NSString stringWithFormat:@"%d",(int)(sender.tag-100)];
    
    //数组selectedArr里面存的数据和表头想对应，方便以后做比较
    if ([selectedArr containsObject:string])
    {
        [selectedArr removeObject:string];
    }
    else
    {
        [selectedArr addObject:string];
    }
    
    [_tableView reloadData];
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)reloadTableView{
    DLog(@"reloadTableView");
    [self initDataSource];
}
@end

