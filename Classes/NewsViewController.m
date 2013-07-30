
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
@property (nonatomic, retain) AVSpeechSynthesizer *av;
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
@synthesize captions;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize scrollView;
@synthesize filter;
@synthesize result;
@synthesize titleText;
@synthesize textStorage;
@synthesize av;


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
                name = [name stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[name substringToIndex:1] capitalizedString]];
                [author appendFormat:@"%@ ", name];
            }
            entry.author = [author copy];
            
            [author appendFormat:@"\n\n"];
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
    else if(entry.story.content){
        content = entry.story.content;
        title = entry.articleTitle;
        author = [[NSMutableString alloc] initWithString:entry.author];
    }else{
        //pop a UIAlert
    }
    
    //For Facebook style description, uncheck Clip Subviews
    dispatch_async(dispatch_get_main_queue(), ^{
        UIScrollView *scrollText;
        [scrollText addSubview:textView];
        textView.textColor = [UIColor whiteColor];
        
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle: UIFontTextStyleHeadline];
            UIFontDescriptor *titleFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
            
            UIFontDescriptor *helveticaNeueFamily = [UIFontDescriptor fontDescriptorWithFontAttributes: @{ UIFontDescriptorFamilyAttribute: @"HelveticaNeue"}];
        NSArray *matches = [helveticaNeueFamily matchingFontDescriptorsWithMandatoryKeys:nil];
            UIFont *titleFont;

            for (UIFontDescriptor *desc in matches) {
                if([desc.postscriptName isEqualToString:@"HelveticaNeue-Light"]){
                    titleFont = [UIFont fontWithDescriptor:desc size:0.0];
                }
            }
            
            UIFontDescriptor *boldFontDescriptor =
            [fontDescriptor fontDescriptorWithSymbolicTraits:
             UIFontDescriptorTraitUIOptimized];
            titleFont = [UIFont fontWithDescriptor: boldFontDescriptor size: 0.0];
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
            
            [textView sizeToFit];
            [scrollView sizeToFit];
        }else{
//        CGSize frameSize = [textView.text sizeWithFont:textView.textStorage.length];
//        NSLog(@"%f", frameSize.height);
            textView.text = [NSString stringWithFormat:@"%@%@", author, entry.story.content];
            titleText.text = entry.articleTitle;

        }

        
        if(entry.story.captions){
            captions.text = entry.story.captions;
            captions.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
            captions.textColor = [UIColor whiteColor];
            captions.alpha = 0;
            captions.editable = NO;
            captions.userInteractionEnabled = YES;
            [captions setScrollEnabled:YES];
//            [_captions setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
//                if([_captions respondsToSelector:@selector(setFont:)])
                [captions setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
            captions.isAccessibilityElement = YES;
            captions.accessibilityLabel = @"Captions";
            
        }
        
        entry.read = [NSNumber numberWithInt:1];
        NSError *error;
        [_managedObjectContext save:&error];
        if(error) NSLog(@"%@", [error description]);
        

        visible = YES;
        NSLog(@"%f", textView.contentSize.height);
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
       [self TFHppleFinishLoading];
        
    });

}

-(void) TFHppleFinishLoading{
    
    
    CGFloat titleHeight = titleText.contentSize.height;
    CGFloat textHeight = textView.contentSize.height;
    
    CGRect titleFrame = titleText.frame;
    titleFrame.size.height = titleHeight;
    titleText.frame = titleFrame;
    
    
    CGRect frame = textView.frame;
    frame.size = textView.contentSize;
    textView.frame = frame;
    UIView *view = [[UIView alloc] initWithFrame:textView.frame];
    UIView *titleView = [UIView new];
    titleView.frame = titleText.frame;
    
    [self.view addSubview:view];
    [self.view addSubview:titleView];
    NSDictionary *viewsDictionary;

    viewsDictionary = NSDictionaryOfVariableBindings(scrollView, textView, titleText, titleView, view);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textView(==scrollView)]|" options:0 metrics: 0 views:viewsDictionary]];
  
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleText(==scrollView)]|" options:0 metrics:0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-280-[titleText(==titleView)]-[textView(==view)]|" options:0 metrics: 0 views:viewsDictionary]];
    
