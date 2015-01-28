//
//  TrendsViewController.m
//  Trendie
//
//  Created by Training7 on 17/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import "TrendsViewController.h"
#import "LoginViewController.h"
#import "TrendCell.h"
#import "TrendAlbum.h"
#import "TrendPhoto.h"
#import "TrendAlbumTitleReusableView.h"
#import "TrendDetailViewController.h"

static NSString * const PhotoCellIdentifier = @"TrendCell";
static NSString * const AlbumTitleIdentifier = @"AlbumTitle";


@interface TrendsViewController ()

@property (atomic, strong) NSMutableArray *albums;
@property (nonatomic, weak) IBOutlet TrendPhotoAlbumLayout *photoAlbumLayout;
@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;

@property (nonatomic, assign) BOOL isRefreshing;


@end

@implementation TrendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Trending"];
        
        self.trendCache = [[NSMutableDictionary alloc] init];
        
        //Set up the location button and add to navigation bar.
        _locationButton = [[UIBarButtonItem alloc] initWithTitle:@"Location" style:UIBarButtonItemStylePlain target:self action:@selector(showLocations)];
        self.navigationItem.rightBarButtonItem = _locationButton;
        
        //Load the previous location.
        long ting = [[[NSUserDefaults standardUserDefaults] objectForKey:@"trends_location"] longValue];
        [self setTrendsLocation:ting];
        [self getLocations];
        
        self.trendStrings = [[NSMutableArray alloc] init];
        self.albums = [[NSMutableArray alloc] init];
        self.thumbnailQueue = [[NSOperationQueue alloc] init];
        self.thumbnailQueue.maxConcurrentOperationCount = 3;
        
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(startRefresh)
                  forControlEvents:UIControlEventValueChanged];
        [_refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Refreshing Images" ]];
        [_refreshControl setTintColor:[UIColor whiteColor]];
        
        _isRefreshing = NO;
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set the background of our view.
//    UIImage *patternImage = [UIImage imageNamed:@"tweed.png"];
//    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:patternImage];

    //Register the custom TrendCell class.
    [self.collectionView registerClass:[TrendCell class]
            forCellWithReuseIdentifier:PhotoCellIdentifier];
    
    //Register collection view.
    [self.collectionView registerClass:[TrendAlbumTitleReusableView class]
            forSupplementaryViewOfKind:PhotoAlbumLayoutAlbumTitleKind
                   withReuseIdentifier:AlbumTitleIdentifier];
    
    [self.collectionView addSubview:_refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
   
    //Get the instagram access token.
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    if(!accessToken) {
        //Show the Instagram login view.
        LoginViewController *lvc = [[LoginViewController alloc] init];
        UINavigationController *uinc = [[UINavigationController alloc] initWithRootViewController:lvc];
        [self presentViewController:uinc animated:YES completion:nil];
    }
    else {
        //Reload the collection view.
        [self reloadCollectionView];
    }
}

- (void)startRefresh
{
    if(_isRefreshing == NO) {
        _isRefreshing = YES;
        [self reloadCollectionView];
    }else
    [_refreshControl endRefreshing];
}

- (void)reloadCollectionView
{
    //Get the trending topics from twitter.
    NSNumber *number = [NSNumber numberWithLong:_trendsLocation];
    NSArray *cachedCopy = [_trendCache objectForKey:number];
    
    [[self trendStrings] removeAllObjects];
    
    void (^loadData)(NSArray *result) = ^(NSArray *result)
    {
        [_trendCache setObject:result forKey:number];
        
        //Add the trend name to the trend array.
        for(NSDictionary *dict in result) {
            NSString *trend = [dict objectForKey:@"name"];
            if(trend) {
                [[self trendStrings] addObject:trend];
            }
        }
        
        __block int completeCounter = 0;

        void (^processImages)(NSDictionary *result, NSString *trend) = ^(NSDictionary *result, NSString *trend)
        {
            
            //An array of 20 images from instagram for this trend.
            NSDictionary *results = [NSDictionary dictionaryWithDictionary:result];
            NSArray *data = [results objectForKey:@"data"];

            if(data.count != 0) {
                bool usingExisting = false;
                    
                //Create a new album or use previous.
                TrendAlbum *album = [[TrendAlbum alloc] init];
                [album setName:trend];

                for (TrendAlbum *existing in self.albums) {
                    if([[existing name] isEqualToString:trend]) {
                        album = existing;
                        usingExisting = true;
                        break;
                    }
                }
                [album setPhotoData:result];
            
                //For each image.
                for(int i = 0; i < data.count; i++) {
                    //Lets create a single photo for the list view to use.
                    NSDictionary *photoDict = [data objectAtIndex:i];
                    NSDictionary *imagesDict = [photoDict objectForKey:@"images"];
                    NSDictionary *thumbnailDict = [imagesDict objectForKey:@"thumbnail"];
                    NSString *thumbUrl = [thumbnailDict objectForKey:@"url"];

                    NSURL *photoURL = [NSURL URLWithString:thumbUrl];
                    TrendPhoto *photo = [TrendPhoto photoWithImageURL:photoURL];
                    
                    //If this is a new photo, add it, otherwise we already have it.
                    if(![[album photos] containsObject:photo]) {
                        [album addPhoto:photo];
                    }
                }
                
                if(!usingExisting) {
                    [self.albums addObject:album];
                }
            }
            
            long counter = ++completeCounter;
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [[self collectionView] reloadData];
                long count = [self trendStrings].count;
                if(counter == count) {
                    
                    NSMutableArray *remove = [NSMutableArray array];
                    
                    for(TrendAlbum *alb in [self albums]) {
                        if(![[self trendStrings] containsObject:alb.name]) {
                            [remove addObject:alb];
                        }
                    }
                    
                    [[self albums] removeObjectsInArray:remove];
                    
                    if(_isRefreshing) {
                        NSLog(@"Finished refreshing");
                        _isRefreshing = NO;
                        [_refreshControl endRefreshing];
                    }
                }
            });
        };
        
        //For each trend, we now want to get the images from Instagram.
        for(NSString *trend in [self trendStrings]) {
            [[InstagramHelper sharedInstance] getPhotoURLsWithHandler:processImages forValue:trend];
        }
    };

    if(cachedCopy != nil) {
        loadData(cachedCopy);
    }
    else {
        [[TwitterHelper sharedInstance] getTrendingTopicsWithHandler:loadData usingLocation:_trendsLocation];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Location code

- (void)setTrendsLocation:(long)trendsLocation
{
    _trendsLocation = trendsLocation;
    NSNumber *store = [NSNumber numberWithLong:trendsLocation];
    [[NSUserDefaults standardUserDefaults] setObject:store forKey:@"trends_location"];
    NSString *name = [_locations objectForKey:store];
    if(name) {
        [[self navigationItem] setTitle:[NSString stringWithFormat:@"Trending - %@", name]];
    }
    else {
        [[self navigationItem] setTitle:@"Trending"];
    }
}

- (void)getLocations
{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"locations.plist"]];
    
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:databasePath];
    
    void (^loadResults)(NSArray *result) = ^(NSArray *result)
    {
            if(result) {
                
                [NSKeyedArchiver archiveRootObject:result toFile:databasePath];
                
                _locationNames = [[NSMutableArray alloc] init];
                _locationWoeids = [[NSMutableArray alloc] init];
                for(NSDictionary *dict in result) {
                    [_locationNames addObject:[dict objectForKey:@"name"]];
                    [_locationWoeids addObject:[dict objectForKey:@"woeid"]];
                }
                _locations = [[NSMutableDictionary alloc] initWithObjects:_locationNames forKeys:_locationWoeids];
            }
    };
    
    if(array) {
        loadResults(array);
    }
    else {
        [[TwitterHelper sharedInstance] getLocationListWithHandler:loadResults];
    }
}

