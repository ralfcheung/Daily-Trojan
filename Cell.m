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
@synthesize imageView;
@synthesize dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        category = [[UILabel alloc] init];
        [category setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.mainLabel = [[UILabel alloc] init];
        [self.mainLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            self.mainLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:19];
        else
            self.mainLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        self.mainLabel.lineBreakMode = NSTextAlignmentJustified;
        self.mainLabel.backgroundColor = [UIColor clearColor];
        self.mainLabel.numberOfLines = 0;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            category.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        else
            category.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
        [self.mainLabel setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [category setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        category.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:category];
        [self.contentView addSubview:self.mainLabel];
        dateLabel = [[UILabel alloc] init];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        else
            dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        [dateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        dateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:dateLabel];
        
        imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:imageView];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                        attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeLeft
                                                       multiplier:1.0f
                                                          constant:15]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0f
                                                          constant:10]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0f
                                                          constant:-10]];
    
        [self addConstraint:[NSLayoutConstraint constraintWithItem:dateLabel
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0f constant:70]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:dateLabel
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0f constant:-10]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:category
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0f constant:70]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:category
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0f constant:10]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.mainLabel
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0f constant:70]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.mainLabel
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.category
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0f constant:10]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.mainLabel
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f constant:-10]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.mainLabel
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0f constant:-20]];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
