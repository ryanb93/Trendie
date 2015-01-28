//
//  LocationPickerViewController.m
//  Trendie
//
//  Created by Training7 on 18/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import "LocationPickerViewController.h"

@interface LocationPickerViewController ()

@property (nonatomic, assign) BOOL useSearchResults;

@end

@implementation LocationPickerViewController

-(id)init
{
    if ([super init] != nil) {
        //Initialize the array
        _locationNames = [NSMutableArray array];
        _locationWoeids = [NSMutableArray array];
        _searchArray = [NSArray array];
        _useSearchResults = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    //Fix for search bar on iOS 7.
    if([self respondsToSelector:@selector(edgesForExtendedLayout)] ) {
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _visible = YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];

    _visible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(!_useSearchResults) {
        return [_locationNames count];
    }
    else {
        return [_searchArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
        
    if(!_useSearchResults) {
        cell.textLabel.text = [_locationNames objectAtIndex:indexPath.row];
    }
    else {
        cell.textLabel.text = [_searchArray objectAtIndex:indexPath.row];
    }
    
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    long woeid;
    NSString *name;
    
    if(!_useSearchResults) {
        woeid = [[_locationWoeids objectAtIndex:indexPath.row] longValue];
        name = [_locationNames objectAtIndex:indexPath.row];
    }
    else {
        name = [_searchArray objectAtIndex:indexPath.row];
        double index = [_locationNames indexOfObject:name];
        woeid = [[_locationWoeids objectAtIndex:index] longValue];
        
    }
    //Notify the delegate if it exists.
    if (_delegate != nil) {
        [_delegate selectedLocation:woeid locationName:name];
    }
}

#pragma mark - Search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length != 0) {
        NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];
        _searchArray = [_locationNames filteredArrayUsingPredicate:resultPredicate];
        [self setUseSearchResults:YES];
    }
    else {
        [self setUseSearchResults:NO];
    }
    [self.locationTable reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self setUseSearchResults:NO];
    [self.locationTable reloadData];
}

@end
