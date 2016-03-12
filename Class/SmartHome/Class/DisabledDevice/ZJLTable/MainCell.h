//
//  MainCell.h
//  NT
//
//  Created by Kohn on 14-5-27.
//  Copyright (c) 2014年 Pem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainCell : UITableViewCell

@property (retain, nonatomic)  UILabel *nameLabel;

@property (retain, nonatomic)  UILabel *IntroductionLabel;

@property (retain, nonatomic)  UILabel *networkLabel;

@property (retain, nonatomic)  UIImageView *Headerphoto;

@property (retain, nonatomic) UIImageView *imageLine;

- (void)setMainCell;
@end


