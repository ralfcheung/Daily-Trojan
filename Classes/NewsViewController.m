
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
#import "UIImage+Resize.h"
#import "Reachability.h"
#import "UIBarButtonItem+withoutBorder.h"

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
@property (nonatomic, strong) NSMutableString *author;
@property (readwrite) BOOL visible;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) MBProgressHUD *HUD;
@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, retain) AVSpeechSynthesizer *av;
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, retain) NSLayoutManager *layoutManager;
@property (nonatomic, retain) TwitterREST *twitter;


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
@synthesize titleText;
@synthesize textStorage;
@synthesize av;
@synthesize operationQueue;
@synthesize layoutManager;
@synthesize twitter;


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
    author = [[NSMutableString alloc] initWithString:@""];
    
    for (TFHppleElement *child in [element children]){
        if([[element tagName] isEqualToString:@"span"]){
            NSString *authorSt = [self getStringForTFHppleElement:child];
            NSArray *names = [authorSt componentsSeparatedByString: @" "];
            [author appendString:@"By: "];
            NSLog(@"%@", element.content);
            if([names count] > 1)
                for (__strong NSString *name in names){
                    name = [name stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[name substringToIndex:1] capitalizedString]];
                    [author appendFormat:@"%@ ", name];
                }
            [author appendFormat:@"\n\n"];
            if ([author isEqualToString:@""]) {
                entry.author = [NSString stringWithFormat: @""];
            }else
                entry.author = [author copy];
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
        }else if([[element tagName] isEqualToString:@"a"]){
            
            
            NSString *twitterAccount = [element objectForKey:@"href"];
            twitter = [TwitterREST new];
            
            if ([twitterAccount rangeOfString:@"twitter.com"].location != NSNotFound) {
                twitter.userName = [twitterAccount lastPathComponent];
            }
            else twitter.userName = @"dailytrojan";
        }else if ([[element tagName] isEqualToString:@"div"]){
            
            [self getStringForTFHppleElement:child];
        }
    }
    
    // Hpple creates a <text> node when it parses texts
    if ([element.tagName isEqualToString:@"text"]) [resultString appendString:element.content];
    
    //    result = [result stringByReplacingOccurrencesOfString:@"â" withString:@"\'"];
    return resultString;
}



-(void) downloadHTMLFileAndParseIt{
    
    
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:entry.articleURL]];
    
    if(tutorialsHtmlData){
        NSString *str = [[NSString alloc] initWithData:tutorialsHtmlData encoding:NSUTF8StringEncoding];
        tutorialsHtmlData = [str dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
        
        NSString *tutorialsXpathQueryString = @"//p[@class='author']/span//a | //div[@class='post']/h1 | //div[@class='entry']/p | //div[@class='entry'] | //div[@class='']";
        NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
        content = [[NSString alloc] init];
        for (TFHppleElement *element in tutorialsNodes) {
            content = [content stringByAppendingString:[self getStringForTFHppleElement: element]];
//            NSLog(@"%@", content);
        }
        
        
        NSString *captionString;
        
        tutorialsXpathQueryString = @"//p[@class='wp-caption-text']";
        tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
        
        if(tutorialsNodes){
            if ([self getStringForTFHppleElement:[tutorialsNodes lastObject]]) {
//                NSLog(@"%@", [self getStringForTFHppleElement:[tutorialsNodes lastObject]]);
                captionString = [self getStringForTFHppleElement:[tutorialsNodes lastObject]];
            }
            else{
                NSLog(@"can't find");
            }
        }
        if (_managedObjectContext) {
            entry.story = [Story storyinManagedObjectContext:_managedObjectContext storyContent:content picture:nil caption:captionString];
        }
        
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
    
}


-(void) loadText{
    
    
    [self downloadHTMLFileAndParseIt];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        
        TagRankingOperation *taggingOperation = [[TagRankingOperation alloc] init];
        taggingOperation.text = content;
        taggingOperation.delegate = self;
        [operationQueue addOperation:taggingOperation];
    }
    
    //For Facebook style description, uncheck Clip Subviews
    dispatch_async(dispatch_get_main_queue(), ^{
        UIScrollView *scrollText;
        [scrollText addSubview:textView];
        
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            UIFont *titleFont;
            
            UIFontDescriptor *helveticaNeueFamily =
            [UIFontDescriptor fontDescriptorWithFontAttributes: @{
                                                                  UIFontDescriptorFamilyAttribute: @"Helvetica Neue"
                                                                  }];
            NSArray *matches =
            [helveticaNeueFamily matchingFontDescriptorsWithMandatoryKeys: nil];
            
            for (UIFontDescriptor *desc in matches) {
                if ([desc.postscriptName isEqualToString:@"HelveticaNeue-Light"]) {
                    titleFont = [UIFont fontWithDescriptor: desc size:30.0];
                    break;
                }
            }
            
            
            //        NSDictionary *titleDic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline1], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
            
            NSDictionary *titleDic = [NSDictionary dictionaryWithObjectsAndKeys:titleFont, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
            
            NSDictionary *nameDic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont preferredFontForTextStyle:UIFontTextStyleBody], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
            [textStorage beginEditing];
            [textStorage setAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", entry.articleTitle] attributes:titleDic]];
            
            if(!_managedObjectContext){
                NSLog(@"%@", [author copy]);
                [textStorage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[author copy] attributes:nameDic]];

                [textStorage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:content attributes:dict]];
            }
            else{
                [textStorage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:entry.author attributes:nameDic]];

                [textStorage appendAttributedString:[[NSMutableAttributedString alloc] initWithString:entry.story.content attributes:dict]];
            }
            [textStorage endEditing];
            
//            [textView sizeToFit];
//            [scrollView sizeToFit];
        }else{
            if(_managedObjectContext){
//                NSLog(@"%@", entry.author);
                textView.text = [NSString stringWithFormat:@"%@%@",entry.author, entry.story.content];
                
            }
            else
                textView.text = [NSString stringWithFormat:@"%@%@", author, content];
            
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
        if (_managedObjectContext) {
            [_managedObjectContext save:&error];
        }
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
    
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(scrollView, textView, titleText, titleView, view);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textView(==scrollView)]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleText(==scrollView)]|" options:0 metrics:0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-150-[titleText(==titleView)][textView(==view)]|" options:0 metrics: 0 views:viewsDictionary]];
    
    
}


