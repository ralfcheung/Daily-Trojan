//
//  TwitterREST.h
//  Daily Trojan
//
//  Created by Ralf Cheung on 8/18/13.
//
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface TwitterREST : NSObject
@property (nonatomic, strong) ACAccountStore *accountStore;
-(void) followWriterTwitter:(NSString *)userName;

@end
