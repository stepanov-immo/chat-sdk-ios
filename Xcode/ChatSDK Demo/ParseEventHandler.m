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
#import "NSObject+ParseHelper.h"

@implementation ParseEventHandler

- (void)currentUserOn:(NSString *)entityID {
    id<PUser> user = [BChatSDK.db fetchEntityWithID:entityID withType:bUserEntity];
    
    [BHookNotification notificationUserOn:user];
    
    //[self threadsOn:user];
    //[self publicThreadsOn:user];
    [self contactsOn:user];
    //[self moderationOn: user];
    //[self onlineOn];
}

- (void)currentUserOff:(NSString *)entityID {
    id<PUser> user = [BChatSDK.db fetchEntityWithID:entityID withType:bUserEntity];
    
    //[self threadsOff:user];
    //[self publicThreadsOff:user];
    [self contactsOff:user];
    //[self moderationOff:user];
    //[self onlineOff];
}

-(void) contactsOn: (id<PUser>) user {
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserContact"];
    [query whereKey:@"user" equalTo:[PFUser objectWithoutDataWithObjectId:BChatSDK.currentUserID]];
    
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

@end