-(BOOL) checkConnection{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        return NO;
    }
    return YES;
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
//    [self.view.layer insertSublayer:topGradient below:textView.layer];
//    [self.view.layer insertSublayer:gradient below:textView.layer];
    
    
    [self generateImage];
    
    //    NSData* data = [content dataUsingEncoding:NSUTF8StringEncoding];
    //    content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}


-(void) shareButton: (id) sender{
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:[NSString stringWithFormat:@"Follow @%@ on Twitter?", twitter.userName] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex) [twitter followWriterTwitter];
    
}

- (void) generateImage{
//    NSLog(@"%@", imageUrl);
//    NSURL *link = [NSURL URLWithString:imageUrl];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
    dispatch_async(downloadQueue, ^{
        [backgroundImage setContentMode:UIViewContentModeScaleAspectFill];
        if(!imageUrl){
            _image = [UIImage imageNamed:@"iPhone5.jpg"];
        }else{
            NSURL *link = [NSURL URLWithString:imageUrl];
            NSData* data;
            NSError *error = nil;
            
            data = [NSData dataWithContentsOfURL:link options:NSDataReadingMappedAlways error:&error];
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }
            
            _image = [[UIImage alloc] initWithData:data];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            backgroundImage.image = [_image applyBlurWithRadius:8 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil];
            backgroundImage.image = [backgroundImage.image resizedImageByMagick:@"640x1136#"];
            
            [backgroundImage setClipsToBounds:YES];
//            [backgroundImage.superview sendSubviewToBack:backgroundImage];
//            if(_image.size.height / _image.size.width > 1.1){
//                [self imageViewAnimation:0 frame:backgroundImage.frame];
//                
//                NSLog(@"Vertical\n");
//            }
//            else{
//                
//                [self imageViewAnimation:190 frame:backgroundImage.frame];
//                backgroundImage.frame.origin.x = -200;
//                NSLog(@"Horizontal %f\n", _image.size.height / _image.size.width);
//            }
//            backgroundImage.frame = frame;
//            [UIView commitAnimations];

        });
        
    });
    
    
    
    
    //    CGRect frame = backgroundImage.frame;
    
    
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
        
        operationQueue = [[NSOperationQueue alloc] init];
        
        [self initializeViews];
        
//        UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButton:)];
        UIBarButtonItem *loadingView = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"twitter.png"] target: self action:@selector(shareButton:)];
//        UIBarButtonItem *speech = [[UIBarButtonItem alloc] initWithTitle:@"Speech" style:UIBarButtonItemStylePlain target:self action:@selector(speak:)];
    
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

-(void)finishedTagging:(TagRankingOperation *)tagsOps{
    
    NSDictionary *tagDic = tagsOps.tags;
//    Tag *tag = [[Tag alloc] init];
    [tagDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        NSLog(@"%@", (NSString*)key );
        NSDictionary * wordDic = obj;
        [wordDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//            NSLog(@"%@ %d", (NSString*)key, [obj intValue]);
        }];
        
    }];
    
    
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
        
        layoutManager = [[NSLayoutManager alloc] init];
        NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeMake(newTextViewRect.size.width, CGFLOAT_MAX)];
        
        container.widthTracksTextView = YES;
        [layoutManager addTextContainer:container];
        
        [textStorage addLayoutManager:layoutManager];
        textView = [[UITextView alloc] initWithFrame:newTextViewRect textContainer:container];

        textView.editable = NO;
        textView.scrollEnabled = YES;
//        textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        textView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
        textView.layer.cornerRadius = 10.0f;
        textView.textColor = [UIColor whiteColor];
        
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
        textView.alpha = 0.7;
        textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        textView.layer.cornerRadius = 10.0f;
        textView.textColor = [UIColor whiteColor];
        
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
        titleText.scrollsToTop = NO;
        
    }
    textView.delegate = self;
    textView.scrollsToTop = NO;
    [scrollView addSubview:textView];
    scrollView.scrollsToTop = YES;
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
    
    if(visible && imageUrl){
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

-(void) viewWillAppear:(BOOL)animated{
    //    [self.navigationController setNavigationBarHidden:NO];
    //    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
    //
    //        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:133/255.0f green:5/255.0f blue:3/255.0f alpha:1.0f];
    //    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end