//
//  TwitterHelper.m
//  Trendie
//
//  Created by Training7 on 17/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "TwitterHelper.h"

static BOOL const DEBUG_MODE = NO;

@interface TwitterHelper ()

- (BOOL)userHasAccessToTwitter;

@property (nonatomic) ACAccountStore *accountStore;
@property (nonatomic) BOOL twitterLoggedIn;

@end

@implementation TwitterHelper


+ (instancetype)sharedInstance {
    static TwitterHelper *helper = nil;
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
        _accountStore = [[ACAccountStore alloc] init];
        
    }
    return self;
}

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)getTrendingTopicsWithHandler:(void (^)(NSArray *success))handler usingLocation:(long)location
{
    
    if(DEBUG_MODE) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = 0; i < 10; i++) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:@"#swagyolo" forKey:@"name"];
            [array addObject:dict];
        }
        handler(array);
        return;
    }
    
    if ([self userHasAccessToTwitter]) {
        
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             //We have access to the account.
             if(granted)
             {
                 
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
                 
                 
                 long tmpLocation = location;
                 if(tmpLocation < 0 || !tmpLocation) {
                     tmpLocation = 1;
                 }
                 
                 NSString *requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/trends/place.json?id=%ld", tmpLocation];
                 
                 NSURL *url = [NSURL URLWithString:requestString];

                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:nil];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:
                  ^(NSData *responseData,
                    NSHTTPURLResponse *urlResponse,
                    NSError *error) {
                      
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 &&
                              urlResponse.statusCode < 300) {
                              
                              NSError *jsonError;
                              
                              NSDictionary *timelineData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                           options:NSJSONReadingAllowFragments
                                                                                             error:&jsonError];
                              
                              for(NSDictionary *item in timelineData) {
                                  handler([item objectForKey:@"trends"]);
                              }
                              
                              if (!timelineData) {
                                  // Our JSON deserialization went awry
                                  NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          }
                          else {
                              // The server did not respond ... were we rate-limited?
                              NSLog(@"The response status code is %ld", (long)urlResponse.statusCode);
                              
                              NSMutableArray *array = [[NSMutableArray alloc] init];
                              
                              for (int i = 0; i < 10; i++) {
                                  NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                  [dict setObject:@"#hobbit" forKey:@"name"];
                                  [array addObject:dict];
                              }
                    
                              handler(array);
                              
                          }
                      }
                  }];
                 
             }
         }];
    }
}

- (void)getLocationListWithHandler:(void (^)(NSArray *success))handler
{
    
    if(DEBUG_MODE) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = 0; i < 10; i++) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:@"Country" forKey:@"10"];
            [array addObject:dict];
        }
        handler(array);
        return;
    }
    
    if ([self userHasAccessToTwitter]) {
        
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if(granted)
             {
                 NSArray *twitterAccounts =
                 [self.accountStore accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/trends/available.json"];
                 
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:nil];
                 
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 [request performRequestWithHandler:
                  ^(NSData *responseData,
                    NSHTTPURLResponse *urlResponse,
                    NSError *error) {
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 &&
                              urlResponse.statusCode < 300) {
                              
                              NSError *jsonError;
                              
                              NSArray *timelineData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                           options:NSJSONReadingAllowFragments
                                                                                             error:&jsonError];
                              
                              handler(timelineData);

                              if (!timelineData) {
                                  // Our JSON deserialization went awry
                                  NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          }
                          else {
                              // The server did not respond ... were we rate-limited?
                              NSLog(@"The response status code is %ld", (long)urlResponse.statusCode);
                              
                              NSMutableArray *array = [[NSMutableArray alloc] init];
                              
                              for (int i = 0; i < 10; i++) {
                                  NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                  [dict setObject:@"Country" forKey:@"10"];
                                  [array addObject:dict];
                              }
                                                            
                              handler(array);
                              
                          }
                      }
                  }];
                 
             }
         }];
    }
}


- (void)requestTwitterAccessForViewController:(UIViewController *)controller withHandler:(void (^)(bool success))handler
{
    if ([self userHasAccessToTwitter]) {
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             //We have access to the account.
             if(granted)
             {
                 _twitterLoggedIn = YES;
             }
             //We don't have access, must be turned off in settings.
             else {
                 _twitterLoggedIn = NO;
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Permission Denied" message:@"We could not access your Twitter account, please check in Settings that Trendie has permissions to access it." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [alert show];
                 });
             }
             NSLog(@"hello");

             handler(_twitterLoggedIn);
         }];
    }
    else {
        /**
         * Hacky way of opening the Settings application on iOS 5.1+
         * We get given a free UIAlertView prompting the user to set up
         * a new Twitter account in the Settings app.
         */
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:
                                               SLServiceTypeTwitter];
        [controller presentViewController:tweetSheet animated:NO completion:^{
            [controller dismissViewControllerAnimated:NO completion:nil];
        }];
        _twitterLoggedIn = NO;
        handler(_twitterLoggedIn);
    }
}

@end
