//
//  BHPhoto.m
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import "TrendPhoto.h"

@interface TrendPhoto ()

@property (nonatomic, strong, readwrite) UIImage *image;

@end

@implementation TrendPhoto

#pragma mark - Properties

- (UIImage *)image
{
    if (!_image && self.imageURL) {        
        NSData *imageData = [NSData dataWithContentsOfURL:self.imageURL];
        UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
        _image = image;
    }
    
    return _image;
}

#pragma mark - Lifecycle

+ (TrendPhoto *)photoWithImageURL:(NSURL *)imageURL
{
    return [[self alloc] initWithImageURL:imageURL];
}

- (id)initWithImageURL:(NSURL *)imageURL
{
    self = [super init];
    if (self) {
        self.imageURL = imageURL;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    
    TrendPhoto *pother = (TrendPhoto *)other;
    if (![[self.imageURL absoluteString] isEqualToString:[pother.imageURL absoluteString]])
        return NO;
    return YES;
}

@end
