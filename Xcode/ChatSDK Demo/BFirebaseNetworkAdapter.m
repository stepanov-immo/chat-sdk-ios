//
//  BFirebaseNetworkAdapter.m
//  Pods
//
//  Created by Benjamin Smiley-andrews on 13/11/2016.
//
//

#import "BFirebaseNetworkAdapter.h"
#import <Parse/Parse.h>
#import "ParseAuthenticationHandler.h"
#import "ParseSearchHandler.h"
#import "ParseCoreHandler.h"
#import "ParseContactHandler.h"
#import "ParseEventHandler.h"

@implementation BFirebaseNetworkAdapter

-(id) init {
    if((self = [super init])) {
        
        [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
            configuration.applicationId = @"com.mdcm.testchatsdk";
            configuration.clientKey = @"";
            configuration.server = @"http://localhost:1337/parse";
            //configuration.server = @"http://10.192.160.10:1337/parse";
        }]];

        
//        if (BChatSDK.config.firebaseShouldConfigureAutomatically) {
//            NSString * plist = BChatSDK.config.firebaseGoogleServicesPlistName;
//            if (plist) {
//                plist = [plist stringByReplacingOccurrencesOfString:@".plist" withString:@""];
//                NSString * path = [[NSBundle mainBundle] pathForResource:plist ofType:@"plist"];
//                FIROptions * options = [[FIROptions alloc] initWithContentsOfFile:path];
//                [FIRApp configureWithOptions:options];
//                [FIRDatabase database].persistenceEnabled = YES;
//            }
//            else {
//                [FIRApp configure];
//            }
//            
//        
//        }
//        
        self.core = [[ParseCoreHandler alloc] init];
        self.auth = [[ParseAuthenticationHandler alloc] init];
        self.search = [[ParseSearchHandler alloc] init];
//        self.moderation = [[BFirebaseModerationHandler alloc] init];
        self.contact = [[ParseContactHandler alloc] init];
//        self.publicThread = [[BFirebasePublicThreadHandler alloc] init];
//        self.users = [[BFirebaseUsersHandler alloc] init];
//        self.contact = [[BFirebaseContactHandler alloc] init];
        self.event = [[ParseEventHandler alloc] init];

    }
    return self;
}

@end
