//  main.m
//  RSSFun
//
//  Created by Ralf Cheung on 5/1/13.
//  Copyright 2013 Ralf Cheung. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSLog(@"%@\n", [[NSBundle mainBundle] bundleIdentifier]);
    int retVal = UIApplicationMain(argc, argv, nil, nil);

    return retVal;
}
