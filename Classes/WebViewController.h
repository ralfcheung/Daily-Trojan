//
//  WebViewController.h
//  RSSFun
//
//  Created by Ralf Cheung on 5/1/13.
//  Copyright 2013 Ralf Cheung. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController {
    UIWebView *_webView;
}

@property (retain) IBOutlet UIWebView *webView;

@end
