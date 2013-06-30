//
//  UISearchBarSolidColor.m
//  Daily Trojan
//
//  Created by Ralf Cheung on 5/23/13.
//
//

#import "UISearchBarSolidColor.h"

@implementation UISearchBarSolidColor

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 133/255.0f, 5/255.0f, 3/255.0f, 1.0f);
    CGContextFillRect(context, rect);


}

@end
