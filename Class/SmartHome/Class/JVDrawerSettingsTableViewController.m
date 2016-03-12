//
//  JVDrawerSettingsTableViewController.m
//  JVFloatingDrawer
//
//  Created by yixingman on 2015-01-15.
//  Copyright (c) 2015 antbang. All rights reserved.
//

#import "JVDrawerSettingsTableViewController.h"
#import "JVFloatingDrawerSpringAnimator.h"
#import "AppDelegate.h"


@interface JVDrawerSettingsTableViewController ()
{
    HASmallCollectionViewController *collectionViewController;
}
@property (nonatomic, strong, readonly) JVFloatingDrawerSpringAnimator *drawerAnimator;



@end

@implementation JVDrawerSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"蚂蚁智能";
    [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@""]];
    HACollectionViewSmallLayout *smallLayout = [[HACollectionViewSmallLayout alloc] init];
    collectionViewController = [[HASmallCollectionViewController alloc] initWithCollectionViewLayout:smallLayout];
    [collectionViewController.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-64)];
    [self.view addSubview:collectionViewController.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionCellChangeSize:) name:NOTI_COLLECTIONVIEW_SIZE_CHANGE object:nil];
}


#pragma mark - Actions

- (IBAction)actionToggleLeftDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (IBAction)actionToggleRightDrawer:(id)sender {
    
    if ([collectionViewController isFullscreen]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTI_CHANGE_LAYOUT object:nil];
    }
//    else{
//        //进入右侧设置
////        [[AppDelegate globalDelegate] toggleRightDrawer:self animated:YES];
//        //刷新主页的UI
//        [collectionViewController refreshCollection];
//    }
    [collectionViewController refreshCollection];
}


#pragma mark - Helpers
- (JVFloatingDrawerSpringAnimator *)drawerAnimator {
    return [[AppDelegate globalDelegate] drawerAnimator];
}


#pragma mark - Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)collectionCellChangeSize:(NSNotification *)noti{
    if (noti) {
        if ([noti userInfo]) {
            NSString *size = [[noti userInfo] objectForKey:@"size"];
            if ([size isEqualToString:@"large"]) {
                [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"navbar_small"]];
            }
            if ([size isEqualToString:@"small"]) {
                [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@""]];
            }
        }
    }
    
}

@end
