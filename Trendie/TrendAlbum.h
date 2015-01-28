//
//  BHAlbum.h
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TrendPhoto;

@interface TrendAlbum : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong, readonly) NSArray *photos;
@property (nonatomic, strong) NSDictionary *photoData;


- (void)addPhoto:(TrendPhoto *)photo;
- (BOOL)removePhoto:(TrendPhoto *)photo;
- (void)removeAllPhotos;

@end
