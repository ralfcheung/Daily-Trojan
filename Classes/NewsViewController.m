
//  NewsViewController.m
//  RSSFun
//
//  Created by Ralf Cheung on 4/20/13.
//
//

#import "NewsViewController.h"
#import "TFHpple.h"
#import "AVFoundation/AVFoundation.h"
#import  <Social/Social.h>
#import <Accounts/Accounts.h>
#import "UINavigationBarTransparent.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "Story+DT.h"
#import "Reachability.h"
#import "UIImage+ImageEffects.h"
#import "WebImageOperations.h"

#define EMPTYVIEW 300
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface NewsViewController ()
@property(nonatomic, copy) NSString *url;
@property (nonatomic, retain) Entry *entry;
@property(nonatomic, retain) NSString *content;
@property (nonatomic, retain) IBOutlet UITextView* textView;
@property (nonatomic, retain) NSString *imageUrl;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) CIImage *inputImage;
@property (nonatomic, retain) CIContext *context;
@property (nonatomic, retain) IBOutlet UITextView *captions;
@property (nonatomic, retain) IBOutlet UITextView *titleText;
@property (nonatomic, retain) IBOutlet UIImageView* backgroundImage;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSMutableString *author;
@property (readwrite) BOOL visible;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) CIFilter *filter;
@property (nonatomic, retain) CIImage *result;
@property (nonatomic, retain) MBProgressHUD *HUD;
@property (nonatomic, strong) NSTextStorage *textStorage;

@end

@implementation NewsViewController
@synthesize url;
@synthesize entry;
@synthesize author;
@synthesize textView;
@synthesize content;
@synthesize imageUrl;
@synthesize backgroundImage;
@synthesize title;
@synthesize visible;
@synthesize captions = _captions;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize scrollView;
@synthesize filter;
@synthesize result;
@synthesize titleText;
@synthesize textStorage;

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    //    [self layoutAnimated:YES];
    //    [UIView beginAnimations:nil context:NULL];
    //    [UIView setAnimationDuration:1];
    //    [banner setAlpha:1];
    //    [UIView commitAnimations];
    
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    //    [UIView beginAnimations:nil context:NULL];
    //    [UIView setAnimationDuration:1];
    //    [banner setAlpha:0];
    //    [UIView commitAnimations];
    
}


-(CGSize)imageSizeAfterAspectFit:(UIImageView*)imgview{
    
    
    float newwidth;
    float newheight;
    
    UIImage *image=imgview.image;
    
    if (image.size.height>=image.size.width){
        newheight=imgview.frame.size.height;
        newwidth=(image.size.width/image.size.height)*newheight;
        
        if(newwidth>imgview.frame.size.width){
            float diff=imgview.frame.size.width-newwidth;
            newheight=newheight+diff/newheight*newheight;
            newwidth=imgview.frame.size.width;
        }
        
    }
    else{
        newwidth=imgview.frame.size.width;
        newheight=(image.size.height/image.size.width)*newwidth;
        
        if(newheight>imgview.frame.size.height){
            float diff=imgview.frame.size.height-newheight;
            newwidth=newwidth+diff/newwidth*newwidth;
            newheight=imgview.frame.size.height;
        }
    }
    
    NSLog(@"image after aspect fit: width=%f height=%f",newwidth,newheight);
    
    
    return CGSizeMake(newwidth, newheight);
    
}


-(id) initWithLink:(NSString *)link{
    if(self = [super init]){
        url = [link copy];
        return self;
        
    }else return nil;
}

-(id) initWithEntry:(Entry *)ent{
    if(self = [super init]){
        self.entry = ent;
        return self;
        
    }else return nil;
}



