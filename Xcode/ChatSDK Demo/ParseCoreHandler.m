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
#import "CCThreadWrapper.h"
#import "CCMessageWrapper.h"

@implementation ParseCoreHandler

-(CCUserWrapper *) currentUser {
    return [CCUserWrapper userWithModel:self.currentUserModel];
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
    [[CCUserWrapper userWithModel:userModel] onlineOn];
//    return [[CCUserWrapper userWithModel:userModel] metaOn];
    return nil;
}

-(RXPromise *) createThreadWithUsers: (NSArray *) users
                                name: (NSString *) name
                                type: (bThreadType) type
                         forceCreate: (BOOL) force
                       threadCreated: (void(^)(NSError * error, id<PThread> thread)) threadCreated {
    
    id<PThread> threadModel = [self fetchThreadWithUsers: users];
    if (threadModel && threadCreated != Nil && !force) {
        threadCreated(Nil, threadModel);
        return [RXPromise resolveWithResult:Nil];
    }
    else {
        threadModel = [self createThreadWithUsers:users name:name type: type];
        CCThreadWrapper * thread = [CCThreadWrapper threadWithModel:threadModel];
        
        return [thread push].thenOnMain(^id(id<PThread> thread) {
            
            // Add the users to the thread
            if (threadCreated != Nil) {
                threadCreated(Nil, thread);
            }
            return [self addUsers:threadModel.users.allObjects toThread:threadModel];
            
        },^id(NSError * error) {
            //[BChatSDK.db undo];
            
            if (threadCreated != Nil) {
                threadCreated(error, Nil);
            }
            return error;
        });
    }
}

-(RXPromise *) addUsers: (NSArray *) users toThread: (id<PThread>) threadModel {
    
    CCThreadWrapper * thread = [CCThreadWrapper threadWithModel:threadModel];
    
    NSMutableArray * promises = [NSMutableArray new];
    
    // Push each user to make sure they have an account
    for (id<PUser> userModel in users) {
        [promises addObject:[thread addUser:[CCUserWrapper userWithModel:userModel]]];
    }
    
    return [RXPromise all: promises];
}

-(RXPromise *) sendMessage: (id<PMessage>) messageModel {
    
    [BHookNotification notificationMessageWillSend:messageModel];
    
    // Create the new CCMessage wrapper
    [BHookNotification notificationMessageSending:messageModel];
    return [[CCMessageWrapper messageWithModel:messageModel] send].thenOnMain(^id(id success) {
        
        // Send a push notification for the message
        NSDictionary * pushData = [BChatSDK.push pushDataForMessage:messageModel];
        [BChatSDK.push sendPushNotification:pushData];
        
        [BHookNotification notificationMessageDidSend:messageModel];
        return success;
    }, Nil);
    
}

@end
