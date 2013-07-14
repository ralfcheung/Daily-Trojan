//
//  NewsViewController.h
//  RSSFun
//
//  Created by Ralf Cheung on 4/20/13.
//
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "Entry.h"
#import <AVFoundation/AVFoundation.h>

@interface NewsViewController : UIViewController  <UIGestureRecognizerDelegate, ADBannerViewDelegate, UIGestureRecognizerDelegate, MBProgressHUDDelegate, UIScrollViewDelegate, UITextFieldDelegate, AVSpeechSynthesizerDelegate>


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
-(void) loadText;
-(id) initWithLink:(NSString *)link;
-(CGSize)imageSizeAfterAspectFit:(UIImageView*)imgview;
- (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize;
- (void)moveImage:(NSTimer*)timer;
-(void) TFHppleFinishLoading;
-(void) getRanking;
-(void) bounceScrollView;
+ (CAKeyframeAnimation*)dockBounceAnimationWithViewHeight:(CGFloat)viewHeight;
-(void) setFontofViews;
-(void) prefereedContentSizeChanged: (NSNotification *)aNotification;
-(void) initializeViews;
-(id) initWithEntry:(Entry *)entry;

@end
