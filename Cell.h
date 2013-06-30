//
//  Cell.h
//  Daily Trojan
//
//  Created by Ralf Cheung on 6/28/13.
//
//

#import <UIKit/UIKit.h>

@interface Cell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *mainLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondLabel;
@property (strong, nonatomic) IBOutlet UILabel *category;

@end
