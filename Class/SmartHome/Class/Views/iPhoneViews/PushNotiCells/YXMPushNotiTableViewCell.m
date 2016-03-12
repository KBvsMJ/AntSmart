//
//  YXMPushNotiTableViewCell.m
//  SmartHome
//
//  Created by iroboteer on 6/16/15.
//  Copyright (c) 2015 iroboteer. All rights reserved.
//

#import "YXMPushNotiTableViewCell.h"

@implementation YXMPushNotiTableViewCell
@synthesize pushData = _pushData;


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *cellView = [self getCellView];
        [self.contentView addSubview:cellView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(YXMPushNotiModel *)pushData{
    return _pushData;
}

-(void)setPushData:(YXMPushNotiModel *)pushData{
    if (_pushData!=pushData) {
        _pushData = pushData;
        [_pushNotiReadFlagImageView setImage:[UIImage imageNamed:pushData.pushNotiIsRead]];
        [self setPushNotiTitleLabelText:pushData.pushNotiTitle];
    }
}


-(UIView *)getCellView{
    UIView *cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_CGSIZE_WIDTH, [self getCellHegiht])];
    _pushNotiReadFlagImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, cellView.frame.size.height/2.0f-5, 10, 10)];
    [cellView addSubview:_pushNotiReadFlagImageView];
    
    _pushNotiTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(_pushNotiReadFlagImageView.frame.origin.x + _pushNotiReadFlagImageView.frame.size.width+5, cellView.frame.size.height/2.0f-15, cellView.frame.size.width-(_pushNotiReadFlagImageView.frame.size.width+_pushNotiReadFlagImageView.frame.origin.x)-5, 30)];
    [_pushNotiTitleLabel setFont:[UIFont systemFontOfSize:18]];
    [_pushNotiTitleLabel setBackgroundColor:[UIColor clearColor]];
    [_pushNotiTitleLabel setTextColor:[UIColor blackColor]];
    [_pushNotiTitleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [cellView addSubview:_pushNotiTitleLabel];
    
    return cellView;
}

-(CGFloat)getCellHegiht{
    return 50.0f;
}

//赋值 and 自动换行,计算出cell的高度
-(void)setPushNotiTitleLabelText:(NSString*)text{
    //获得当前cell高度
    CGRect frame = [self frame];
    //文本赋值
    _pushNotiTitleLabel.text = text;
    //设置label的最大行数
    _pushNotiTitleLabel.numberOfLines = 10;
    CGSize size = CGSizeMake(SCREEN_CGSIZE_WIDTH-(_pushNotiReadFlagImageView.frame.size.width+_pushNotiReadFlagImageView.frame.origin.x)-5, 1000);
    CGSize labelSize = [_pushNotiTitleLabel.text sizeWithFont:_pushNotiTitleLabel.font constrainedToSize:size lineBreakMode:NSLineBreakByClipping];
    _pushNotiTitleLabel.frame = CGRectMake(_pushNotiTitleLabel.frame.origin.x, _pushNotiTitleLabel.frame.origin.y, labelSize.width, labelSize.height);
    
    //计算出自适应的高度
    frame.size.height = labelSize.height+25;
    
    self.frame = frame;
}
@end
