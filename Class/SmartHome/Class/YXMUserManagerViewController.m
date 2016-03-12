//
//  YXMUserManagerViewController.m
//  SmartHome
//
//  Created by iroboteer on 15/3/19.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMUserManagerViewController.h"
#import "APService.h"
#import "LoginViewController.h"

@implementation YXMUserManagerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    LoginViewController *_loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.view addSubview:_loginViewController.view];
}

-(void)insertCloseButton{
    /******关闭按钮******/
    CGFloat closeButtonWidth = (44.0/320.0)*SCREEN_CGSIZE_WIDTH;
    //按钮与右侧边缘的水平空隙
    CGFloat closeButtonX = (SCREEN_CGSIZE_WIDTH-70);
    //按钮与顶部边缘的垂直空隙
    CGFloat closeButtonY = self.view.frame.size.height - 140;
    UIButton *_deviceCloseButton = [[UIButton alloc]initWithFrame:CGRectMake(closeButtonX, closeButtonY, closeButtonWidth, closeButtonWidth)];
    [_deviceCloseButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [_deviceCloseButton addTarget:self action:@selector(backSuperView) forControlEvents:UIControlEventTouchUpInside];
    [self.loginWebView addSubview:_deviceCloseButton];
}


-(void)backSuperView{
    [self dismiss:nil];
    [self.view removeFromSuperview];
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [self initLoadProgress];
    [self insertCloseButton];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self dismiss:nil];
}



-(void)initLoadProgress{
    self.loginWebView.backgroundColor = [UIColor colorWithHexCode:@"#019875"];
    
    //*********
    index = 0;
    
    
    // init Loader
    if (!_spinner) {
        _arrTitile = @[@"首次加载，耐心等待！",@"首次加载，耐心等待！",@"首次加载，耐心等待！",@"首次加载，耐心等待！"];
        _spinner = [[FeSpinnerTenDot alloc] initWithView:self.loginWebView withBlur:NO];
        _spinner.titleLabelText = _arrTitile[index];
        _spinner.fontTitleLabel = [UIFont fontWithName:@"Neou-Thin" size:26];
        _spinner.delegate = self;
        
        [self.loginWebView addSubview:_spinner];
    }
    
    
    [_spinner showWhileExecutingSelector:@selector(longTask) onTarget:self withObject:nil completion:^{
        index = 0;
    }];
}

-(void) FeSpinnerTenDotDidDismiss:(FeSpinnerTenDot *)sender
{
    NSLog(@"did dismiss");
}

-(void)dismiss:(id)sender
{
    self.loginWebView.backgroundColor = [UIColor whiteColor];
    [_spinner dismiss];
    [_spinner removeFromSuperview];
}

-(void) longTask
{
//    sleep(5);
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [APService startLogPageView:@"登陆/注册"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [APService stopLogPageView:@"登陆/注册"];
}
@end
