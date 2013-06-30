//
//  UIBarButtonItem+withoutBorder.h
//  Daily Trojan
//
//  Created by Ralf Cheung on 5/23/13.
//
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (withoutBorder)

+ (UIBarButtonItem*)barItemWithImage:(UIImage*)image target:(id)target action:(SEL)action;

@end
