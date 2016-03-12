//
//  ProjectItemCell
//  LEDAD
//  项目列表的Cell
//  Created by yixingman on 8/21/14.
//  Copyright (c) 2014 yixingman. All rights reserved.
//


#import "ProjectItemCell.h"


@implementation ProjectItemCell
@synthesize channelObject = _channelObject;


-(YXMNetChannelDataObjet *)channelObject{
    return _channelObject;
}

-(void)setChannelObject:(YXMNetChannelDataObjet *)channelObject{
        if (channelObject != _channelObject) {
            _channelObject = nil;
            _channelObject = channelObject;
            _projectNameLabel.text = channelObject.channelsName;
            
            _numberOfDeviceLabel.text = [NSString stringWithFormat:@"%d",((int)[channelObject.channelInnerRouterArray count])];
            [audioIndicatorView setHidden:(!channelObject.isIncludeCurrentDevice)];
        }
}




-(UIView*)getCellView{
    float cellViewHeight = [ProjectItemCell projectItemCellHeight];
    float cellViewWidth = SCREEN_CGSIZE_WIDTH;
    
    UIView *cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,cellViewWidth,cellViewHeight)];

    float scale1 = 0.28f;
    float scale2 = 0.3f;
    float scale3 = 0.2f;
    //通道的名称
    _projectNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, cellViewWidth * scale1, cellViewHeight)];
    [_projectNameLabel setBackgroundColor:[UIColor clearColor]];
    [_projectNameLabel setTextColor:[UIColor colorWithRed:0.463 green:0.392 blue:0.286 alpha:1.000]];
    [cellView addSubview:_projectNameLabel];
    //当前通道内的设备的数量
    _numberOfDeviceLabel = [[UILabel alloc]initWithFrame:CGRectMake(_projectNameLabel.frame.origin.x + _projectNameLabel.frame.size.width, 0, cellViewWidth * scale2, cellViewHeight)];
    [_numberOfDeviceLabel setBackgroundColor:[UIColor clearColor]];
    [_numberOfDeviceLabel setTextAlignment:NSTextAlignmentRight];
    [_numberOfDeviceLabel setTextColor:[UIColor colorWithRed:0.463 green:0.392 blue:0.286 alpha:1.000]];
    [cellView addSubview:_numberOfDeviceLabel];
    UIView *routerSignView = [[UIView alloc]initWithFrame:CGRectMake(_numberOfDeviceLabel.frame.size.width + _numberOfDeviceLabel.frame.origin.x, 0, cellViewWidth*scale3, cellViewHeight)];
    [cellView addSubview:routerSignView];
    UIImageView *routerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(3, 9, 25, 25)];
    [routerImageView setImage:[UIImage imageNamed:@"信道图标"]];
    [routerSignView addSubview:routerImageView];
    //当前选择的通道
    audioIndicatorView = [[UIImageView alloc]initWithFrame:CGRectMake(routerSignView.frame.size.width + routerSignView.frame.origin.x , 17, 15, 10)];
    [audioIndicatorView setImage:[UIImage imageNamed:@"选中信道"]];
    [cellView addSubview:audioIndicatorView];
    [audioIndicatorView setHidden:YES];

    return cellView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *cellView = [self getCellView];
        [self.contentView addSubview:cellView];
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(CGFloat)projectItemCellHeight{
    return 44.0f;
}

@end
