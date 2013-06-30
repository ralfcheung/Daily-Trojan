//
//  Story+DT.m
//  Daily Trojan
//
//  Created by Ralf Cheung on 5/18/13.
//
//

#import "Story+DT.h"

@implementation Story (DT)

+ (Story *) storyinManagedObjectContext: (NSManagedObjectContext *)context storyContent:(NSString *)story picture: (NSData *)picture caption: (NSString *)caption{
    
    Story *s = [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:context];
    if(story)
        s.content = story;
//    s.storyPicture = picture;
    if(caption)
        s.captions = caption;

    return s;
    
}


@end
