//
//  FirstPageViewController.h
//  Daily Trojan
//
//  Created by Ralf Cheung on 7/19/13.
//
//

#import <UIKit/UIKit.h>
#import "UIImage+ImageEffects.h"
#import "Entry.h"
@interface FirstPageViewController : UIViewController
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) Entry *entry;

-(id) initWithTitles;

@end
