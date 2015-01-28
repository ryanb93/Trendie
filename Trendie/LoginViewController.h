//
//  LoginViewController.h
//  Trendie
//
//  Created by Training7 on 16/12/2013.
//  Copyright (c) 2013 Ryan Burke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UIWebViewDelegate> {
    NSString *authURL;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
