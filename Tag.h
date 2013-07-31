//
//  Tag.h
//  Daily Trojan
//
//  Created by Ralf Cheung on 7/31/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * word;
@property (nonatomic) int16_t count;

@end
