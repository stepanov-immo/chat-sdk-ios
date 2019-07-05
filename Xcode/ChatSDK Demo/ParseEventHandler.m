//
//  ParseEventHandler.m
//  ChatSDK Demo
//
//  Created by Alexander Stepanov on 05/07/2019.
//  Copyright © 2019 deluge. All rights reserved.
//

#import "ParseEventHandler.h"
#import <Parse/Parse.h>
#import <ChatSDK/Core.h>
#import "CCUserWrapper.h"
#import "CCThreadWrapper.h"
#import "NSObject+ParseHelper.h"

@implementation ParseEventHandler

- (void)currentUserOn:(NSString *)entityID {
    id<PUser> user = [BChatSDK.db fetchEntityWithID:entityID withType:bUserEntity];
    
    [BHookNotification notificationUserOn:user];
    
    [self threadsOn:user];
    //[self publicThreadsOn:user];
    [self contactsOn:user];
    //[self moderationOn: user];
    //[self onlineOn];
}

- (void)currentUserOff:(NSString *)entityID {
    id<PUser> user = [BChatSDK.db fetchEntityWithID:entityID withType:bUserEntity];
    
    [self threadsOff:user];
    //[self publicThreadsOff:user];
    [self contactsOff:user];
    //[self moderationOff:user];
    //[self onlineOff];
}

-(void) contactsOn: (id<PUser>) user {
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserContact"];
    [query whereKey:@"user" equalTo:[PFUser objectWithoutDataWithObjectId:BChatSDK.currentUserID]]; // ???
    
    [self observe:@"contacts"
            query:query
      childChange:^(PFObject *added, PFObject *removed) {
          if(added != nil) {
              PFObject* c = added[@"contact"];
              NSString* key = c.objectId;
              NSNumber* type = added[bType];

              id<PUser> contact = [BChatSDK.db fetchOrCreateEntityWithID:key withType:bUserEntity];
              if (type) {
                  [BChatSDK.contact addLocalContact:contact withType:type.intValue];
              }
          }
          
          if(removed != nil) {
              PFObject* c = removed[@"contact"];
              NSString* key = c.objectId;
              NSNumber* type = added[bType];
              
              id<PUser> contact = [BChatSDK.db fetchOrCreateEntityWithID:key withType:bUserEntity];
              if (type) {
                  [BChatSDK.contact deleteLocalContact:contact withType:type.intValue];
              }
          }
      }];
}

-(void) contactsOff: (id<PUser>) user {
//    for (id<PUserConnection> contact in [user connectionsWithType:bUserConnectionTypeContact]) {
//        // Turn the contact on
//        id<PUser> contactModel = contact.user;
//        [[[CCUserWrapper alloc]initWithModel:contactModel] off];
//        [[[CCUserWrapper alloc]initWithModel:contactModel] onlineOff];
//    }
}

-(void) threadsOn: (id<PUser>) user {
    NSString * entityID = user.entityID;
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserThread"];
    [query whereKey:@"user" equalTo:[PFUser objectWithoutDataWithObjectId:entityID]];
    
    [self observe:@"user_threads"
            query:query
      childChange:^(PFObject *added, PFObject *removed) {
          if (added != nil) {
              // Make the new thread
              PFObject* t = added[@"thread"];
              [t fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                  if (!error) {
                      CCThreadWrapper * thread = [CCThreadWrapper threadWithParseObject:object];
                      if (![thread.model.users containsObject:user]) {
                          [thread.model addUser:user];
                      }
                      
                      //              [thread on];
                      //              [thread messagesOn];
                      [thread usersOn];
                      //              [thread lastMessageOn];
                      //              [thread metaOn];
                  }
              }];
          }
          
          if (removed != nil) {
              PFObject* t = removed[@"thread"];
              [t fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                  if (!error) {
                      CCThreadWrapper * thread = [CCThreadWrapper threadWithParseObject:object];
                      //              [thread off];
                      //              [thread messagesOff]; // We need to turn the messages off incase we rejoin the thread
                      //              [thread lastMessageOff];
                      //              [thread metaOff];
                      
                      [BChatSDK.core deleteThread:thread.model];
                  }
              }];
          }
      }];
}

-(void) threadsOff: (id<PUser>) user {
    //NSString * entityID = user.entityID;
    [self removeQueryObserver:@"user_threads"];
    
    if (user) {
        for (id<PThread> threadModel in user.threads) {
            //CCThreadWrapper * thread = [CCThreadWrapper threadWithModel:threadModel];
            //[thread off];
        }
    }
}

@end
