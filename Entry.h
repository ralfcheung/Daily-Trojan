//
//  Entry.h
//  Daily Trojan
//
//  Created by Ralf Cheung on 6/13/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Story;

@interface Entry : NSManagedObject

@property (nonatomic, retain) NSDate * articleDate;
@property (nonatomic, retain) NSString * articleTitle;
@property (nonatomic, retain) NSString * articleURL;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) Story *story;

@end
