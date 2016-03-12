//
//  BaseViewController.h
//  Project_Aidu
//
//  Created by macmini_01 on 14-11-12.
//  Copyright (c) 2014年 Vooda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
{
    //标题
    UILabel * titleLabel;
    //工具栏左侧返回按钮
    UIButton * btnBack;
    //工具栏右侧更多按钮
    UIButton * btnMore;
    //标题右侧按钮
    UIButton * btnTitle;
    //背景图片
    UIImageView * imgBg;
}
/*
 *@brief 标题栏按钮事件
 */
-(void)btnTitleNav:(id)sender;
/*
 *@brief 后退按钮事件
 */
-(void)btnBackNav:(id)sender;
/*
 *@brief 更多按钮事件
 */
-(void)btnMoreNav:(id)sender;

@end
