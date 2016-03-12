//
//  YXMOptimizeTableViewCell.m
//  SmartHome
//
//  Created by iroboteer on 15/4/26.
//  Copyright (c) 2015年 antbang. All rights reserved.
//

#import "YXMOptimizeTableViewCell.h"

@implementation YXMOptimizeTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(UIView *)getCellView{
    UIView *cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_CGSIZE_WIDTH, 44)];
    UILabel *l = [[UILabel alloc]init];
    [l setTextAlignment:NSTextAlignmentRight];
    return cellView;
}
@end
