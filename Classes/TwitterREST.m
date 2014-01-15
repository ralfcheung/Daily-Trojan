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
@synthesize userName;


- (BOOL)userHasAccessToTwitter
{
    accountStore = [[ACAccountStore alloc] init];

    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

-(void) followWriterTwitter{

    if ([self userHasAccessToTwitter]) {

        ACAccountType *twitterAccountType = [self.accountStore
                                             accountTypeWithAccountTypeIdentifier:
                                             ACAccountTypeIdentifierTwitter];
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error) {
            if (granted) {
                NSArray *twitterAccounts =
                [self.accountStore accountsWithAccountType:twitterAccountType];
                NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"];
                NSDictionary *params = @{@"screen_name" : self.userName,
                                         @"follow" : @"true"};
                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                        requestMethod:SLRequestMethodPOST
                                                                  URL:url
                                                           parameters:params];
                [request setAccount:[twitterAccounts lastObject]];
                [request performRequestWithHandler:^(NSData *responseData,
                                                    NSHTTPURLResponse *urlResponse,
                                                    NSError *error) {
                    if ([urlResponse statusCode] != 200) {
                        NSLog(@"Twitter warning");
                        NSLog(@"URL Response Data: %@", [NSHTTPURLResponse localizedStringForStatusCode: [urlResponse statusCode]]);
                    }
                }];
            }
        }];
    
    }
}
@end
