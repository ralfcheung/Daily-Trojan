//
//  TwitterREST.m
//  Daily Trojan
//
//  Created by Ralf Cheung on 8/18/13.
//
//

#import "TwitterREST.h"

@implementation TwitterREST
@synthesize accountStore;

- (BOOL)userHasAccessToTwitter
{
    accountStore = [[ACAccountStore alloc] init];

    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

-(void) followWriterTwitter:(NSString *)userName{
    if ([self userHasAccessToTwitter]) {
    
        ACAccountType *twitterAccountType = [self.accountStore
                                             accountTypeWithAccountTypeIdentifier:
                                             ACAccountTypeIdentifierTwitter];
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error) {
            if (granted) {
                NSArray *twitterAccounts =
                [self.accountStore accountsWithAccountType:twitterAccountType];
                NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"];
                NSDictionary *params = @{@"screen_name" : userName,
                                         @"follow" : @"true"};
                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                        requestMethod:SLRequestMethodPOST
                                                                  URL:url
                                                           parameters:params];
                [request setAccount:[twitterAccounts lastObject]];
                [request performRequestWithHandler:^(NSData *responseData,
                                                    NSHTTPURLResponse *urlResponse,
                                                    NSError *error) {
                    NSLog(@"URL Response Data: %i", [urlResponse statusCode]);
                    if ([urlResponse statusCode] != 200) {
                        NSLog(@"Twitter warning");
                    }
                }];
            }
        }];
    
    }
}
@end
