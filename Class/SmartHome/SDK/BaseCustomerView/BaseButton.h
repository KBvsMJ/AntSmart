//
//  BaseButton.h
//  BaseFrame
//
//  Created by ledmedia on 13-2-19.
//  Copyright (c) 2013年 wally. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseButton : UIButton
-(id)initWithFrame:(CGRect)frame andNorImg:(NSString *)norimage andHigImg:(NSString *)higimg andTitle:(NSString *)titlestr;
-(id)initWithFrame:(CGRect)frame andNorImg:(NSString *)norimage andHigImg:(NSString *)higimg andTitle:(NSString *)titlestr andTag:(NSInteger)tagstr;
@end
