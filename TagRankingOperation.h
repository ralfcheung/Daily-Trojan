//
//  TagRankingOperation.h
//  Daily Trojan
//
//  Created by Ralf Cheung on 7/30/13.
//
//

#import <Foundation/Foundation.h>
@protocol TaggingDelegate;

@interface TagRankingOperation : NSOperation
@property (nonatomic, weak) id <TaggingDelegate> delegate;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDictionary *tags;
@end

@protocol TaggingDelegate <NSObject>
-(void)finishedTagging: (NSDictionary *)tags;
@end