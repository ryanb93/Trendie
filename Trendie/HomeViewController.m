//
//  HomeViewController.m
//  Trendie
//
//  Created by Training7 on 16/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "HomeViewController.h"
#import "LoginViewController.h"
#import "TrendsViewController.h"
#import "trendieAppDelegate.h"

@interface HomeViewController ()

@property (nonatomic) ACAccountStore *accountStore;

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Trendie"];
        _accountStore = [[ACAccountStore alloc] init];
        [self registerNotifications];
        twitterLoggedIn = NO;
        instagramLoggedIn = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!twitterLoggedIn) {
        [self requestTwitterAccess];
    }
    if(shouldDismiss) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidInstagramLogin)
                                                 name:@"trendieFinishedLogin"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userCanceledInstagramLogin)
                                                 name:@"trendieFailedLogin"
                                               object:nil];
}

- (IBAction)instagramLoginPressed:(id)sender
{
    LoginViewController *lvc = [[LoginViewController alloc] init];
    UINavigationController *fakeNav = [[UINavigationController alloc] initWithRootViewController:lvc];
    [[self navigationController] presentViewController:fakeNav animated:YES completion:nil];
}

- (IBAction)twitterLoginPressed:(id)sender
{
    [self requestTwitterAccess];
}

- (IBAction)infoButtonPressed:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Help" message:@"For Trendie to work we need to access both Instagram and Twitter. In order for us to do this we need to log you into both applications. We use OAuth technology and never see your username or password when logging in." delegate:self cancelButtonTitle:@"Thanks" otherButtonTitles:nil, nil];
    [alert show];
}

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}


- (void)requestTwitterAccess
{
    if ([self userHasAccessToTwitter]) {

        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             //We have access to the account.
             if(granted) {
                 twitterLoggedIn = YES;
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[self twitterButton] setEnabled:NO];
                     [[self twitterButton] setTitle:[NSString stringWithFormat:@"%@ - Done", [[[self twitterButton] titleLabel] text]] forState:UIControlStateDisabled];
                     [[self instagramButton] setEnabled:YES];
                 });
             }
             //We don't have access, must be turned off in settings.
             else {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Permission Denied" message:@"We could not access your Twitter account, please check in Settings that Trendie has permissions to access it." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [alert show];
                 });
             }
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
        [self presentViewController:tweetSheet animated:NO completion:^{
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
    }
}

- (void)userDidInstagramLogin
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    if(accessToken) {
        [[self instagramButton] setEnabled:NO];
        [[self instagramButton] setTitle:[NSString stringWithFormat:@"%@ - Done", [[[self instagramButton] titleLabel] text]] forState:UIControlStateDisabled];
        NSLog(@"User did login with access token: %@", accessToken);
        shouldDismiss = YES;
    }
}

- (void)userCanceledInstagramLogin
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error"
                                                    message:@"Sorry, you must authenticate your Instagram account to login."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

@end
