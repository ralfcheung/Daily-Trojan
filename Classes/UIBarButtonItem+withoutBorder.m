//
//  UIBarButtonItem+withoutBorder.m
//  Daily Trojan
//
//  Created by Ralf Cheung on 5/23/13.
//
//

#import "UIBarButtonItem+withoutBorder.h"

@implementation UIBarButtonItem (withoutBorder)
+ (UIBarButtonItem*)barItemWithImage:(UIImage*)image target:(id)target action:(SEL)action{
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake(30, 0, image.size.width, image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[self alloc] initWithCustomView:button];
    
    
}
@end