-(NSString*) getStringForTFHppleElement:(TFHppleElement *)element {
    
    NSMutableString *resultString = [NSMutableString new];
    
    // Iterate recursively through all children
    for (TFHppleElement *child in [element children]){
        if([[element tagName] isEqualToString:@"span"]){
            author = [NSMutableString new];
            NSString *authorSt = [self getStringForTFHppleElement:child];
            NSArray *names = [authorSt componentsSeparatedByString: @" "];
            [author appendString:@"By: "];
            for (__strong NSString *name in names){
                NSLog(@"%@", name);
                name = [name stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[name substringToIndex:1] capitalizedString]];
                [author appendFormat:@"%@ ", name];
            }
            entry.author = [author copy];
            
            [author appendFormat:@"\n\n"];
            //            NSLog(@"%@", author);
        }else if([[element tagName] isEqualToString:@"h1"]){
            title = [self getStringForTFHppleElement: child];
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
                title = [title stringByAppendingString:@"\n\n"];
            
        }
        else if([[element tagName] isEqualToString:@"p"]){
            
            NSString *st =[self getStringForTFHppleElement:child];
            st = [st stringByAppendingString:@"\n\n"];
            
            
            [resultString appendString:[self getStringForTFHppleElement:child]];
            [resultString appendFormat:@"\n\n"];
        }
    }
    
    // Hpple creates a <text> node when it parses texts
    if ([element.tagName isEqualToString:@"text"]) [resultString appendString:element.content];
    
    //    result = [result stringByReplacingOccurrencesOfString:@"â" withString:@"\'"];
    return resultString;
}


-(void) loadText{
    
    
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:entry.articleURL]];
    if(tutorialsHtmlData){
        NSString *str = [[NSString alloc] initWithData:tutorialsHtmlData encoding:NSUTF8StringEncoding];
        tutorialsHtmlData = [str dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
        
        NSString *tutorialsXpathQueryString = @"//p[@class='author']/span[@class='upper'] | //div[@class='post']/h1 | //div[@class='entry']/p";
        NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
        content = [[NSString alloc] init];
        for (TFHppleElement *element in tutorialsNodes) {
            content = [content stringByAppendingString:[self getStringForTFHppleElement: element]];
            //        content = [content stringByAppendingString:@"\n\n"];
            
        }
        
        //    content = [content stringByReplacingOccurrencesOfString:@"\n\n\n" withString:@"\n\n"];
        
        //    NSLog(@"%@", content);
        NSString *captionString;
        
        tutorialsXpathQueryString = @"//p[@class='wp-caption-text']";
        tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
        if(tutorialsNodes)
            captionString = [self getStringForTFHppleElement:[tutorialsNodes lastObject]];
        
        entry.story = [Story storyinManagedObjectContext:_managedObjectContext storyContent:content picture:nil caption:captionString];
        
        tutorialsXpathQueryString = @"//a";
        tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
        
        for (TFHppleElement *element in tutorialsNodes) {
            NSRange range = [[element objectForKey: @"href"] rangeOfString:@".jpg"];
            if(range.location == NSNotFound){}
            else{
                imageUrl = [[element objectForKey:@"href"] copy];
                break;
            }
        }
    }
    //change it to 'read'
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    fetchRequest.entity = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext:_managedObjectContext];

    else{
    //if([content isEqual: @""]){  //offline reading mode
        //        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"articleURL = %@", url];
        //        NSArray *fetchResult = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
        //        Entry *e = [fetchResult lastObject];
        content = entry.story.content;
        title = entry.articleTitle;
        author = [[NSMutableString alloc] initWithString:entry.author];
//        if(entry.story.captions) captionString = entry.story.captions;
    }
    
    //For Facebook style description, uncheck Clip Subviews
    dispatch_async(dispatch_get_main_queue(), ^{
        UIScrollView *scrollText;
        [scrollText addSubview:textView];
        textView.textColor = [UIColor whiteColor];
        
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle: UIFontTextStyleHeadline1];
            UIFontDescriptor *titleFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
            
            UIFontDescriptor *helveticaNeueFamily = [UIFontDescriptor fontDescriptorWithFontAttributes: @{ UIFontDescriptorFamilyAttribute: @"Helvetica Neue"}];
        NSArray *matches = [helveticaNeueFamily matchingFontDescriptorsWithMandatoryKeys:nil];
            UIFont *titleFont;

            for (UIFontDescriptor *desc in matches) {
                if([desc.postscriptName isEqualToString:@"HelveticaNeue-Light"]){
                    titleFont = [UIFont fontWithDescriptor:desc size:28.0f];
//                    desc 
                }
            }

            
            //HelveticaNeue-Light, UIFontDescriptorNameAttribute
//        NSLog(@"%@", matches);
            
            
            //        NSDictionary *titleDic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline1], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
            
            NSDictionary *titleDic = [NSDictionary dictionaryWithObjectsAndKeys:titleFont, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
            
            NSDictionary *nameDic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont preferredFontForTextStyle:UIFontTextStyleBody], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
            

            [textStorage beginEditing];
            [textStorage setAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", entry.articleTitle] attributes:titleDic]];
            [textStorage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [author copy]] attributes:nameDic]];
            [textStorage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:entry.story.content attributes:dict]];
            [textStorage endEditing];
            
            NSLog(@"%f", textView.contentSize.height);
        }else{
//        CGSize frameSize = [textView.text sizeWithFont:textView.textStorage.length];
//        NSLog(@"%f", frameSize.height);
            textView.text = [NSString stringWithFormat:@"%@%@", author, entry.story.content];
            titleText.text = entry.articleTitle;
        }

        
        if(entry.story.captions){
            _captions.text = entry.story.captions;
            _captions.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
            _captions.textColor = [UIColor whiteColor];
            _captions.alpha = 0;
            _captions.editable = NO;
            _captions.userInteractionEnabled = YES;
            [_captions setScrollEnabled:YES];
//            [_captions setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
//                if([_captions respondsToSelector:@selector(setFont:)])
                [_captions setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption2]];
            _captions.isAccessibilityElement = YES;
            _captions.accessibilityLabel = @"Captions";
            
        }
        
        //        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        //        fetchRequest.entity = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext:_managedObjectContext];
        //        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"articleTitle = %@", title];
        //
        //        NSArray *array = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
        //        Entry *e = [array lastObject];
        //        Story *s = [Story storyinManagedObjectContext:_managedObjectContext storyContent:content picture:nil caption:captionString];
        //        e.story = s;
        //        NSNumber *num = [NSNumber numberWithInt:1];
        //        NSLog(@"%i", [num integerValue]);
        entry.read = [NSNumber numberWithInt:1];
        NSError *error;
        [_managedObjectContext save:&error];
        if(error) NSLog(@"%@", [error description]);
        

        visible = YES;
        
