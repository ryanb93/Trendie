//
//  TrendPhotoAlbumLayout.h
//  Trendie
//
//  Created by Training7 on 17/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString * const PhotoAlbumLayoutAlbumTitleKind;

@interface TrendPhotoAlbumLayout : UICollectionViewLayout

@property (nonatomic) UIEdgeInsets itemInsets;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat interItemSpacingY;
@property (nonatomic) NSInteger numberOfColumns;
@property (nonatomic) CGFloat titleHeight;

// the point to which the stack collapses
@property (nonatomic) CGPoint stackCenter;

// 0.0 means completely stacked, 1.0 results in the default FlowLayout
// Values bigger than 1.0 will spread the layout even more
@property (nonatomic) CGFloat stackFactor;

@end
