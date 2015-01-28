//
//  TrendsViewController.h
//  Trendie
//
//  Created by Training7 on 17/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramHelper.h"
#import "TwitterHelper.h"
#import "TrendPhotoAlbumLayout.h"
#import "LocationPickerViewController.h"

@interface TrendsViewController : UIViewController<UICollectionViewDataSource,
UICollectionViewDelegate, LocationPickerDelegate>
//The collection view which will hold cells for each of the top trends.
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

//An array which will hold the trending hashtags from twitter.
@property (nonatomic, strong) NSMutableArray *trendStrings;
@property (nonatomic, strong) NSMutableDictionary *trendCache;

@property (nonatomic, strong) UIPopoverController *locationPopover;
@property (nonatomic, strong) LocationPickerViewController *locationPicker;
@property (nonatomic, strong) UIBarButtonItem *locationButton;

@property (nonatomic, strong) UIRefreshControl *refreshControl;


@property (nonatomic, strong) NSURLSessionConfiguration *backgroundConfiguration;
@property (nonatomic, strong) NSURLSession *backgroundSession;


//Two arrays to hold our location data. We will show names, return woeids.
@property (nonatomic, strong) NSMutableArray *locationNames;
@property (nonatomic, strong) NSMutableArray *locationWoeids;

@property (nonatomic, strong) NSMutableDictionary *locations;

@property (nonatomic, assign) long trendsLocation;

@property (nonatomic, strong) UIImageView *imgView;

@end
