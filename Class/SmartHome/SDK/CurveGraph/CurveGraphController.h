//
//  CurveGraphController.h
//  蚂蚁智能
//
//  Created by IOS－001 on 15-4-23.
//  Copyright (c) 2015年 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeartLive.h"
#import "GradView.h"

@interface CurveGraphController : UIViewController
{
    UIImageView *bg;
    GradView *grad;
    UIView *backgroundView;
}

@property (atomic,strong) NSArray *dataSource;
+ (CurveGraphController *)sharedManager;

-(void)setGraphViewFrame:(CGRect)rect;
@end
