//
//  FlickrAlbumCollectionViewCell.m
//  Daily Trojan
//
//  Created by Ralf Cheung on 8/25/13.
//
//

#import "FlickrAlbumCollectionViewCell.h"

@implementation FlickrAlbumCollectionViewCell
@synthesize imageView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[imageView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(imageView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(imageView)]];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
