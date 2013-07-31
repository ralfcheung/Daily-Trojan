//
//  RootViewController.h
//  RSSFun
//
//  Created by Ralf Cheung on 5/3/13.
//  Copyright 2013 Ralf Cheung. All rights reserved.
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
