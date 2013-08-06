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

-(void) viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:YES];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

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
    
    
    //    [newsLabel setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    //    [sportsLabel setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    //    [lifestyleLabel setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    //    [opinionLabel setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self setLooking:newsLabel];
    [self setLooking:sportsLabel];
    [self setLooking:lifestyleLabel];
    [self setLooking:opinionLabel];
       
    
    
    [self loadPhoto];
    
    [self.view addSubview:newsLabel];
//    [self.view addSubview:sportsLabel];
//    [self.view addSubview:lifestyleLabel];
//    [self.view addSubview:opinionLabel];
    
    
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(newsLabel, sportsLabel, lifestyleLabel, opinionLabel);
    
    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-300-[newsLabel]-10-[sportsLabel(==newsLabel)]-10-[lifestyleLabel(==sportsLabel)]-10-[opinionLabel(==lifestyleLabel)]-10-|" options:NSLayoutFormatDirectionMask metrics:nil views:viewDictionary]];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[newsLabel]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewDictionary]];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[sportsLabel]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewDictionary]];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[lifestyleLabel]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewDictionary]];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[opinionLabel]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewDictionary]];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-300-[newsLabel]-15-|" options:NSLayoutFormatDirectionMask metrics:nil views:viewDictionary]];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-700-[newsLabel]-|" options:NSLayoutFormatDirectionMask metrics:nil views:viewDictionary]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[newsLabel]|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewDictionary]];

}

- (void) loadPhoto{
    
    NSError *error = nil;
    NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:stringPath  error:&error];
    UIImage *ia;
    for(int i=0;i<[filePathsArray count];i++)
    {
        NSString *strFilePath = [filePathsArray objectAtIndex:i];
        
        if ([[strFilePath pathExtension] isEqualToString:@"jpg"]){
            NSString *imagePath = [[stringPath stringByAppendingFormat:@"/"] stringByAppendingFormat:strFilePath];
            NSData *data = [NSData dataWithContentsOfFile:imagePath];
            if(data){
                ia = [UIImage imageWithData:data];
            }
        }
        
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:ia];
    [self.view addSubview:imageView];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];

    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[imageView]|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];


    dispatch_queue_t loaderQ = dispatch_queue_create("flickr latest loader", NULL);
    dispatch_async(loaderQ, ^{
        
        UIImage *image = [self loadFromFlickr];
        
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        NSData * binaryImageData = UIImagePNGRepresentation(image);
        
        [binaryImageData writeToFile:[basePath stringByAppendingPathComponent:@"myfile.jpg"] atomically:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            imageView.image = image;
            [self switchPhotos:imageView :image];
            imageView.image = [imageView.image resizedImageByMagick:@"640x1136#"];
            [imageView.superview sendSubviewToBack:imageView];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
        });
    });
}

-(void) switchPhotos:(UIImageView *)imageView :(UIImage *)image{
    
    [UIView animateWithDuration:0.5 animations:^{
        imageView.image = image;
    } completion:^(BOOL finished) {

    }];

}

-(void) setLooking:(UIButton *) button{
    button.titleLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    button.titleLabel.layer.shadowOffset = CGSizeMake(0.3f, 0.3f);
    button.titleLabel.layer.shadowOpacity = 1.0f;
    button.titleLabel.layer.shadowRadius = 0.4f;
    button.titleLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor fontDescriptorWithFontAttributes: @{ UIFontDescriptorNameAttribute: @"HelveticaNeue-Light"}] size:25];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        button.titleLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor fontDescriptorWithFontAttributes: @{ UIFontDescriptorNameAttribute: @"HelveticaNeue-Light"}] size:40];

    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.numberOfLines = 3;
    button.translatesAutoresizingMaskIntoConstraints = NO;

}


-(UIImage *) loadFromFlickr{
    NSArray *photoArray = [FlickrFetcher uscPhotos];
    
    NSURL *url;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        url =[FlickrFetcher urlForPhoto:photoArray[arc4random() % 30] format:FlickrPhotoFormatOriginal];
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        url = [FlickrFetcher urlForPhoto:photoArray[arc4random() % 30] format:FlickrPhotoFormatLarge];

    NSData *data = [NSData dataWithContentsOfURL:url];
    return [UIImage imageWithData:data];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
