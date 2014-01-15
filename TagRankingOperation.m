//
//  TagRankingOperation.m
//  Daily Trojan
//
//  Created by Ralf Cheung on 7/30/13.
//
//

#import "TagRankingOperation.h"



@implementation TagRankingOperation
@synthesize text;
@synthesize tags = _tags;

-(void) main{
    if ([self isCancelled]) {
        NSLog(@"** operation cancelled **");
    }
    
    // Do some work here
    
    if ([self isCancelled]) {
        NSLog(@"** operation cancelled **");
    }
//    _tags = [self getRanking];
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(finishedTagging:) withObject:self waitUntilDone:NO];

}


-(NSDictionary*) getRanking{
    
    NSString *n = text;
    
    NSMutableDictionary *tags = [NSMutableDictionary dictionary];
    
    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
    
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes: [NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:options];
    tagger.string = n;
    
    [tagger enumerateTagsInRange:NSMakeRange(0, [n length])
                          scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass
                         options:options
                      usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
                          NSString *token = [n substringWithRange:tokenRange];
                          if([tag isEqualToString:NSLinguisticTagPersonalName] || [tag isEqualToString:NSLinguisticTagPlaceName] || [tag isEqualToString:NSLinguisticTagOrganizationName] ){
//                              NSLog(@"%@: %@", token, tag);
                              if (![[tags allKeys] containsObject:token]) {
                                  NSMutableDictionary *tagDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:1], @"count", nil];
                                  [tags setObject:tagDict forKey:token];
                              } else {
                                  NSMutableDictionary *tagDict = [tags objectForKey:token];
                                  [tagDict setObject:[NSNumber numberWithInt:([[tagDict objectForKey:@"count"] intValue] + 1)] forKey:@"count"];
                              }
                          }
                          
                      }];
    
//    NSLog(@"%@", tags);
    return tags;
    
}

@end
