//
//  Story+DT.h
//  Daily Trojan
//
//  Created by Ralf Cheung on 5/18/13.
//
//

#import "Story.h"

@interface Story (DT)


+ (Story *) storyinManagedObjectContext: (NSManagedObjectContext *)context storyContent:(NSString *)story picture: (NSData *)picture caption: (NSString *)caption;


@end
