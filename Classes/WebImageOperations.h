//
//  WebImageOperations.h
//  Daily Trojan
//
//  Created by Ralf Cheung on 6/22/13.
//
//

#import <Foundation/Foundation.h>

@interface WebImageOperations : NSObject
+ (void)processImageDataWithURLString:(NSString *)urlString andBlock:(void (^)(NSData *imageData))processImage;

@end
