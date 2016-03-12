//
//  BaseViewController.m
//  Project_Aidu
//
//  Created by macmini_01 on 14-11-12.
//  Copyright (c) 2014年 Vooda. All rights reserved.
//

#import "BaseViewController.h"


@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //设置Nav背景
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"public_navbg_image.png"] forBarMetrics:UIBarMetricsDefault];

    //添加页面的背景图
    imgBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    imgBg.image = [UIImage imageNamed:@"Public_img_backGround.png"];
    [self.view addSubview:imgBg];
    
    //标题栏titleView
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:17];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    [self.navigationItem setTitleView:titleLabel];
    
    //标题栏按钮
    btnTitle = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTitle.frame = CGRectMake(kScreenWidth/2 + 20, 12, 20, 20);
    [btnTitle setBackgroundImage:[UIImage imageNamed:@"Sport_btn_titleBtn.png"] forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:btnTitle];
    [btnTitle addTarget:self action:@selector(btnTitleNav:) forControlEvents:UIControlEventTouchUpInside];
    btnTitle.hidden = YES;
    
    
    //返回按钮
    btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(0, 0, 35, 35);
    [btnBack addTarget:self action:@selector(btnBackNav:) forControlEvents:UIControlEventTouchUpInside];
    btnBack.backgroundColor = [UIColor clearColor];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"Public_btn_back.png"] forState:UIControlStateNormal];
    UIBarButtonItem *btnLeftItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem = btnLeftItem;

    //更多按钮
    btnMore = [[UIButton alloc]init];
    btnMore.frame = CGRectMake(320-120/2, 0, 35, 35);
    [btnMore addTarget:self action:@selector(btnMoreNav:) forControlEvents:UIControlEventTouchUpInside];
    btnMore.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *btnRightItem = [[UIBarButtonItem alloc] initWithCustomView:btnMore];
    self.navigationItem.rightBarButtonItem = btnRightItem;
    [btnMore setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnMore setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateHighlighted];
    btnMore.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    btnMore.titleLabel.adjustsFontSizeToFitWidth = YES;
    btnMore.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    btnMore.titleLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    [btnMore setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 1, 0)];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
