//
//  LocationPickerViewController.h
//  Trendie
//
//  Created by Training7 on 18/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocationPickerDelegate <NSObject>
@required
- (void)selectedLocation:(long)newLocation locationName:(NSString *)name;
@end

@interface LocationPickerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

//Two arrays to hold our location data. We will show names, return woeids.
@property (nonatomic, strong) NSMutableArray *locationNames;
@property (nonatomic, strong) NSMutableArray *locationWoeids;

@property (nonatomic, strong) NSArray *searchArray;


@property (nonatomic, weak) id<LocationPickerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *locationTable;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchTopConstraint;

@property (nonatomic, assign, readonly) BOOL visible;


@end
