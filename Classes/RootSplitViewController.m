//
//  RootSplitViewController.m
//  Daily Trojan
//
//  Created by Ralf Cheung on 5/19/13.
//
//

#import "RootSplitViewController.h"

@interface RootSplitViewController ()

@end

@implementation RootSplitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (id)initWithLink:(NSString *)link name:(NSString*)name{
    self = [super init];
    if (self) {
//        self.feed = [link copy];
        self.title = name;
        //        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
        //            _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        //        } else {
        //            _bannerView = [[ADBannerView alloc] init];
        //        }
        //        _bannerView.delegate = self;
        
    }
    //    NSLog(@"%@\n", self.feed);
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