//        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            [self TFHppleFinishLoading];
        
    });
//    [self getRanking];
    
}

-(void) TFHppleFinishLoading{
    
    CGFloat titleHeight = titleText.contentSize.height;
    CGFloat textHeight = textView.contentSize.height;
    
    CGRect titleFrame = titleText.frame;
    titleFrame.size.height = titleHeight;
    titleText.frame = titleFrame;
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([UIScreen mainScreen].scale == 2.0f) {
            CGSize sizeResult = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            sizeResult = CGSizeMake(sizeResult.width * scale, sizeResult.height * scale);
            
            if(sizeResult.height == 960){
                titleText.frame = CGRectMake(0, 680 - EMPTYVIEW -titleText.contentSize.height - 20, titleText.frame.size.width, titleText.frame.size.height);
                textView.frame = CGRectMake(0, titleText.frame.origin.y + titleHeight, textView.frame.size.width, textHeight);
                
                
            }
            if(sizeResult.height == 1136){
                titleText.frame = CGRectMake(0, 770 - EMPTYVIEW -titleText.contentSize.height - 20, titleText.frame.size.width, titleText.frame.size.height);
                textView.frame = CGRectMake(0, titleText.frame.origin.y + titleHeight, textView.frame.size.width, textHeight);
                
            }
        } else {
            //            NSLog(@"iPhone Standard Resolution");
        }
    }
    
    
    
    CGSize size = scrollView.contentSize;
    size.height = textHeight + titleHeight + EMPTYVIEW + 80;
    scrollView.contentSize = size;
    
    NSLog(@"%f", scrollView.contentSize.height);
}

