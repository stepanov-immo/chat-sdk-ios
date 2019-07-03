//
//  BFirebaseEventHandler.m
//  Chat SDK
//
//  Created by Benjamin Smiley-andrews on 10/02/2015.
//  Copyright (c) 2015 deluge. All rights reserved.
//

#import "BFirebaseEventHandler.h"

#import "FirebaseAdapter.h"
#import "ParseAdapter.h"

@implementation BFirebaseEventHandler

-(void) currentUserOn: (NSString *) entityID {
    
    id<PUser> user = [BChatSDK.db fetchEntityWithID:entityID withType:bUserEntity];

    [BHookNotification notificationUserOn:user];
    
    [self threadsOn:user];
    [self publicThreadsOn:user];
    [self contactsOn:user];
    [self moderationOn: user];
    [self onlineOn];

}

// todo
-(void) onlineOn {
    [[[[FIRDatabase database] reference] child:@".info/connected"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * snapshot) {
        if (![snapshot.value isEqual: NSNull.null]) {
            NSLog(@"Connected");
        } else {
            NSLog(@"Disconnected");
        }
    }];
}

// todo
-(void) onlineOff {
    [[[[FIRDatabase database] reference] child:@".info/connected"] removeAllObservers];
}

-(void) threadsOn: (id<PUser>) user {
    NSString * entityID = user.entityID;
    
    [self observe:@"user_threads" query:[PFQuery userThreads:entityID] childChange:^(PFObject *added, PFObject *removed) {
        if (added != nil) {
            // Make the new thread
            PFObject* t = added[@"thread"];
            NSString* key = t.objectId;

            CCThreadWrapper * thread = [CCThreadWrapper threadWithEntityID:key];
            if (![thread.model.users containsObject:user]) {
                [thread.model addUser:user];
            }
            
            [thread on];
            [thread messagesOn];
            [thread usersOn];
            [thread lastMessageOn];
            [thread metaOn];
        }
        
        if (removed != nil) {
            PFObject* t = added[@"thread"];
            NSString* key = t.objectId;
            
            CCThreadWrapper * thread = [CCThreadWrapper threadWithEntityID:key];
            [thread off];
            [thread messagesOff]; // We need to turn the messages off incase we rejoin the thread
            [thread lastMessageOff];
            [thread metaOff];
            
            [BChatSDK.core deleteThread:thread.model];
        }
    }];
}

// todo
-(void) publicThreadsOn: (id<PUser>) user {
    FIRDatabaseReference * publicThreadsRef = [FIRDatabaseReference publicThreadsRef];

    // TODO: This may cause issues if the device's clock is wrong
    FIRDatabaseQuery * query = [publicThreadsRef queryOrderedByChild:bCreationDate];
    double loadRoomsSince = ([[NSDate date] timeIntervalSince1970] - BChatSDK.config.publicChatRoomLifetimeMinutes * 60) * 1000;
    [query queryStartingAtValue: @(loadRoomsSince)];
    
    [query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * snapshot) {
        if (snapshot.value != [NSNull null]) {
            // Make the new thread
            CCThreadWrapper * thread = [CCThreadWrapper threadWithEntityID:snapshot.key];
            
            // Make sure that we're not in the thread
            // there's an edge case where the user could kill the app and remain
            // a member of a public thread
            [thread removeUser:[CCUserWrapper userWithModel:user]];
            
            [thread on];
            
            // TODO: Maybe move this so we only listen to a thread when it's open
            [thread messagesOn];
            [thread usersOn];
            [thread lastMessageOn];
            [thread metaOn];
        }
    }];
}

-(void) contactsOn: (id<PUser>) user {
    
    [self observe:@"contacts" query:[PFQuery userContacts:BChatSDK.currentUserID] childChange:^(PFObject *added, PFObject *removed) {
        if(added != nil) {
            PFObject* t = added[@"contact"];
            NSString* key = t.objectId;
            NSNumber* type = added[@"type"]; // bType

            id<PUser> contact = [BChatSDK.db fetchOrCreateEntityWithID:key withType:bUserEntity];
            if (type) {
                [BChatSDK.contact addLocalContact:contact withType:type.intValue];
            }
        }
        
        if(removed != nil) {
            PFObject* t = added[@"contact"];
            NSString* key = t.objectId;
            NSNumber* type = added[@"type"]; // bType

            id<PUser> contact = [BChatSDK.db fetchOrCreateEntityWithID:key withType:bUserEntity];
            if (type) {
                [BChatSDK.contact deleteLocalContact:contact withType:type.intValue];
            }
        }
    }];
}

-(void) moderationOn: (id<PUser>) user {
    if (BChatSDK.config.enableMessageModerationTab) {
        [BChatSDK.moderation on];
    }
}

-(void) currentUserOff: (NSString *) entityID {
    id<PUser> user = [BChatSDK.db fetchEntityWithID:entityID withType:bUserEntity];
    [self threadsOff:user];
    [self publicThreadsOff:user];
    [self contactsOff:user];
    [self moderationOff:user];
    [self onlineOff];
}

-(void) threadsOff: (id<PUser>) user {
    //NSString * entityID = user.entityID;
    [self removeQueryObserver:@"user_threads"];
    
    if (user) {
        for (id<PThread> threadModel in user.threads) {
            CCThreadWrapper * thread = [CCThreadWrapper threadWithModel:threadModel];
            [thread off];
        }
    }
}

// todo
-(void) publicThreadsOff: (id<PUser>) user {
    FIRDatabaseReference * publicThreadsRef = [FIRDatabaseReference publicThreadsRef];
    for (id<PThread> threadModel in [BChatSDK.core threadsWithType:bThreadTypePublicGroup]) {
        CCThreadWrapper * thread = [CCThreadWrapper threadWithModel:threadModel];
        [thread off];
    }
    [publicThreadsRef removeAllObservers];
}

-(void) contactsOff: (id<PUser>) user {
    for (id<PUserConnection> contact in [user connectionsWithType:bUserConnectionTypeContact]) {
        // Turn the contact on
        id<PUser> contactModel = contact.user;
        [[CCUserWrapper userWithModel:contactModel] off];
        [[CCUserWrapper userWithModel:contactModel] onlineOff];
    }
}

-(void) moderationOff: (id<PUser>) user {
    if (BChatSDK.config.enableMessageModerationTab) {
        [BChatSDK.moderation off];
    }
}

@end
