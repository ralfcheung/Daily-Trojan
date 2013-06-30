//
//  Story.h
//  Daily Trojan
//
//  Created by Ralf Cheung on 6/6/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entry;

@interface Story : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSData * storyPicture;
@property (nonatomic, retain) NSString * captions;
@property (nonatomic, retain) Entry *entry;

@end
