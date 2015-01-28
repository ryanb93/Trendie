//
//  HomeViewController.h
//  Trendie
//
//  Created by Training7 on 16/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController {
    BOOL twitterLoggedIn;
    BOOL instagramLoggedIn;
    BOOL shouldDismiss;
}

- (IBAction)instagramLoginPressed:(id)sender;
- (IBAction)twitterLoginPressed:(id)sender;
- (IBAction)infoButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *instagramButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

@end
