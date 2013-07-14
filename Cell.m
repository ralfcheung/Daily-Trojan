//
//  Cell.m
//  Daily Trojan
//
//  Created by Ralf Cheung on 6/28/13.
//
//

#import "Cell.h"

@implementation Cell
@synthesize category;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGSize size = self.contentView.frame.size;
        NSLayoutConstraint *categoryConstraint = [[NSLayoutConstraint alloc] init];
        category = [[UILabel alloc] initWithFrame:CGRectMake(10, -20, 100, 20)];
        self.mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 8.0, size.width - 16.0, size.height - 16.0)];
        self.mainLabel.numberOfLines = 2;
        self.mainLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        self.mainLabel.lineBreakMode = NSTextAlignmentJustified;
        self.mainLabel.backgroundColor = [UIColor clearColor];
        category.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
//        [self.mainLabel setFont:[UIFont boldSystemFontOfSize:24.0]];
//        [self.mainLabel setTextAlignment:NSTextAlignmentCenter];
//        [self.mainLabel setTextColor:[UIColor orangeColor]];
        [self.mainLabel setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [category setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [self.contentView addSubview:category];
        [self.contentView addSubview:self.mainLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
