//
//  LoginViewController.m
//  Trendie
//
//  Created by Training7 on 16/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()


@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Login"];
        
//        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(closeView)];
//        [[self navigationItem] setLeftBarButtonItem:item];
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    //Do this here, otherwise we dismiss before view has finished showing.
    [super viewDidAppear:animated];
    [self authorize];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)closeView
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)authorize
{
    NSString *scopeStr = @"scope=likes+comments+relationships";
    NSString *url = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&display=touch&%@&redirect_uri=http://ryanburke.co.uk/trendie.php&response_type=token", @"cc5844ab4bdf4bc4aa3659b4b7c9fb80", scopeStr];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString * q = [request.URL absoluteString];
    NSLog(@"Loading URL: %@", q);
    NSArray *comps = [q componentsSeparatedByString:@"#"];
    if([[comps objectAtIndex:0] isEqualToString:@"http://ryanburke.co.uk/trendie.php"]) {
        //We are on the correct page. Get the access token.
        NSArray *tokenParam = [[comps objectAtIndex:1] componentsSeparatedByString:@"="];
        if([[tokenParam objectAtIndex:0] isEqualToString:@"access_token"]) {
            NSString *accessToken = [tokenParam objectAtIndex:1];
            if(accessToken) {
                NSLog(@"Using instagram auth access_token: %@", accessToken);
                [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"access_token"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"trendieFinishedLogin" object:self userInfo:nil];
                [self closeView];
                return FALSE;
            }
        }
    }
    else {
        NSArray *errorParam = [[[q componentsSeparatedByString:@"?"] objectAtIndex:1] componentsSeparatedByString:@"&"];
        NSMutableDictionary *errorDic = [[NSMutableDictionary alloc] init];
        for(NSString *string in errorParam) {
            NSArray *keypair = [string componentsSeparatedByString:@"="];
            if ([string rangeOfString:@"error"].location != NSNotFound) {
                [errorDic setObject:[keypair objectAtIndex:1] forKey:[keypair objectAtIndex:0]];
            }
        }
        
        if([errorParam count] == 3) {
            //User declined login.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"trendieFailedLogin" object:self userInfo:nil];
            [self closeView];
            return FALSE;
        }
    }
    return TRUE;
}

@end