//    [self.backgroundImage addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[captions]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(captions)]];
//    [self.backgroundImage addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-450-[captions]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(captions)]];
    
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
    
    
    [self generateImage];
    
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
        [backgroundImage setContentMode:UIViewContentModeScaleToFill];
        if(!imageUrl){
            _image = [UIImage imageNamed:@"iPhone5.jpg"];
        }else{
            NSData *data = [NSData dataWithContentsOfURL:link];
            _image = [[UIImage alloc] initWithData:data];
        }
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
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    [self initializeViews];
    
    UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButton:)];
    UIBarButtonItem *speech = [[UIBarButtonItem alloc] initWithTitle:@"Speech" style:UIBarButtonItemStylePlain target:self action:@selector(speak:)];
    
    [self.navigationItem setRightBarButtonItem:loadingView];
    

    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:_HUD];
    _HUD.delegate = self;
    _HUD.labelText = @"Loading...";
    [_HUD showWhileExecuting:@selector(loadDetails)
                    onTarget:self
                  withObject:nil
                    animated:YES];
    
    av = [[AVSpeechSynthesizer alloc]init];
    av.delegate = self;
    
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("get ranking queue", NULL);
    dispatch_async(downloadQueue, ^{

        [self getRanking];
    });
    
}


-(void) speak:(id)sender{
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:textView.text];
    utterance.rate = 0.25;
    
    if(av.speaking)
        [av pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    else if(av.paused){
        NSLog(@"speaking");
        [av speakUtterance:utterance];
    }
}

-(void) speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance{
    
}



-(void) initializeViews{
    scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    scrollView.delegate = self;
    backgroundImage = [[UIImageView alloc] initWithFrame:scrollView.frame];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:backgroundImage];
    [self.view addSubview:scrollView];

    captions = [[UITextView alloc] init];
    [captions setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.4f]];
    [self.backgroundImage addSubview:captions];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(scrollView)]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(scrollView)]];
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        
        CGRect newTextViewRect = CGRectInset(self.view.frame, 8., 10.);
        
        textStorage = [[NSTextStorage alloc] init];
        
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeMake(newTextViewRect.size.width, CGFLOAT_MAX)];
        
        container.widthTracksTextView = YES;
        [layoutManager addTextContainer:container];
        
        
        [layoutManager addTextContainer:container];
        [textStorage addLayoutManager:layoutManager];
        textView = [[UITextView alloc] initWithFrame:newTextViewRect textContainer:container];
        
        textView.editable = NO;
//        textView.scrollEnabled = NO;
        textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        textView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];

        CGSize size = scrollView.contentSize;
        size.height = textView.contentSize.height + EMPTYVIEW;
        
        scrollView.contentSize = size;
        CGRect textViewFrame = textView.frame;
        textViewFrame.origin.y += EMPTYVIEW;
        textViewFrame.size = textView.contentSize;
        textView.frame = textViewFrame;
        
        
    }else{  //iOS 6

        titleText = [[UITextView alloc] init];
        titleText.backgroundColor = [UIColor clearColor];
        titleText.textColor = [UIColor whiteColor];
        titleText.editable = NO;
        titleText.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
        titleText.layer.shadowColor = [[UIColor blackColor] CGColor];
        titleText.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        titleText.layer.shadowOpacity = 1.0f;
        titleText.layer.shadowRadius = 1.0f;
        [titleText setTranslatesAutoresizingMaskIntoConstraints:NO];
        textView = [[UITextView alloc] init];
        [textView setTranslatesAutoresizingMaskIntoConstraints:NO];
        textView.editable = NO;
        textView.scrollEnabled = NO;
        textView.backgroundColor = [UIColor blackColor];
        textView.alpha = 0.8;
        textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        textView.textColor = [UIColor blackColor];
        
        [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:133/255.0f green:5/255.0f blue:3/255.0f alpha:1.0f]];
        [scrollView addSubview:titleText];
        
        [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:textView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0f constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:titleText
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.0f constant:0]];
    }
    

    [scrollView addSubview:textView];

}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGSize size = textView.frame.size;
//    UIGraphicsBeginImageContextWithOptions(size, NULL, 0);
//    [textView drawViewHierarchyInRect:textView.frame];
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    newImage = [newImage applyLightEffect];
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
        
        [UIView animateWithDuration:0.1
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                                textView.alpha = 0.0;
                                titleText.alpha = 0.0;
                                backgroundImage.image = [_image applyBlurWithRadius:0 tintColor:[UIColor clearColor] saturationDeltaFactor:0 maskImage:nil];
                                captions.alpha = 1;
                                scrollView.userInteractionEnabled = NO;
                            } completion:^(BOOL finished) {
                                if(finished){
                                    visible = FALSE;
                                }
                            }];
    }else{
        [UIView animateWithDuration:0.1
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                                textView.alpha = 1.0f;
                                titleText.alpha = 1.0f;
                                backgroundImage.image = [_image applyBlurWithRadius:8 tintColor:[UIColor clearColor]saturationDeltaFactor:1.0 maskImage:nil];
                                captions.alpha = 0;
                                scrollView.userInteractionEnabled = YES;
                            } completion:^(BOOL finished) {
                                if(finished){
                                    visible = TRUE;
                                }
                            }];
        
    }
}

-(void) backPage: (UISwipeGestureRecognizer*) swipe{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if([touch.view isKindOfClass:[UIImageView class]]){
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end