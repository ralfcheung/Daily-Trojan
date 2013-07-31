//
//  HTMLOperation.m
//  Daily Trojan
//
//  Created by Ralf Cheung on 7/30/13.
//
//

#import "HTMLOperation.h"
#import "TFHpple.h"

@implementation HTMLOperation
@synthesize articleURL;

-(void) main{
    if ([self isCancelled]) {
        NSLog(@"** operation cancelled **");
    }
    
    // Do some work here
    
    if ([self isCancelled]) {
        NSLog(@"** operation cancelled **");
    }
}


-(void) downloadHTMLFileAndParseIt{
    /*NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:articleURL]];
    
    if(tutorialsHtmlData){
        NSString *str = [[NSString alloc] initWithData:tutorialsHtmlData encoding:NSUTF8StringEncoding];
        tutorialsHtmlData = [str dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
        
        NSString *tutorialsXpathQueryString = @"//p[@class='author']/span[@class='upper'] | //div[@class='post']/h1 | //div[@class='entry']/p";
        NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
        content = [[NSString alloc] init];
        for (TFHppleElement *element in tutorialsNodes) {
            content = [content stringByAppendingString:[self getStringForTFHppleElement: element]];
//        content = [content stringByAppendingString:@"\n\n"];
            
        }
        
        //    content = [content stringByReplacingOccurrencesOfString:@"\n\n\n" withString:@"\n\n"];
        
        //    NSLog(@"%@", content);
        NSString *captionString;
        
        tutorialsXpathQueryString = @"//p[@class='wp-caption-text']";
        tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
        if(tutorialsNodes)
            captionString = [self getStringForTFHppleElement:[tutorialsNodes lastObject]];
        
        entry.story = [Story storyinManagedObjectContext:_managedObjectContext storyContent:content picture:nil caption:captionString];
        
        tutorialsXpathQueryString = @"//a";
        tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
        
        for (TFHppleElement *element in tutorialsNodes) {
            NSRange range = [[element objectForKey: @"href"] rangeOfString:@".jpg"];
            if(range.location == NSNotFound){}
            else{
                imageUrl = [[element objectForKey:@"href"] copy];
                break;
            }
        }
    }
    //change it to 'read'
    else if(entry.story.content){
        content = entry.story.content;
        title = entry.articleTitle;
        author = [[NSMutableString alloc] initWithString:entry.author];
    }else{
        //pop a UIAlert
    }
    */
    
}

@end
