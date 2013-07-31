//
//  RSSFunAppDelegate.m
//  RSSFun
//
//  Created by Ralf Cheung on 5/1/13.
//  Copyright 2013 Ralf Cheung. All rights reserved.
//

#import "RSSFunAppDelegate.h"
#import "IIViewDeckController.h"
#import "LeftViewController.h"
#import "Story.h"
#import "AFHTTPClient.h"
#import "Entry.h"
#import "ASIHTTPRequest.h"
#import "GDataXMLNode.h"
#import "GDataXMLElement-Extras.h"
#import "NSDate+InternetDateTime.h"
#import "FirstPageViewController.h"

@implementation RSSFunAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize leftViewController;
@synthesize rootViewController;
@synthesize leftVC;
@synthesize centerController;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize splitViewController = _splitViewController;
@synthesize queue = _queue;

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    
    // Add the navigation controller's view to the window and display.

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    

    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    }
    
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
    
    rootViewController = [[RootViewController alloc] initWithLink: @"http://feeds2.feedburner.com/DailyTrojan-rss" name:@"Home" managedObjectContext:_managedObjectContext];
//    FirstPageViewController *first = [[FirstPageViewController alloc] initWithTitles];

    rootViewController.managedObjectContext = [self managedObjectContext];
    leftVC = [[LeftViewController alloc] init];
    leftVC.managedObjectContext = [self managedObjectContext];
    
    self.centerController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];

    IIViewDeckController *deckController = [[IIViewDeckController alloc] initWithCenterViewController:self.centerController leftViewController:leftVC];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
    
        [deckController setLeftSize: 100];
//        deckController.rightSize = 50;
    }else{
        [deckController setLeftSize: 400];
//        deckController.rightSize = 800;

    }
    [self refresh];

    self.window.rootViewController = deckController;
    //    }
    //    else{
    //
    //        _splitViewController = [[RootSplitViewController alloc] init];
    //
    //
    //    }
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (void)refresh {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://dailytrojan.com/feed/rss/"]];
    NSError *error;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
//    NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//        returnData = data;
//    }
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:returnData
                                                           options:0 error:&error];
    if (doc == nil) {
        NSLog(@"Failed to parse %@", request.URL);
    }
    else {
        NSMutableArray *entries = [NSMutableArray array];
        [self parseFeed:doc.rootElement entries:entries];
        
    }

    
    
    
//
//    NSURL *url = [NSURL URLWithString:@"http://feeds2.feedburner.com/DailyTrojan-rss"];
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    [request setDelegate:self];
//    [request startAsynchronous];
//    [_queue addOperation:request];
}


- (BOOL)parseRss:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {
    
    BOOL newData = NO;
    
    NSArray *channels = [rootElement elementsForName:@"channel"];
    for (GDataXMLElement *channel in channels) {
        
        NSString *blogTitle = [channel valueForChild:@"title"];
//        NSLog(@"Blog Title: %@", blogTitle);
        NSArray *items = [channel elementsForName:@"item"];
        for (GDataXMLElement *item in items) {
            //            NSLog(@"Category: %@\n", [item valueForChild:@"category"]);
            
            NSString *articleTitle = [item valueForChild:@"title"];
            //            NSLog(@"Article Title: %@\n", articleTitle);
            NSString *articleAuthor = [item valueForChild:@"dc:creator"];
            //            NSLog(@"Author: %@\n", articleAuthor);
            NSString *articleUrl = [item valueForChild:@"link"];
            NSString *category = [item valueForChild:@"category"];
            NSString *articleDateString = [item valueForChild:@"pubDate"];
            NSDate *articleDate = [NSDate dateFromInternetDateTimeString:articleDateString formatHint:DateFormatHintRFC822];
            NSRange found = [articleTitle rangeOfString:@"Classifieds"];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            fetchRequest.entity = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext:_managedObjectContext];    
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"articleTitle = %@", articleTitle];
            NSArray *result = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];

            if(found.location == NSNotFound && ![result count]) {
                Entry *e = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:_managedObjectContext]; 
                e.articleTitle = articleTitle;
                e.articleURL = articleUrl;
                e.author = articleAuthor;
                e.articleDate = articleDate;
                e.category = category;
                e.favorite = [NSNumber numberWithInt:0];
                e.read = [NSNumber numberWithInt:0];
                NSError *error;
                newData = YES;
                if(![_managedObjectContext save:&error]){
                    NSLog(@"couldn't save %@", [error localizedDescription]);
                }
            }
        }
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"articleDate" ascending:TRUE];
    [entries sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return newData;
}

- (BOOL)parseFeed:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {
    BOOL newData = NO;
    if ([rootElement.name compare:@"rss"] == NSOrderedSame) {
       newData = [self parseRss:rootElement entries:entries];
    } else {
        NSLog(@"Unsupported root element: %@", rootElement.name);
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    [_queue addOperationWithBlock:^{
    }];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: %@", error);
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
//	NSLog(@"My token is: %@", deviceToken);
//    NSString *token = [NSString stringWithUTF8String:[deviceToken bytes]];
//    NSString *host = @"127.0.0.1:8888";
//    NSString *URLString = @"/register.php?devicetoken=";
//    NSLog(@"token: %@\n", token);
//    URLString = [URLString stringByAppendingString:token];
//    URLString = [URLString stringByAppendingString:@"&amp;amp;amp;amp;amp;devicetoken="];
//    
//    NSString *dt = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&lt;&gt;<>"]];
//    dt = [dt stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSLog(@"device token: %@\n", dt);
    
//    URLString = [URLString stringByAppendingString:dt];
//    URLString = [URLString stringByAppendingString:dt];
//    URLString = [URLString stringByAppendingString:@"&amp;amp;amp;amp;amp;devicename="];
//    URLString = [URLString stringByAppendingString:[[UIDevice alloc] name]];
    
//    NSString *URLString = @"http://localhost:8888";
//    NSDictionary *param = @{@"devicetoken":dt};
//    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:URLString]];
//    [client postPath:@"/register.php"
//          parameters:param
//             success:^(AFHTTPRequestOperation *operation, id response) {
//                 NSLog(@"Success\n");
//             }
//             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                 NSLog(@"Error with request");
//                 NSLog(@"%@",[error localizedDescription]);
//             }];
    
//    NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:URLString];
//    NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:@"google.com" path:@""];
//    NSLog(@"FullURL = %@", url);
    
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
//    NSError *error;
//    
//    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
//    NSLog(@"%@\n", [error description]);
}


- (void)application:(UIApplication*)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    
    [rootViewController refreshWithCompletionHandler:^(BOOL didReceiveNewPosts) {
        if (didReceiveNewPosts) {
            completionHandler(UIBackgroundFetchResultNewData);
        }else completionHandler(UIBackgroundFetchResultNoData);
    }];
}
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    [self saveContext];
    
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    

    NSError *error = nil;
    /*_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        
        
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
     
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }*/
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Handle error
        NSLog(@"Problem with PersistentStoreCoordinator: %@",error);
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end

