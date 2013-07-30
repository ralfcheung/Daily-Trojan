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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGSize size = self.contentView.frame.size;
        category = [[UILabel alloc] init];
        [category setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.mainLabel = [[UILabel alloc] init];
        [self.mainLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.mainLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        self.mainLabel.lineBreakMode = NSTextAlignmentJustified;
        self.mainLabel.backgroundColor = [UIColor clearColor];
        self.mainLabel.numberOfLines = 0;
        category.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
//        [self.mainLabel setFont:[UIFont boldSystemFontOfSize:24.0]];
        [self.mainLabel setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [category setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [self.contentView addSubview:category];
        [self.contentView addSubview:self.mainLabel];
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
