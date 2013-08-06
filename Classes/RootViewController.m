//
//  RootViewController.m
//  RSSFun
//
//  Created by Ralf Cheung on 5/01/13.
//  Copyright 2013 Ralf Cheung. All rights reserved.
//

#import "RootViewController.h"
#import "ASIHTTPRequest.h"
#import "GDataXMLNode.h"
#import "GDataXMLElement-Extras.h"
#import "NSDate+InternetDateTime.h"
#import "NSArray+Extras.h"
#import "NewsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "IIViewDeckController.h"
#import <iAd/iAd.h>
#import "UIBarButtonItem+withoutBorder.h"
#import "UINavigationBarWithoutGradient.h"
#import "UISearchBarSolidColor.h"
#import "Entry.h"
#import "Story.h"
#import "Cell.h"


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface RootViewController()

@property (retain) NSOperationQueue *queue;
@property (retain) NSArray *allEntries;
@property (retain) NSArray *searchedEntries;
@property (retain) UISearchDisplayController *searchDisplay;
@property (retain) IBOutlet UISearchBar* searchBar;
@property (nonatomic, retain) NSString *feed;
@property (nonatomic, assign) BOOL showingRightPanel;
@property (nonatomic, assign) BOOL showPanel;
@property (nonatomic, assign) BOOL showingLeftPanel;
@property (nonatomic, assign) CGPoint preVelocity;
@property (strong, nonatomic) UINavigationController *nav;
@property (nonatomic, retain) UINavigationBarWithoutGradient *navBar;
@property (nonatomic, assign) NSInteger *currentPage;
//@property (nonatomic, assign) ADBannerView *bannerView;
@property (nonatomic, retain) UISegmentedControl *segmentControl;

@end


@implementation RootViewController

@synthesize segmentControl;
@synthesize currentPage;
@synthesize allEntries = _allEntries;
@synthesize queue = _queue;
@synthesize searchBar = _searchBar;
@synthesize searchDisplay = _searchDisplay;
@synthesize feed = _feed;
@synthesize nav;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize searchedEntries;


//@synthesize bannerView = _bannerView;

#pragma mark -
#pragma mark View lifecycle

- (void) refreshView: (UIRefreshControl*)refresh {
    
    [self refresh: nil];
    [refresh endRefreshing];
}

-(BOOL) refresh: (NSString *) url {
    NSURLRequest *request;
    if(url == nil)
        request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://dailytrojan.com/feed/rss/"]];
    else request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    
    NSError *error;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    if(error){
        NSLog(@"%@", error.localizedDescription);
    }
    BOOL newData = NO;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:returnData
                                                           options:0 error:&error];
    if (doc == nil) {
        NSLog(@"Failed to parse %@", request.URL);
    }
    else {
        NSMutableArray *entries = [NSMutableArray array];
        newData = [self parseFeed:doc.rootElement entries:entries];
        
    }
    
    return newData;
    
}
-(void) refreshWithCompletionHandler:(CRefreshCompletionHandler)completionHandler{
    
    BOOL newData = [self refresh: nil];
    if (completionHandler) {
        completionHandler(newData ? YES: NO);
    }
    
}


- (id)initWithLink:(NSString *)link name:(NSString*)name managedObjectContext: (NSManagedObjectContext *) managedObjectContext{
    self = [super init];
    if (self) {
        if(link)
            self.feed = [link copy];
        self.title = name;
        self.managedObjectContext = managedObjectContext;
        //        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
        //            _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        //        } else {
        //            _bannerView = [[ADBannerView alloc] init];
        //        }
        //        _bannerView.delegate = self;
        
    }
    //    NSLog(@"%@\n", self.feed);
    return self;
}

//- (void)layoutAnimated:(BOOL)animated
//{
//    // As of iOS 6.0, the banner will automatically resize itself based on its width.
//    // To support iOS 5.0 however, we continue to set the currentContentSizeIdentifier appropriately.
//    CGRect contentFrame = self.view.bounds;
//    if (contentFrame.size.width < contentFrame.size.height) {
//        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
//    } else {
//        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
//    }
//
//    CGRect bannerFrame = _bannerView.frame;
//    if (_bannerView.bannerLoaded) {
//        contentFrame.size.height -= _bannerView.frame.size.height;
//        bannerFrame.origin.y = contentFrame.size.height;
//    } else {
//        bannerFrame.origin.y = contentFrame.size.height;
//    }
//
//    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
//        self.view.frame = contentFrame;
//        [self.view layoutIfNeeded];
//        _bannerView.frame = bannerFrame;
//    }];
//}
//

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.tableView becomeFirstResponder];
}


- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    [self performSelector:@selector(searchBarCancelButtonClicked:) withObject:self.searchBar afterDelay: 0.1];
//    [textField resignFirstResponder];
    
    return YES;
}



- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Entry" inManagedObjectContext:_managedObjectContext]];
    NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"SELF.articleTitle contains[c] %@ ", searchString];
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"SELF.category contains[c] %@", searchString];
    NSPredicate *authorPredicate = [NSPredicate predicateWithFormat:@"SELF.author contains[c] %@", searchString];

    NSArray *array = [NSArray arrayWithObjects:titlePredicate, categoryPredicate, authorPredicate, nil];
    NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:array];
    [fetchRequest setPredicate:predicate];
//    _allEntries = [[_allEntries filteredArrayUsingPredicate:predicate] mutableCopy];
    searchedEntries = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
//    searchedEntries = _allEntries;
    
    return YES;
}

-(void) prefereedContentSizeChanged: (NSNotification *)aNotification{
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allEntries = [NSMutableArray array];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44)];
    _searchBar.delegate = self;
    _searchBar.translucent = YES;

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    refresh.tintColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing"];
    [refresh endRefreshing];
    self.refreshControl = refresh;
    
    
    UIColor *bgRefreshColor = [UIColor colorWithRed:100/255.0f green:5/255.0f blue:3/255.0f alpha:1.0f];

    CGRect frame = self.tableView.bounds;
    frame.origin.y = -frame.size.height;
    UIView* bgView = [[UIView alloc] init];
    bgView.backgroundColor = bgRefreshColor;
    

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"menu.png"] target:self.viewDeckController action:@selector(toggleLeftView)];
        [self.navigationController setValue:_navBar forKey:@"navigationBar"];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:133/255.0f green:5/255.0f blue:3/255.0f alpha:1.0f];
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, [UIFont fontWithName:@"HelveticaNeue-Light" size:16], UITextAttributeFont,nil]];
//    [self.navigationController setNavigationBarHidden:YES];
        
//        [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:133/255.0f green:5/255.0f blue:3/255.0f alpha:1.0f]];
        
        _searchBar.tintColor = [UIColor whiteColor];
        _searchBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    }
    else{ //iOS 6
        _navBar = [[UINavigationBarWithoutGradient alloc] init];
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"menu.png"] target:self.viewDeckController action:@selector(toggleLeftView)];
        [self.navigationController setValue:_navBar forKey:@"navigationBar"];
                
//        [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:133/255.0f green:5/255.0f blue:3/255.0f alpha:1.0f]];
        
        for (UIView *subview in _searchBar.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
                UIView *bg = [[UIView alloc] initWithFrame:subview.frame];
                bg.backgroundColor = [UIColor colorWithRed:133/255.0f green:5/255.0f blue:3/255.0f alpha:1.0f];
                [_searchBar insertSubview:bg aboveSubview:subview];
                [subview removeFromSuperview];
                break;
            }
        }
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor blackColor];
        UILabel *label = [[UILabel alloc] init];
        label.text = @"Bottom";
        label.textColor = [UIColor blackColor];
        self.tableView.tableHeaderView = _searchBar;
        self.tableView.tableFooterView = view;
    }
    
    for (UIView *view in _searchBar.subviews){
        if ([view isKindOfClass: [UITextField class]]) {
            __strong UITextField *tf = (UITextField *)view;
            tf.delegate = self;
            break;
        }
    }
    
    _searchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchDisplay.delegate = self;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            _searchDisplay.displaysSearchBarInNavigationBar = YES;
    }
    _searchDisplay.searchResultsDataSource = self;
    _searchDisplay.searchResultsDelegate = self;
    
//    self.navigationController.navigationItem.titleView = segmentControl;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    if(![self.title isEqualToString:@"Home"]){
        fetchRequest = [self sortCD];
    }else{
        fetchRequest.entity = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext:_managedObjectContext];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"articleDate" ascending:NO];
        NSArray * descriptors = [NSArray arrayWithObject:sortDescriptor];
        fetchRequest.sortDescriptors = descriptors;

    }

    
    _allEntries = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
    NSLog(@"all entries: %i", [_allEntries count]);
    
    
    
    
    
    //    [self setupView];
    //    [self setup];
    //    [self.view addSubview:_searchBar];
    //    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view delegate

