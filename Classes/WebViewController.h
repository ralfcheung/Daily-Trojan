//
//  WebViewController.h
//  RSSFun
//
//  Created by Ray Wenderlich on 1/24/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSSEntry;

@interface WebViewController : UIViewController {
    UIWebView *_webView;
}

@property (retain) IBOutlet UIWebView *webView;

@end
