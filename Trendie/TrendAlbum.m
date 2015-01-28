//
//  BHAlbum.m
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import "TrendAlbum.h"
#import "TrendPhoto.h"

@interface TrendAlbum ()

@property (nonatomic, strong) NSMutableArray *mutablePhotos;

@end

@implementation TrendAlbum

#pragma mark - Properties

- (NSArray *)photos
{
    return [self.mutablePhotos copy];
}


#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        self.mutablePhotos = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Photos

- (void)addPhoto:(TrendPhoto *)photo
{
    
    [self.mutablePhotos insertObject:photo atIndex:0];    
}

- (void)removeAllPhotos
{
    [self.mutablePhotos removeAllObjects];
}

- (BOOL)removePhoto:(TrendPhoto *)photo
{
    if ([self.mutablePhotos indexOfObject:photo] == NSNotFound) {
        return NO;
    }
    
    [self.mutablePhotos removeObject:photo];
    
    return YES;
}



@end