-(NSFetchRequest*) sortCD{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext:_managedObjectContext];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"articleDate" ascending:NO];
    NSArray * descriptors = [NSArray arrayWithObject:sortDescriptor];
    fetchRequest.sortDescriptors = descriptors;

    NSPredicate *predicate;
    
    if([self.title isEqualToString:@"Sports"]){
        NSArray *array = [NSArray arrayWithObjects:
                          [NSPredicate predicateWithFormat:@"SELF.category beginswith[c] %@", @"Baseball"],[NSPredicate predicateWithFormat:@"SELF.category beginswith[c] %@", @"Basketball"], [NSPredicate predicateWithFormat:@"SELF.category beginswith[c] %@", @"Football"], [NSPredicate predicateWithFormat:@"SELF.category beginswith[c] %@", @"Golf"], [NSPredicate predicateWithFormat:@"SELF.category beginswith[c] %@", @"Soccer"], [NSPredicate predicateWithFormat:@"SELF.category beginswith[c] %@", @"Tennis"], [NSPredicate predicateWithFormat:@"SELF.category beginswith[c] %@", @"Track and Field"],  [NSPredicate predicateWithFormat:@"SELF.category beginswith[c] %@", @"Volleyball"], [NSPredicate predicateWithFormat:@"SELF.category beginswith[c] %@", @"Water Polo"], [NSPredicate predicateWithFormat:@"category = %@", self.title], nil];
        predicate = [NSCompoundPredicate orPredicateWithSubpredicates: array];
        
    }else if([self.title isEqualToString:@"News"]){
        NSArray *array = [NSArray arrayWithObjects:[NSPredicate predicateWithFormat:@"SELF.category beginsWith[c] %@", @"Roundup"], [NSPredicate predicateWithFormat:@"SELF.category beginsWith[c] %@", self.title], nil];
        
        predicate = [NSCompoundPredicate orPredicateWithSubpredicates: array];
        
    }else if([self.title isEqualToString:@"Lifestyle"]){
        NSArray *array = [NSArray arrayWithObjects:[NSPredicate predicateWithFormat:@"SELF.category beginsWith[c] %@", @"Film"] ,[NSPredicate predicateWithFormat:@"SELF.category beginsWith[c] %@", @"Games"], [NSPredicate predicateWithFormat:@"SELF.category beginsWith[c] %@", @"Music"], [NSPredicate predicateWithFormat:@"SELF.category beginsWith[c] %@", @"Reviews"], [NSPredicate predicateWithFormat:@"SELF.category beginsWith[c] %@", @"Theatre"] ,[NSPredicate predicateWithFormat:@"SELF.category beginsWith[c] %@", self.title],  nil];
        predicate = [NSCompoundPredicate orPredicateWithSubpredicates: array];
        
    }else if([self.title isEqualToString:@"Opinion"]){
        
        predicate = [NSPredicate predicateWithFormat:@"SELF.category beginsWith[c] %@", self.title];
    }
    
    
    fetchRequest.predicate = predicate;
    return fetchRequest;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    Entry *entry;
    if(tableView == self.searchDisplay.searchResultsTableView){
        entry = [searchedEntries objectAtIndex:indexPath.row];
    }
    else entry = [_allEntries objectAtIndex:indexPath.row];
    
//    NewsViewController* news = [[NewsViewController alloc] initWithLink: entry.articleURL];
    NewsViewController* news = [[NewsViewController alloc] initWithEntry: entry];
    news.managedObjectContext = _managedObjectContext;
    [self.navigationController pushViewController:news animated:YES];
    
    
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
//                NSLog(@"%@", articleTitle);
                Entry *e = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:_managedObjectContext];
                e.articleTitle = articleTitle;
                e.articleURL = articleUrl;
                e.author = articleAuthor;
                e.articleDate = articleDate;
                e.category = category;
                e.favorite = NO;
                newData = YES;
                e.read = [NSNumber numberWithInt:0];
                NSError *error;
                if(![_managedObjectContext save:&error]){
                    NSLog(@"couldn't save %@", [error localizedDescription]);
                }
            }
        }
    }
    return newData;
}

- (BOOL)parseFeed:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {
    BOOL newData = NO;
    if ([rootElement.name compare:@"rss"] == NSOrderedSame) {
        newData = [self parseRss:rootElement entries:entries];
    }else {
        NSLog(@"Unsupported root element: %@", rootElement.name);
    }
    return newData;
}


- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: %@", error);
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    NSInteger currentOffset = self.tableView.contentOffset.y;
    NSInteger maximumOffset = self.tableView.contentSize.height - self.tableView.frame.size.height;
    
    if (maximumOffset - currentOffset <= -20) {
        [self refresh:[NSString stringWithFormat:@"http://dailytrojan.com/feed/rss/?paged=%i", _allEntries.count / 50 + 2 ]];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext:_managedObjectContext];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"articleDate" ascending:NO];
        NSArray * descriptors = [NSArray arrayWithObject:sortDescriptor];
        fetchRequest.sortDescriptors = descriptors;
        
        if(![self.title isEqualToString:@"Home"]){
            fetchRequest = [self sortCD];
            
        }
        
        _allEntries = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
        [self.tableView reloadData];
    }
        //bug: when it's in one of the sections page, it fails to go beyond 2, coz _all entries is almost always < 50
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
/*
    
    
    if(indexPath.row == [_allEntries count] - 1){
        NSLog(@"getting new entries");
//        [self refresh:[NSString stringWithFormat:@"http://dailytrojan.com/feed/rss/?paged=%i", _allEntries.count / 50 + 2 ]];
//bug: when it's in one of the sections page, it fails to go beyond 2, coz _all entries is almost always < 50
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext:_managedObjectContext];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"articleDate" ascending:NO];
        NSArray * descriptors = [NSArray arrayWithObject:sortDescriptor];
        fetchRequest.sortDescriptors = descriptors;
        
        if(![self.title isEqualToString:@"Home"]){
            fetchRequest = [self sortCD];
            
        }
        
        
        _allEntries = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
        [self.tableView reloadData];
    }
     */
}



/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    // return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}



#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.searchDisplay.searchResultsTableView)
        return [self.searchedEntries count];
    else return [_allEntries count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"Cell";
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Cell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[Cell alloc] init];
    }
    
    Entry *entry;
    if([_allEntries count]){
        
        if(tableView == self.searchDisplay.searchResultsTableView)
            entry = [searchedEntries objectAtIndex:indexPath.row];
        
        else entry = [_allEntries objectAtIndex:indexPath.row];
        
        NSString *articleDateString;
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
        NSDate *today = [cal dateFromComponents:components];
        components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:entry.articleDate];
        NSDate *otherDate = [cal dateFromComponents:components];
        
        if([today isEqualToDate:otherDate]) {
            articleDateString = @"Today at ";
            NSDateFormatter * timeFormatter = [[NSDateFormatter alloc] init] ;
            timeFormatter.dateFormat = @"hh:mm";
            articleDateString = [articleDateString stringByAppendingString:[timeFormatter stringFromDate: entry.articleDate]];
        }
        else{
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
			[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm"];
            articleDateString = [dateFormatter stringFromDate:entry.articleDate];
            
        }
        cell.mainLabel.text = entry.articleTitle;
        cell.category.text = entry.category;
        cell.dateLabel.text = articleDateString;
        
        UILongPressGestureRecognizer* sgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector (longPress:)];
        cell.isAccessibilityElement = YES;
        cell.accessibilityLabel = cell.textLabel.text;
        cell.accessibilityValue = cell.textLabel.text;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        if(entry.read == [NSNumber numberWithInt:0]){
            cell.backgroundColor = [UIColor blueColor];
        }
        else cell.backgroundColor = [UIColor clearColor];
        
        [cell addGestureRecognizer:sgr];
        if([entry.category isEqualToString:@"News"]){
            cell.imageView.image = [UIImage imageNamed:@"NewsIcon.jpg"];
        }else if([entry.category isEqualToString:@"Sports"] || [entry.category isEqualToString:@"Football"] || [entry.category isEqualToString:@"Golf"] || [entry.category isEqualToString:@"Water Polo"] || [entry.category isEqualToString:@"Baseball"] || [entry.category isEqualToString:@"Basketball"])
            cell.imageView.image = [UIImage imageNamed:@"SportsIcon.jpg"];
        else if([entry.category isEqualToString:@"Lifestyle"] || [entry.category isEqualToString:@"Game"] || [entry.category isEqualToString:@"Film"] || [entry.category isEqualToString:@"Reviews"] || [entry.category isEqualToString:@"Theatre"] || [entry.category isEqualToString:@"Music"])
            cell.imageView.image = [UIImage imageNamed:@"LifestyleIcon.jpg"];
        else if([entry.category isEqualToString:@"Opinion"])
            cell.imageView.image = [UIImage imageNamed:@"OpinionIcon.jpg"];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    
    return cell;
}

-(void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    UITableViewCell *cell = (UITableViewCell *)gestureRecognizer.view;
    
    [UIView animateWithDuration:1 animations:^{
        cell.backgroundColor = [UIColor grayColor];
    } completion:^(BOOL finished) {
        // show after hiding
        [UIView animateWithDuration:1 animations:^{
            cell.backgroundColor = [UIColor whiteColor];
        } completion:^(BOOL finished) {
            
        }];
    }];
    
    
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // if (editingStyle == UITableViewCellEditingStyleDelete) {
    // // Delete the row from the data source.
    // [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    // }
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}



/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    _allEntries = nil;
    _queue = nil;
}


@end

