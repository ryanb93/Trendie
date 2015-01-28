//
//  InstagramHelper.h
//  Trendie
//
//  Created by Training7 on 18/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstagramHelper : NSObject

+ (instancetype)sharedInstance;

- (void)getPhotoURLsWithHandler:(void (^)(NSDictionary *result, NSString *trend))handler forValue:(NSString *)searchTerm;

@property (nonatomic, strong) NSOperationQueue *queue;

@end
