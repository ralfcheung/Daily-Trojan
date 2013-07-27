//
//  FirstPageViewController.m
//  Daily Trojan
//
//  Created by Ralf Cheung on 7/19/13.
//
//

#import "FirstPageViewController.h"

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
    
//    self.view.backgroundColor = [UIColor blackColor];
    
    newsLabel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sportsLabel =  [UIButton buttonWithType:UIButtonTypeRoundedRect];
    lifestyleLabel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    opinionLabel = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    [newsLabel setTitle:@"New building for Interactive Media Program holds top resources" forState:UIControlStateNormal];
    [sportsLabel setTitle:@"Adam Landecker collects another postseason award" forState:UIControlStateNormal];
    [lifestyleLabel setTitle:@"Neighborhood Academic Initiative continues to help students excel" forState:UIControlStateNormal];
    [opinionLabel setTitle:@"Failed to get token, error: Error Domain continues to help students " forState:UIControlStateNormal];
    
    
    newsLabel.backgroundColor = [UIColor blackColor];
    sportsLabel.backgroundColor = [UIColor blackColor];
    lifestyleLabel.backgroundColor = [UIColor blackColor];
    opinionLabel.backgroundColor = [UIColor blackColor];

//    [newsLabel setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [sportsLabel setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [lifestyleLabel setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [opinionLabel setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    newsLabel.titleLabel.textColor = [UIColor whiteColor];
    
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

    [self.view addSubview:newsLabel];
    [self.view addSubview:sportsLabel];
    [self.view addSubview:lifestyleLabel];
    [self.view addSubview:opinionLabel];
    
    
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(newsLabel, sportsLabel, lifestyleLabel, opinionLabel);
    
    NSArray *aconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-300-[newsLabel]-10-[sportsLabel(==newsLabel)]-10-[lifestyleLabel(==sportsLabel)]-10-[opinionLabel(==lifestyleLabel)]-10-|" options:NSLayoutFormatDirectionMask metrics:nil views:viewDictionary];
    for (int i = 0; i< aconstraints.count; i++) [self.view addConstraint:aconstraints[i]];
    

    aconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[newsLabel]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewDictionary];
    for (int i = 0; i< aconstraints.count; i++) [self.view addConstraint:aconstraints[i]];
    
    aconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[sportsLabel]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewDictionary];
    for (int i = 0; i< aconstraints.count; i++) [self.view addConstraint:aconstraints[i]];
    
    aconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[lifestyleLabel]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewDictionary];
    for (int i = 0; i< aconstraints.count; i++) [self.view addConstraint:aconstraints[i]];
    
    aconstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[opinionLabel]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewDictionary];
    for (int i = 0; i< aconstraints.count; i++) [self.view addConstraint:aconstraints[i]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
