//
//  InstagramHelper.m
//  Trendie
//
//  Created by Training7 on 18/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import "InstagramHelper.h"

static NSString *SEARCH_URL = @"https://api.instagram.com/v1/tags/%@/media/recent?access_token=%@";

static NSString *CLIENT_ID = @"cc5844ab4bdf4bc4aa3659b4b7c9fb80";

@implementation InstagramHelper


+ (instancetype)sharedInstance {
    static InstagramHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[self alloc] init];
    });
    return helper;
}


- (id)init
{
    self = [super init];
    if(self) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)getPhotoURLsWithHandler:(void (^)(NSDictionary *result, NSString *trend))handler forValue:(NSString *)searchTerm;
{
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    NSString *oneword = [searchTerm stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *stripSearch = [oneword stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSString *webStringURL = [stripSearch stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if(accessToken) {
        NSString *urlString = [NSString stringWithFormat:SEARCH_URL, webStringURL, accessToken];
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:_queue completionHandler:^(NSURLResponse *response, NSData *urlData, NSError *error)
         {
             
             NSString *results = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
            
             if(error) {
                 NSLog(@"Could not reach the Instagram server.");
             }
             
             //Create a dictionary using the response data.
             NSDictionary *responseObject =
             [NSJSONSerialization JSONObjectWithData: [results dataUsingEncoding:NSUTF8StringEncoding]
                                             options: kNilOptions
                                               error: &error];
             
             handler(responseObject, searchTerm);
             
             if(error) {
                 NSLog(@"JSON failed with error: %@", [error localizedDescription]);
             }
             
         }];
        
    }
    else {
        NSLog(@"User is not logged into instagram");
    }
    
}

@end
