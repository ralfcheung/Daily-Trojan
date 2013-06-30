//
//  UINavigationBarWithoutGradient.m
//  Daily Trojan
//
//  Created by Ralf Cheung on 5/23/13.
//
//

#import "UINavigationBarWithoutGradient.h"
#import "NewsViewController.h"
#import "RootViewController.h"

@implementation UINavigationBarWithoutGradient

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void) drawRect:(CGRect)rect{
    if ([self isMemberOfClass: [NewsViewController class]]){
        NSLog(@"NewViewController\n");
    }
    else if([self isMemberOfClass:[RootViewController class]]) NSLog(@"RootViewController");
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 133/255.0f, 5/255.0f, 3/255.0f, 1.0f);
    CGContextFillRect(context, rect);
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
