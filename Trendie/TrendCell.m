//
//  TrendCell.m
//  Trendie
//
//  Created by Training7 on 17/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import "TrendCell.h"
#import <QuartzCore/QuartzCore.h>

@interface TrendCell ()

@property (nonatomic, strong, readwrite) UIImageView *imageView;

@end

@implementation TrendCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor blackColor];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 3.0f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.5f;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        [self.contentView addSubview:self.imageView];
        
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        self.indicator.clipsToBounds = YES;
        self.indicator.frame = self.bounds;
        self.indicator.hidden = YES;
        
        [self.contentView addSubview:_indicator];
        
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
}

- (void)setDelegate:(id)delegate
{
    _delegate = delegate;
    [_collectionView setDelegate:_delegate];
    [_collectionView setDataSource:_delegate];
}

@end
