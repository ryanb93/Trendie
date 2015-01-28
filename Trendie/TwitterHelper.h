//
//  TwitterHelper.h
//  Trendie
//
//  Created by Training7 on 17/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface TwitterHelper : NSObject

+ (instancetype)sharedInstance;


- (void)getLocationListWithHandler:(void (^)(NSArray *success))handler;

- (void)getTrendingTopicsWithHandler:(void (^)(NSArray *success))handler usingLocation:(long)location;

- (void)requestTwitterAccessForViewController:(UIViewController *)controller withHandler:(void(^)(bool result))handler;

@end
