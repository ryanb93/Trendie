//
//  TrendDetailViewController.m
//  Trendie
//
//  Created by Training7 on 18/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import "TrendDetailViewController.h"
#import "TrendAlbumTitleReusableView.h"

static NSString * const PhotoCellIdentifier = @"TrendCell";
static NSString * const AlbumTitleIdentifier = @"AlbumTitle";

@interface TrendDetailViewController ()

@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;

@property (nonatomic, weak) IBOutlet TrendPhotoAlbumLayout *photoAlbumLayout;

@end

@implementation TrendDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.thumbnailQueue = [[NSOperationQueue alloc] init];
        self.thumbnailQueue.maxConcurrentOperationCount = 3;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     
    [self.collectionView registerClass:[TrendCell class]
            forCellWithReuseIdentifier:PhotoCellIdentifier];
    [self.collectionView registerClass:[TrendAlbumTitleReusableView class]
            forSupplementaryViewOfKind:PhotoAlbumLayoutAlbumTitleKind
                   withReuseIdentifier:AlbumTitleIdentifier];
    [self setTitle:[[self album] name]];
    
}

- (void)popViewController
{
    [UIView transitionWithView: self.view
                      duration: 0.7f
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^{
                        [[self navigationController] popViewControllerAnimated:NO];
                    }
                    completion: nil ];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_previousCell setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_previousCell setHidden:NO];
    
    [UIView animateWithDuration:0.8f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         
                         [_previousCell setFrame:CGRectMake(25.0f, 100.0f, _previousCell.frame.size.height, _previousCell.frame.size.width)];
                     }
                     completion:nil];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionView Code

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Get a TrendCell object.
    TrendCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier
                                                                     forIndexPath:indexPath];
    if(self.album && self.album.photos.count != 0) {
        //Get the album object for this section.
        TrendAlbum *album = self.album;
        //Get the photo for this album.
        TrendPhoto *photo = album.photos[indexPath.section];
        
        //Load photo images in the background.
        __weak TrendDetailViewController *weakSelf = self;
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
                }
            });
        }];
        
        //If this is the top image then we want to render this fast.
        if(indexPath.item == 0) {
            operation.queuePriority = NSOperationQueuePriorityVeryHigh;
        }
        else {
            operation.queuePriority = NSOperationQueuePriorityVeryLow;
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
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.album.photos.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped");
    
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
    if(self.album && self.album.photos.count != 0) {
        TrendAlbum *album = self.album;
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