- (void)loadDetails {
    
    [self loadText];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.opacity = 1;
    CAGradientLayer *topGradient = [CAGradientLayer layer];
    gradient.opacity = 1;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([UIScreen mainScreen].scale == 2.0f) {
            CGSize sizeResult = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            sizeResult = CGSizeMake(sizeResult.width * scale, sizeResult.height * scale);
            
            if(sizeResult.height == 960){
                
                gradient.frame = CGRectMake(0, 300 , [UIScreen mainScreen].bounds.size.width, 180);
                topGradient.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40);
            }
            if(sizeResult.height == 1136){
                //                NSLog(@"iPhone 5 Resolution");
            }
        } else {
            //            NSLog(@"iPhone Standard Resolution");
        }
    }
    //    gradient.frame = CGRectMake(0, ([UIScreen mainScreen].bounds.size.height * 5 / 6) /2 , [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height / 6);
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
    topGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    //    [self.view.layer insertSublayer:gradient atIndex:0];
    [self.view.layer insertSublayer:topGradient below:textView.layer];
    [self.view.layer insertSublayer:gradient below:textView.layer];
    
    if(imageUrl){
        [self generateImage];
    }else{

    }
    
//    NSData* data = [content dataUsingEncoding:NSUTF8StringEncoding];
//    content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}


-(void) shareButton:(id)sender{
    
    
    NSArray *array = [NSArray arrayWithObjects:titleText.text, textView.text, nil];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
    [self presentViewController:avc animated:YES completion:nil];
    
}

- (void) generateImage{
    NSURL *link = [NSURL URLWithString:imageUrl];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSData *data = [NSData dataWithContentsOfURL:link];
        [backgroundImage setContentMode:UIViewContentModeScaleToFill];
        _image = [[UIImage alloc] initWithData:data];
        NSLog(@"Finished downloading image");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            backgroundImage.image = [_image applyBlurWithRadius:8 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil];
            backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
            
            [backgroundImage setClipsToBounds:YES];
            [backgroundImage.superview sendSubviewToBack:backgroundImage];
            
        });
        
    });
    
    
    
    
    //    CGRect frame = backgroundImage.frame;
    
    /*
     if(_image.size.height / _image.size.width > 1.1){
     [self imageViewAnimation:0 frame:frame];
     
     NSLog(@"Vertical\n");
     }
     else{
     
     [self imageViewAnimation:190 frame:_frame];
     frame.origin.x = -200;
     NSLog(@"Horizontal %f\n", _image.size.height / _image.size.width);
     }
     backgroundImage.frame = frame;
     [UIView commitAnimations];*/
    
    //    [UIView animateWithDuration:20
    //                          delay:0
    //                        options:UIViewAnimationOptionCurveLinear
    //                     animations:^{
    //                         CGRect imageViewFrame = self.backgroundImage.frame;
    //                         NSLog(@"%f %f\n", backgroundImage.image.size.height, backgroundImage.image.size.width);
    //                         NSLog(@"%f \n", imageViewFrame.origin.x - backgroundImage.image.size.width);
    //                         NSLog(@"%f \n", [[UIScreen mainScreen] bounds].size.width);
    //                         CGRect a = AVMakeRectWithAspectRatioInsideRect(backgroundImage.image.size, imageViewFrame);
    //                         imageViewFrame.origin.x = CGRectGetWidth(imageViewFrame) / -2;
    //                         self.backgroundImage.frame = imageViewFrame;
    //                     }completion:nil];
    
    
    
}

