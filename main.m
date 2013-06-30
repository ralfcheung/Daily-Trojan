
//  main.m
//  RSSFun
//
//  Created by Ray Wenderlich on 1/24/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
//    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSLog(@"%@\n", [[NSBundle mainBundle] bundleIdentifier]);
    int retVal = UIApplicationMain(argc, argv, nil, nil);
//    [pool release];
    return retVal;
}
