//
//  RSSFunAppDelegate.h
//  RSSFun
//
//  Created by Ray Wenderlich on 1/24/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "RootViewController.h"
#import "LeftViewController.h"
#import "RootSplitViewController.h"
#import "UINavigationBarWithoutGradient.h"

@interface RSSFunAppDelegate : NSObject <UIApplicationDelegate, UIAppearanceContainer> {
    
    
    UIWindow *window;
    UINavigationController *navigationController;
}
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) UITableViewController *leftViewController;
@property (nonatomic, retain) RootViewController *rootViewController;
@property (nonatomic, retain) LeftViewController *leftVC;
@property (nonatomic, retain) UIViewController *centerController;
@property (nonatomic, retain) RootSplitViewController *splitViewController;
@property (retain) NSOperationQueue *queue;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

