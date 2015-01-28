//
//  TrendCell.h
//  Trendie
//
//  Created by Training7 on 17/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrendCell : UICollectionViewCell

@property (nonatomic, weak) id delegate;
@property (weak, nonatomic) IBOutlet UILabel *hashtagLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic, readonly) UIActivityIndicatorView *indicator;

@property (nonatomic, strong, readonly) UIImageView *imageView;

@end
