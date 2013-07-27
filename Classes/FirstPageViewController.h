//
//  FirstPageViewController.h
//  Daily Trojan
//
//  Created by Ralf Cheung on 7/19/13.
//
//

#import <UIKit/UIKit.h>

@interface FirstPageViewController : UIViewController
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
-(id) initWithTitles;

@end
