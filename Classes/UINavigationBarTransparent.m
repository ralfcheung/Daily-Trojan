//
//  UINavigationBarTransparent.m
//  Daily Trojan
//
//  Created by Ralf Cheung on 5/31/13.
//
//

#import "UINavigationBarTransparent.h"

@implementation UINavigationBarTransparent

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.*/
- (void)drawRect:(CGRect)rect
{
    self.translucent = YES;
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor clearColor];
    self.opaque = YES;
}


@end