- (void)showLocations
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (!_locationPicker.visible){
            _locationPicker = [[LocationPickerViewController alloc] init];
            [_locationPicker setDelegate:self];
            [_locationPicker setLocationNames:_locationNames];
            [_locationPicker setLocationWoeids:_locationWoeids];
            _locationPopover = [[UIPopoverController alloc] initWithContentViewController:_locationPicker];
            [_locationPopover presentPopoverFromBarButtonItem:_locationButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else {
            [_locationPopover dismissPopoverAnimated:YES];
        }
    }
    else {
        _locationPicker = [[LocationPickerViewController alloc] init];
        [_locationPicker setDelegate:self];
        [_locationPicker setLocationNames:_locationNames];
        [_locationPicker setLocationWoeids:_locationWoeids];
        [_locationPicker setTitle:@"Location"];
        [self setHidesBottomBarWhenPushed:YES];
        [[self navigationController] pushViewController:_locationPicker animated:YES];
        [self setHidesBottomBarWhenPushed:NO];
    }
}


- (void)selectedLocation:(long)newLocation locationName:(NSString *)name
{
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.locationPopover dismissPopoverAnimated:YES];
    } else {
        [[self navigationController] popViewControllerAnimated:YES];
    }
    
    if(newLocation) {
        [self setTrendsLocation:newLocation];
    }
    else {
        [self setTrendsLocation:1];
    }
    [self reloadCollectionView];
}


