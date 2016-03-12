//
//  JVDrawerTableViewCell.h
//  JVFloatingDrawer
//
//  Created by yixingman on 2015-01-15.
//  Copyright (c) 2015 antbang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JVLeftDrawerTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, strong) UIImage *iconImage;
@end