- (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize {
    CGSize scaledSize = newSize;
    float scaleFactor = 1.0;
    if( image.size.width > image.size.height ) { //horizontal
        scaleFactor = image.size.width / image.size.height;
        scaledSize.width = newSize.width;
        scaledSize.height = newSize.height / scaleFactor;
    }
    else {//vertical
        scaleFactor = image.size.height / image.size.width;
        scaledSize.height = newSize.height;
        scaledSize.width = newSize.width / scaleFactor;
    }
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}


- (void) imageViewAnimation: (CGFloat) time frame:(CGRect)frame{
    frame.origin.x = time;
    backgroundImage.frame = frame;
    [UIView beginAnimations:@"animate" context:nil];
    [UIView setAnimationDuration:15];
    [UIView setAnimationTransition:UIViewAnimationOptionCurveEaseInOut forView:backgroundImage cache:YES];
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMethod:)];
    tapped.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapped];
    UIPanGestureRecognizer *swipe= [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(backPage:)];
    [self.view addGestureRecognizer:swipe];
    swipe.maximumNumberOfTouches = 2;
    swipe.minimumNumberOfTouches = 2;
    
    
    //    self.view.backgroundColor = [UIColor blackColor];
    //    [self.navigationController setValue:[[UINavigationBarTransparent alloc] init] forKey:@"navigationBar"];
    //    textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 260, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    
    
    
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    [self initializeViews];
    
    UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButton:)];
    [self.navigationItem setRightBarButtonItem:loadingView];
    
    [_captions setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.4f]];
    
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:_HUD];
    _HUD.delegate = self;
    _HUD.labelText = @"Loading...";
    [_HUD showWhileExecuting:@selector(loadDetails)
                    onTarget:self
                  withObject:nil
                    animated:YES];
    
    
    
    [self.view addSubview:_captions];
    
    
}

-(void) initializeViews{
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        
        scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        scrollView.scrollEnabled = YES;
        
        backgroundImage = [[UIImageView alloc] initWithFrame:scrollView.frame];
        self.view.backgroundColor = [UIColor blackColor];

        CGRect newTextViewRect = CGRectInset(self.view.bounds, 8., 10.);
        
        textStorage = [[NSTextStorage alloc] init];
        
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeMake(newTextViewRect.size.width, CGFLOAT_MAX)];
        
        container.widthTracksTextView = YES;
        [layoutManager addTextContainer:container];
        
        
        [layoutManager addTextContainer:container];
        [textStorage addLayoutManager:layoutManager];
        textView = [[UITextView alloc] initWithFrame:newTextViewRect textContainer:container];
        
        textView.editable = NO;
        textView.scrollEnabled = NO;
        textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        textView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
        //    textView.allowsEditingTextAttributes = NO;
        
        
        CGSize size = scrollView.contentSize;
        size.height = textView.contentSize.height + EMPTYVIEW;
        
        scrollView.contentSize = size;
        CGRect textViewFrame = textView.frame;
        textViewFrame.origin.y += EMPTYVIEW;
        textViewFrame.size = textView.contentSize;
        textView.frame = textViewFrame;
        
        
        
        
        //    [scrollView addSubview:view];
        [scrollView addSubview:textView];
        [self.view addSubview:scrollView];
        
    }else{  //iOS 6
        scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        //        scrollView.backgroundColor = [UIColor blackColor];
        backgroundImage = [[UIImageView alloc] initWithFrame:scrollView.frame];
        backgroundImage.backgroundColor = [UIColor blackColor];
        
        
        titleText = [[UITextView alloc] initWithFrame:CGRectMake(0, EMPTYVIEW, [[UIScreen mainScreen] bounds].size.width, 50)];
        //    titleText.font = [UIFont preferredFontForTextStyle:UIFontDescriptorTextStyleHeadline2];
        titleText.backgroundColor = [UIColor clearColor];
        titleText.textColor = [UIColor whiteColor];
        titleText.editable = NO;
        titleText.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
        
        textView = [[UITextView alloc] initWithFrame:CGRectMake(0, titleText.frame.origin.y + titleText.frame.size.height, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        textView.editable = NO;
        textView.scrollEnabled = NO;
        textView.backgroundColor = [UIColor blackColor];
        textView.alpha = 0.8;
        textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        
        textView.textColor = [UIColor blackColor];
        
        [scrollView addSubview:titleText];
        [scrollView addSubview:textView];
        [self.view addSubview:scrollView];
        
    }
    
    [self.view addSubview:backgroundImage];
    
}

-(void) bounceScrollView{
    
    
    CGFloat midHeight = scrollView.frame.size.height * 1.001;
    CAKeyframeAnimation* animation = [[self class] dockBounceAnimationWithViewHeight:midHeight];
    [scrollView.layer addAnimation:animation forKey:@"bouncing"];
}

+ (CAKeyframeAnimation*)dockBounceAnimationWithViewHeight:(CGFloat)viewHeight
{
    NSUInteger const kNumFactors = 30;
    CGFloat const kFactorsPerSec = 30.0f;
    CGFloat const kFactorsMaxValue = 128.0f;
    CGFloat factors[30] = {0, 3, 7, 9, 13, 15, 15, 13, 9, 5, 3, 0, 1.5, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0};
    
    NSMutableArray* transforms = [NSMutableArray array];
    
    for(NSUInteger i = 0; i < kNumFactors; i++){
        CGFloat positionOffset = factors[i] / kFactorsMaxValue * viewHeight;
        CATransform3D transform = CATransform3DMakeTranslation(0.0f, -positionOffset, 0.0f);
        
        [transforms addObject:[NSValue valueWithCATransform3D:transform]];
    }
    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.repeatCount = 1;
    animation.duration = kNumFactors * 1.0f/kFactorsPerSec;
    animation.fillMode = kCAFillModeForwards;
    animation.values = transforms;
    animation.removedOnCompletion = YES; // final stage is equal to starting stage
    animation.autoreverses = NO;
    
    return animation;
}


-(void) getRanking{
    
    NSString *n = textView.text;
    
    NSMutableDictionary *tags = [NSMutableDictionary dictionary];
    
    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
    
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes: [NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:options];
    tagger.string = n;
    
    [tagger enumerateTagsInRange:NSMakeRange(0, [n length])
                          scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass
                         options:options
                      usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
                          NSString *token = [n substringWithRange:tokenRange];
                          if([tag isEqualToString:NSLinguisticTagPersonalName] || [tag isEqualToString:NSLinguisticTagPlaceName] || [tag isEqualToString:NSLinguisticTagOrganizationName] ){
                              NSLog(@"%@: %@", token, tag);
                              if (![[tags allKeys] containsObject:token]) {
                                  NSMutableDictionary *tagDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:1], @"count", nil];
                                  [tags setObject:tagDict forKey:token];
                              } else {
                                  NSMutableDictionary *tagDict = [tags objectForKey:token];
                                  [tagDict setObject:[NSNumber numberWithInt:([[tagDict objectForKey:@"count"] intValue] + 1)] forKey:@"count"];
                              }
                          }
                          
                      }];
    
    
    
    NSLog(@"%@", tags);
    
    
}


