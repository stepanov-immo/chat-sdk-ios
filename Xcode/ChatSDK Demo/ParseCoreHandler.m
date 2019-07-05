//
//  ParseCoreHandler.m
//  ChatSDK Demo
//
//  Created by Alexander Stepanov on 05/07/2019.
//  Copyright © 2019 deluge. All rights reserved.
//

#import "ParseCoreHandler.h"
//#import <Parse/Parse.h>
#import <ChatSDK/Core.h>
#import "CCUserWrapper.h"

@implementation ParseCoreHandler

-(CCUserWrapper *) currentUser {
    return [[CCUserWrapper alloc] initWithModel:self.currentUserModel];
}

-(void) goOnline {
    //[FIRDatabaseReference goOnline];
    if (self.currentUserModel) {
        [self setUserOnline];
    }
}

-(void) goOffline {
    //[FIRDatabaseReference goOffline];
}

-(RXPromise *)observeUser: (NSString *)entityID {
    id<PUser> userModel = [BChatSDK.db fetchOrCreateEntityWithID:entityID withType:bUserEntity];
    [[[CCUserWrapper alloc] initWithModel:userModel] onlineOn];
//    return [[CCUserWrapper userWithModel:userModel] metaOn];
    return nil;
}

@end
