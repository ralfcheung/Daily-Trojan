//
//  LeftViewController.m
//  Daily Trojan
//
//  Created by Ralf Cheung on 4/22/13.
//
//

#import "LeftViewController.h"
#import "IIViewDeckController.h"
#import "RootViewController.h"
#import "WebViewController.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface LeftViewController ()
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSArray *links;
@end

@implementation LeftViewController
@synthesize managedObjectContext = _managedObjectContext;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sections = [NSArray arrayWithObjects:@"news", @"sports",@"lifestyle",@"opinion",nil];
    
    [self.tableView reloadData];
//    UIColor *color = [[UITableViewHeaderFooterView appearance] tintColor];
    
//    [[self tableView] setBackgroundColor: [UIColor colorWithRed:120/255.0f green:21/255.0f blue:27/255.0f alpha:1.0f]];
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        
        [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor colorWithRed:250/255.0f green:250/255.0f blue:250/255.0f alpha:1.0f]];
    }
//    [[UITableViewCell appearance] setTintColor: [UIColor blueColor]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0)
        return 130;
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {

        case 1:
            return [NSString stringWithFormat:@"Sections"];
            break;
        case 2: return [NSString stringWithFormat:@"Find us on"];
            break;
        default: return @" ";
            break;
    }}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    
    if(!section) return 1;
    else if(section == 1) return [self.sections count];
    else return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        if(indexPath.section == 1){
            
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.opacity = 1;
            gradient.frame = cell.bounds;

//            gradient.startPoint = CGPointMake(0, 0.5);
//            gradient.endPoint = CGPointMake(1.0, 0.5);
            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
            UIView *background = [UIView new];
            [background.layer insertSublayer:gradient atIndex:0];
//            cell.backgroundView = background;
//            [cell.layer insertSublayer:gradient below:cell.textLabel.layer];
//            [cell.contentView.layer insertSublayer:gradient below:cell.textLabel.layer];
//            cell.backgroundColor = [UIColor blackColor];

        }

    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext:_managedObjectContext];
    NSArray *result;
    NSString *detail;
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"Daily Trojan";
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
            break;
        case 1:
            cell.textLabel.text = [self.sections objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
            switch (indexPath.row) {
                case 0:
                    cell.imageView.image = [UIImage imageNamed:@"News.png"];
                    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"read == %@ AND category == %@", [NSNumber numberWithInt:0], @"News"];
                    
                    result = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
                    detail = [NSString stringWithFormat:@"%i unread news", [result count]];
                    if([result count])
                        cell.detailTextLabel.text = detail;

                    break;
                case 1:
                    cell.imageView.image = [UIImage imageNamed:@"Sports.png"];
                    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"read == %@ AND category == %@", [NSNumber numberWithInt:0], @"Sports"];
                    result = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
                    if([result count])
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i unread news", [result count]];

                    break;
                case 2:
                    cell.imageView.image = [UIImage imageNamed:@"Lifestyle.png"];
                    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"read == %@ AND category == %@", [NSNumber numberWithInt:0], @"Lifestyle"];
                    result = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
                    if([result count])
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i unread news", [result count]];

                    break;
                case 3:
                    cell.imageView.image = [UIImage imageNamed:@"Opinion.png"];
                    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"read == %@ AND category == %@", [NSNumber numberWithInt:0], @"Opinion"];
                    result = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
                    if([result count])
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i unread news", [result count]];

                    break;
                default:
                    break;
            }
            break;
        case 2:
            if(indexPath.row == 0){
                cell.textLabel.text = @"Twitter";
                cell.imageView.image = [UIImage imageNamed:@"twitterSideBar.png"];
            }
            else cell.textLabel.text = @"Facebook";
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
            break;
        default:
            break;
    }
    
    
    UIView *bgColorView = [[UIView alloc] init];
//    [bgColorView setBackgroundColor: [UIColor colorWithRed:108/255.0f green:16/255.0f blue:24/255.0f alpha:0.6]];
//    [bgColorView setBackgroundColor: [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.6]];
    
    cell.selectedBackgroundView = bgColorView;
    cell.detailTextLabel.textColor =  [UIColor colorWithRed:150/255.0f green:5/255.0f blue:3/255.0f alpha:1.0f];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    //    cell.selectionStyle = UITableViewCellSelectionStyleGray;
//    cell.textLabel.textColor = [UIColor whiteColor];
    
    //    [[cell contentView] setBackgroundColor:color];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext:_managedObjectContext];
    NSArray *result;
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"Daily Trojan";
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
            break;
        case 1:
            cell.textLabel.text = [self.sections objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
            switch (indexPath.row) {
                case 0:
                    cell.imageView.image = [UIImage imageNamed:@"News.png"];
                    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"read == %@ AND category == %@", [NSNumber numberWithInt:0], @"News"];
                    
                    result = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
                    if([result count] != 0)
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i unread news", [result count]];
                    
                    break;
                case 1:
                    cell.imageView.image = [UIImage imageNamed:@"Sports.png"];
                    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"read == %@ AND category == %@", [NSNumber numberWithInt:0], @"Sports"];
                    result = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
                    if([result count] != 0)
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i unread news", [result count]];
                    
                    break;
                case 2:
                    cell.imageView.image = [UIImage imageNamed:@"Lifestyle.png"];
                    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"read == %@ AND category == %@", [NSNumber numberWithInt:0], @"Lifestyle"];
                    result = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
                    if([result count] != 0)
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i unread news", [result count]];
                    
                    break;
                case 3:
                    cell.imageView.image = [UIImage imageNamed:@"Opinion.png"];
                    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"read == %@ AND category == %@", [NSNumber numberWithInt:0], @"opinion"];
                    result = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
                    if([result count] != 0)
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i unread news", [result count]];
                    
                    break;
                default:
                    break;
            }
            break;
        case 2:
            if(indexPath.row == 0) cell.textLabel.text = @"twitter";
            else cell.textLabel.text = @"facebook";
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
            break;
        default:
            break;
    }

    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
        if ([controller.centerController isKindOfClass:[UINavigationController class]]) {
            if(indexPath.section == 2){
                if(indexPath.row == 0){
                    if(![[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"twitter://user?id=18652755"]]){
                        WebViewController *twitter = [[WebViewController alloc] init];
                        controller.centerController = [[UINavigationController alloc] initWithRootViewController:twitter];
                    }
                }
                else [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"fb://profile/14560543971"]];
                
            }
            else {
                RootViewController *rootViewController;
                if(!indexPath.section){
                    rootViewController = [[RootViewController alloc] initWithLink: nil name: @"Home" managedObjectContext: _managedObjectContext];
                    
                }else{
                    
                    rootViewController = [[RootViewController alloc] initWithLink: nil name: [self.sections objectAtIndex:indexPath.row] managedObjectContext: _managedObjectContext];
                }
                controller.centerController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
                if ([rootViewController respondsToSelector:@selector(tableView)]) {
                    [rootViewController.tableView deselectRowAtIndexPath:[rootViewController.tableView indexPathForSelectedRow] animated:NO];
                }
            }
        }
        //        [NSThread sleepForTimeInterval:(300 + arc4random()% 700)/1000000.0]; // mimic delay... not really necessary
    }];
}

@end