-(void) tapMethod: (UITapGestureRecognizer*) gesture{
    
    if(visible && backgroundImage.image){
        NSLog(@"disappearing\n");
        
        [UIView animateWithDuration:0.1
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                                textView.alpha = 0.0;
                                titleText.alpha = 0.0;
                                backgroundImage.image = [_image applyBlurWithRadius:0 tintColor:[UIColor clearColor] saturationDeltaFactor:0 maskImage:nil];
                                _captions.alpha = 1;
                                scrollView.userInteractionEnabled = NO;
                            } completion:^(BOOL finished) {
                                if(finished){
                                    visible = FALSE;
                                }
                            }];
    }else{
        NSLog(@"appearing\n");
        [UIView animateWithDuration:0.1
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                                textView.alpha = 1.0f;
                                titleText.alpha = 1.0f;
                                backgroundImage.image = [_image applyBlurWithRadius:8 tintColor:[UIColor clearColor]saturationDeltaFactor:1.0 maskImage:nil];
                                _captions.alpha = 0;
                                scrollView.userInteractionEnabled = YES;
                            } completion:^(BOOL finished) {
                                if(finished){
                                    visible = TRUE;
                                }
                            }];
        
    }
}

-(void) backPage: (UISwipeGestureRecognizer*) swipe{
    NSLog(@"back");
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    NSLog(@"%@\n", touch.view);
    if([touch.view isKindOfClass:[UIImageView class]]){
        NSLog(@"TEST\n");
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end