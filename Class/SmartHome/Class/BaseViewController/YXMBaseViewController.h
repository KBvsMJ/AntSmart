//
//  YXMBaseViewController.h
//  SmartHome
//
//  Created by iroboteer on 6/9/15.
//  Copyright (c) 2015 iroboteer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YXMBaseViewController : UIViewController
/**
 *  启动加载视图
 */
-(void)startDejalBezelActivityView:(NSString *)promptTitle;

/**
 *  移除加载视图
 */
-(void)stopDegalBezeActivityView;

/**
 *  定义导航栏的文字、颜色、按钮
 */
-(void)configNavigationBar;
@end
