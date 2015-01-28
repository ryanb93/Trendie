//
//  TrendDetailViewController.h
//  Trendie
//
//  Created by Training7 on 18/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrendAlbum.h"
#import "TrendPhoto.h"
#import "TrendCell.h"
#import "TrendPhotoAlbumLayout.h"

@interface TrendDetailViewController : UIViewController<UICollectionViewDataSource,
UICollectionViewDelegate>

@property (nonatomic, strong) TrendAlbum *album;
@property (nonatomic, strong) UIImageView *previousCell;

@property (nonatomic, strong) NSMutableArray *photos;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
