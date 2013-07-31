//
//  WebViewController.m
//  RSSFun
//
//  Created by Ralf Cheung on 5/1/13.
//  Copyright 2013 Ralf Cheung. All rights reserved.
//

#import "WebViewController.h"
#import "IIViewDeckController.h"

@implementation WebViewController
@synthesize webView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStylePlain target:self.viewDeckController action:@selector(toggleLeftView)];
    UIColor * color = [UIColor colorWithRed:164/255.0f green:16/255.0f blue:7/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = color;

}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/



- (void)viewWillAppear:(BOOL)animated {
    
    NSURL *url = [NSURL URLWithString:@"https://twitter.com/dailytrojan"];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
    webView = nil;
}


@end
