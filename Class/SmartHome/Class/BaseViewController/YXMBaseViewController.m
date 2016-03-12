//
//  YXMBaseViewController.m
//  SmartHome
//
//  Created by iroboteer on 6/9/15.
//  Copyright (c) 2015 iroboteer. All rights reserved.
//

#import "YXMBaseViewController.h"
#import "DejalActivityView.h"
#import "Config.h"
#import "AppDelegate.h"
#import "JVFloatingDrawerViewController.h"

@interface YXMBaseViewController ()

@end

@implementation YXMBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/**
 *  启动加载视图
 */
-(void)startDejalBezelActivityView:(NSString *)promptTitle{
    NSString *promptLabelTitle = nil;
    if (promptTitle) {
        promptLabelTitle = promptTitle;
    }else{
        promptLabelTitle = [Config DPLocalizedString:@"prompt_title_loading"];
    }
    [DejalBezelActivityView activityViewForView:self.view withLabel:promptLabelTitle width:SCREEN_CGSIZE_WIDTH/3.0];
    [DejalBezelActivityView currentActivityView].showNetworkActivityIndicator = YES;
}

/**
 *  移除加载视图
 */
-(void)stopDegalBezeActivityView{
    //删除加载视图
    [DejalBezelActivityView removeViewAnimated:YES];
}

/**
 *  定义导航栏的文字、颜色、按钮
 */
-(void)configNavigationBar{
    //设置视图背景色，视图的背景色默认为透明
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIBarButtonItem *leftbarbtn=[[UIBarButtonItem alloc]
                                 initWithImage:[UIImage imageNamed:@"399-list1"]
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(showLeftPage:)];
    [leftbarbtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftbarbtn;
    
    UIBarButtonItem *rightbarbtn = [[UIBarButtonItem alloc]
                                    initWithImage:[UIImage imageNamed:@"navbar_small"]
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(showRightPage:)];
    [rightbarbtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = rightbarbtn;
    
    //自定义导航栏文字的样式
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithWhite:0.984 alpha:1.000], NSForegroundColorAttributeName,[UIColor colorWithWhite:0.996 alpha:1.000], NSBackgroundColorAttributeName,[NSValue valueWithUIOffset:UIOffsetMake(0, 0)], NSBaselineOffsetAttributeName,[UIFont fontWithName:@"Arial-Bold" size:0.0], NSFontAttributeName,nil]];
    
    
    //导航栏颜色
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000]];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)showLeftPage:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}
- (void)showRightPage:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:[[AppDelegate globalDelegate] drawerSettingsViewController]];
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

@end
