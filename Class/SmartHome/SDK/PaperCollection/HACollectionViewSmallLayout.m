//
//  HACollectionViewSmallLayout.m
//  Paper
//
//  Created by Heberti Almeida on 04/02/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

#import "HACollectionViewSmallLayout.h"

@implementation HACollectionViewSmallLayout

- (id)init
{
    if (!(self = [super init])) return nil;
    
    self.itemSize = CGSizeMake(SCREEN_CGSIZE_WIDTH/2.8-((SCREEN_CGSIZE_WIDTH/2.8)/8.0),(SCREEN_CGSIZE_HEIGHT-64)/3.0);
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    self.sectionInset = UIEdgeInsetsMake(SCREEN_CGSIZE_HEIGHT - 64 - (SCREEN_CGSIZE_HEIGHT-64)/3.0, 2, 2, 2);
    self.minimumInteritemSpacing = 10.0f;
    self.minimumLineSpacing = 2.0f;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}

@end
