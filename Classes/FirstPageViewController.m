//
//  FirstPageViewController.m
//  Daily Trojan
//
//  Created by Ralf Cheung on 7/19/13.
//
//

#import "FirstPageViewController.h"
#import "UIImage+Resize.h"
#import "FlickrFetcher.h"

@interface FirstPageViewController ()

@property (nonatomic, retain) UIButton *newsLabel;
@property (nonatomic, retain) UIButton *sportsLabel;
@property (nonatomic, retain) UIButton *lifestyleLabel;
@property (nonatomic, retain) UIButton *opinionLabel;

@end


@implementation FirstPageViewController

@synthesize newsLabel, sportsLabel, lifestyleLabel, opinionLabel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithTitles{
    self = [super init];
    if (self) {
        
    }
    return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //    @"http://dailytrojan.com/category/news//feed/";
    //    @"http://dailytrojan.com/category/lifestyle//feed/";
    //    @"http://dailytrojan.com/category/sports//feed/";
    //    @"http://dailytrojan.com/category/opinion//feed/";
    
    self.view.backgroundColor = [UIColor whiteColor];
    newsLabel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sportsLabel =  [UIButton buttonWithType:UIButtonTypeRoundedRect];
    lifestyleLabel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    opinionLabel = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    
    [newsLabel setTitle:@"New building for Interactive Media Program holds top resources" forState:UIControlStateNormal];
    [sportsLabel setTitle:@"Adam Landecker collects another postseason award" forState:UIControlStateNormal];
    [lifestyleLabel setTitle:@"Neighborhood Academic Initiative continues to help students excel" forState:UIControlStateNormal];
    [opinionLabel setTitle:@"Failed to get token, error: Error Domain continues to help students " forState:UIControlStateNormal];
    
    [newsLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sportsLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [lifestyleLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [opinionLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

//    [newsLabel setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [sportsLabel setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [lifestyleLabel setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [opinionLabel setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
//    newsLabel.titleLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
//    newsLabel.titleLabel.layer.shadowOffset = CGSizeMake(0.3f, 0.3f);
//    newsLabel.titleLabel.layer.shadowOpacity = 1.0f;
//    newsLabel.titleLabel.layer.shadowRadius = 0.4f;
//    
    newsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    sportsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    lifestyleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    opinionLabel.translatesAutoresizingMaskIntoConstraints = NO;


    newsLabel.titleLabel.numberOfLines = 3;
    sportsLabel.titleLabel.numberOfLines = 3;
    lifestyleLabel.titleLabel.numberOfLines = 3;
    opinionLabel.titleLabel.numberOfLines = 3;

    dispatch_queue_t loaderQ = dispatch_queue_create("flickr latest loader", NULL);
    dispatch_async(loaderQ, ^{

        [self loadPhoto];
    });
    
    [self.view addSubview:newsLabel];
    [self.view addSubview:sportsLabel];
    [self.view addSubview:lifestyleLabel];
    [self.view addSubview:opinionLabel];
    
    
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(newsLabel, sportsLabel, lifestyleLabel, opinionLabel);
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-300-[newsLabel]-10-[sportsLabel(==newsLabel)]-10-[lifestyleLabel(==sportsLabel)]-10-[opinionLabel(==lifestyleLabel)]-10-|" options:NSLayoutFormatDirectionMask metrics:nil views:viewDictionary]];
   
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[newsLabel]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[sportsLabel]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[lifestyleLabel]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[opinionLabel]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewDictionary]];
    
}

- (void) loadPhoto{
    
    UIImage *image = [self loadFromFlickr];

    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;

    NSData * binaryImageData = UIImagePNGRepresentation(image);
    
    [binaryImageData writeToFile:[basePath stringByAppendingPathComponent:@"myfile.jpg"] atomically:YES];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];

        imageView.image = [imageView.image resizedImageByMagick:@"640x960#"];
        [self.view addSubview:imageView];
        
        [imageView.superview sendSubviewToBack:imageView];

        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[imageView]|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];

    });
    
    
}

-(UIImage *) loadFromFlickr{
    NSArray *photoArray = [FlickrFetcher uscPhotos];
    NSURL *url = [FlickrFetcher urlForPhoto:photoArray[arc4random() % 50] format:FlickrPhotoFormatLarge];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    return [UIImage imageWithData:data];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
