//
//  RootViewController.h
//  RSSFun
//
//  Created by Ray Wenderlich on 1/24/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

typedef void (^CRefreshCompletionHandler) (BOOL didReceiveNewPosts);

@interface RootViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, ADBannerViewDelegate,  UIAccessibilityIdentification>
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

- (void) refreshWithCompletionHandler:(CRefreshCompletionHandler) completionHandler;
- (id)initWithLink:(NSString *)link name:(NSString*)name managedObjectContext: (NSManagedObjectContext *) managedObjectContext;
-(void) prefereedContentSizeChanged: (NSNotification *)aNotification;


@end