#pragma mark - UICollectionView Code

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Get a TrendCell object.
    TrendCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier
                                              forIndexPath:indexPath];

    if(self.albums && self.albums.count != 0) {
        //Get the album object for this section.
        TrendAlbum *album = self.albums[indexPath.section];
        //Get the photo for this album.
        TrendPhoto *photo = album.photos[indexPath.item];
        
        
        if(indexPath.item == 0) {
            [[photoCell indicator] setHidden:NO];
            [[photoCell indicator] startAnimating];
        }
        
        //Load photo images in the background.
        __weak TrendsViewController *weakSelf = self;
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            //Create a new UIImage using the photo for the album.
            UIImage *image = [photo image];
            //On the main thread update the cell.
            dispatch_async(dispatch_get_main_queue(), ^{
                //If this cell is still visible.
                if ([weakSelf.collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
                    //Get the reference to the cell again as it could have been reused.
                    __strong TrendCell *cell = (TrendCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
                    cell.imageView.image = image;
                    [[cell indicator] stopAnimating];
                }
            });
        }];
        
        //If this is the top image then we want to render this fast.
        if(indexPath.item == 0) {
            operation.queuePriority = NSOperationQueuePriorityVeryHigh;
        }
       
        
        //Add this operation to the background queue.
        [self.thumbnailQueue addOperation:operation];
    }
    
    //Return the photo cell, it's image will be updated later.
    return photoCell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    TrendAlbum *album = self.albums[section];
    long count = album.photos.count;
    if(count > 1) count = 1;
    return count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.albums.count;
}

- (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    TrendCell *cell = (TrendCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    
//    UIImage *img = [self imageWithView:cell];
//    _imgView = [[UIImageView alloc] initWithImage:img];
//    
//    CGRect frame =[cell frame];
//    frame.origin.y += 60.0f;
//    [_imgView setFrame:frame];
//    
//    [[[self view] window] addSubview:_imgView];
    
    TrendDetailViewController *details = [[TrendDetailViewController alloc] init];
    [details setAlbum:[self.albums objectAtIndex:[indexPath section]]];
//    [details setPreviousCell:_imgView];
    [[self navigationController] pushViewController:details animated:YES];
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath;
{
    //Create the title view for this cell and return it.
    TrendAlbumTitleReusableView *titleView =
    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                       withReuseIdentifier:AlbumTitleIdentifier
                                              forIndexPath:indexPath];
    if(self.albums && self.albums.count != 0) {
        TrendAlbum *album = self.albums[indexPath.section];
        titleView.titleLabel.text = album.name;
    }
    return titleView;
}

#pragma mark - View Rotation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    double itemWidth = self.photoAlbumLayout.itemSize.width + 22;
    double viewWidth = [self view].bounds.size.height;
    double cols = viewWidth / itemWidth;
    self.photoAlbumLayout.numberOfColumns = floor(cols);

}


@end
