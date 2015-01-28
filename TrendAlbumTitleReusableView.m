//
//  TrendAlbumTitleReusableView.m
//  Trendie
//
//  Created by Training7 on 17/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import "TrendAlbumTitleReusableView.h"

@interface TrendAlbumTitleReusableView ()

@property (nonatomic, strong, readwrite) UILabel *titleLabel;

@end

@implementation TrendAlbumTitleReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        self.titleLabel.textColor = [UIColor blackColor];
        
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.titleLabel.text = nil;
}

@end
