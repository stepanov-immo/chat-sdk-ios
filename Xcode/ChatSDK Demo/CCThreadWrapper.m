//
//  CCThreadWrapper.m
//  ChatSDK Demo
//
//  Created by Alexander Stepanov on 05/07/2019.
//  Copyright © 2019 deluge. All rights reserved.
//

#import "CCThreadWrapper.h"
#import <Parse/Parse.h>
#import <ChatSDK/Core.h>
#import "NSManagedObject+Status.h"
#import "NSObject+ParseHelper.h"
#import "CCUserWrapper.h"
#import "CCMessageWrapper.h"

@implementation CCThreadWrapper
{
    NSObject<PThread> * _model;
}

+(CCThreadWrapper *) threadWithModel: (id<PThread>) model {
    return [[self alloc] initWithModel:model];
}

-(CCThreadWrapper *) initWithModel: (id<PThread>) model {
    if((self = [self init])) {
        _model = model;
    }
    return self;
}

//+(id) threadWithEntityID: (NSString *) entityID {
//    return [[self alloc] initWithEntityID:entityID];
//}
//
//-(id) initWithEntityID: (NSString *) entityID {
//    if((self = [self init])) {
//        // Get or create the model
//        _model = [BChatSDK.db fetchOrCreateEntityWithID:entityID withType:bThreadEntity];
//    }
//    return self;
//}

+(CCThreadWrapper *) threadWithParseObject: (PFObject *) object {
    return [[self alloc] initWithParseObject:object];
}

-(id) initWithParseObject: (PFObject *) object {
    if((self = [self init])) {
        // Get or create the model
        _model = [BChatSDK.db fetchOrCreateEntityWithID:object.objectId withType:bThreadEntity];
        
        _model.type = object[bType];
        _model.name = object[bUserNameKey];
    }
    return self;
}

-(id<PThread>) model {
    return _model;
}

-(NSString *) entityID {
    return [self model].entityID;
}

-(RXPromise *) push {
    RXPromise * promise = [RXPromise new];
    
//    if(!_model.entityID || !_model.entityID.length) {
//        _model.entityID = [[FIRDatabaseReference threadsRef] childByAutoId].key;
//    }
    
    PFObject *thread = [PFObject objectWithClassName:@"Thread"];
    // details
    thread[bUserNameKey] = _model.name ?: @"";
    thread[bType] = _model.type;
    //thread[bCreatorEntityID] = _model.creator.entityID;
    
    [thread saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            _model.entityID = thread.objectId;
            
            //[BEntity pushThreadDetailsUpdated:self.model.entityID];
            [promise resolveWithResult:_model];
        }
        else {
            [promise rejectWithReason:error];
        }
    }];

    return promise;
}

-(RXPromise *) addUser: (CCUserWrapper *) user {
    
    RXPromise * promise = [RXPromise new];
    
    PFObject *userThread = [PFObject objectWithClassName:@"UserThread"];
    userThread[@"user"] = [PFUser objectWithoutDataWithObjectId:user.entityID];
    userThread[@"thread"] = [PFObject objectWithoutDataWithClassName:@"Thread" objectId:_model.entityID];
    userThread[bStatus] = [self.model.creator.entityID isEqualToString:user.entityID] ? bStatusOwner : bStatusMember;
//    if (_model.type.intValue & bThreadFilterPrivate) {
//        userThread[bInvitedBy] = [PFUser objectWithoutDataWithObjectId:BChatSDK.currentUser.entityID];
//    }
    
    [userThread saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            //[BEntity pushThreadUsersUpdated:self.model.entityID];
            [promise resolveWithResult:_model];
        }
        else {
            [promise rejectWithReason:error];
        }
    }];

    return promise;
}

-(void) usersOn {
    
    if ([((NSManagedObject *)_model) pathOn:bUsersPath]) {
        return;
    }
    [((NSManagedObject *)_model) setPath:bUsersPath on:YES];
    
    {
        PFQuery *query = [PFQuery queryWithClassName:@"UserThread"];
        [query whereKey:@"thread" equalTo:[PFObject objectWithoutDataWithClassName:@"Thread" objectId:self.entityID]];
        [self observe:@"thread_users_change"
                query:query
          childChange:^(PFObject *added, PFObject *removed) {
              if (added != nil) {
                  PFUser* parseUser = added[@"user"];
                  [parseUser fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                      if (!error) {
                          // Update the thread
                          CCUserWrapper * user = [CCUserWrapper userWithAuthUserData:parseUser];
                          [_model addUser:user.model];
                          [user onlineOn];
                          [[NSNotificationCenter defaultCenter] postNotificationName:bNotificationThreadUsersUpdated object:Nil];
                      }
                  }];
              }
              if (removed != nil) {
                  PFUser* parseUser = removed[@"user"];
                  [parseUser fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                      if (!error) {
                          // Update the thread
                          CCUserWrapper * user = [CCUserWrapper userWithAuthUserData:parseUser];
                          [_model removeUser:user.model];
                          [[NSNotificationCenter defaultCenter] postNotificationName:bNotificationThreadUsersUpdated object:Nil];
                      }
                  }];
              }
          }];
    }
    
//    {
//        PFQuery *query = [PFQuery queryWithClassName:@"UserThread"];
//        [query whereKey:@"thread" equalTo:[PFObject objectWithoutDataWithClassName:@"Thread" objectId:self.entityID]];
//        [self observe:@"thread_users_update"
//                query:query
//               update:^(PFObject *o) {
//
//                   PFUser* parseUser = o[@"user"];
//                   NSString* userEntityID = parseUser.objectId;
//                   NSNumber* deleted = o[bDeletedKey]; // ???
//
//                   if(deleted) {
//                       // Update the thread
//                       CCUserWrapper * user = [CCUserWrapper userWithEntityID:userEntityID];
//                       if (_model.type.intValue ^ bThreadType1to1) {
//                           [_model removeUser:user.model];
//                           [[NSNotificationCenter defaultCenter] postNotificationName:bNotificationThreadUsersUpdated object:Nil];
//                       }
//                   }
//               }];
//    }
}

-(void) usersOff {
    [((NSManagedObject *)_model) setPath:bUsersPath on:NO];
    for(id<PUser> user in _model.users) {
        //[[CCUserWrapper userWithModel:user.model] off];
    }
    
    [self removeQueryObserver:@"thread_users_change"];
    [self removeQueryObserver:@"thread_users_update"];
}

-(RXPromise *) pushLastMessage: (NSString *) messageId threadId:(NSString*)threadId {
    RXPromise * promise = [RXPromise new];
    
    
    PFObject *thread = [PFObject objectWithoutDataWithClassName:@"Thread" objectId:threadId];
    [thread fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object != nil) {
            
            thread[@"lastMessage"] = [PFObject objectWithoutDataWithClassName:@"Message" objectId:messageId];
            [thread saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [promise resolveWithResult:Nil];
                }
                else {
                    [promise rejectWithReason:error];
                }
            }];
            
        } else {
            [promise rejectWithReason:error];
        }
    }];

    return promise;
}

-(RXPromise *) messagesOn {
    __weak __typeof__(self) weakSelf = self;
    
    if(BChatSDK.readReceipt) {
        [BChatSDK.readReceipt updateReadReceiptsForThread:self.model];
    }
    
    RXPromise * promise = [RXPromise new];
    
    if (((NSManagedObject *)_model).messagesOn) {
        [promise resolveWithResult:self];
        return promise;
    }
    ((NSManagedObject *)_model).messagesOn = YES;
    
    //return [self threadDeletedDate].thenOnMain(^id(NSDate * deletedDate) {
        __typeof__(self) strongSelf = weakSelf;
        
        //FIRDatabaseQuery * query = [FIRDatabaseReference threadMessagesRef:strongSelf.model.entityID];
    PFQuery* query = [PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"thread" equalTo:[PFObject objectWithoutDataWithClassName:@"Thread" objectId:strongSelf.model.entityID]];
    
        // Get the last message from the thread
        NSArray * messages = strongSelf.model.messagesOrderedByDateDesc;
        
        // Start date - the date we'll start retrieving messages
        NSDate * startDate = Nil;
        
        // If there are messages we only fetch messages since the
        // last message
        if (messages.count) {
            startDate = ((id<PMessage>)messages.firstObject).date;
        }
        
        // If thread is deleted
//        if (deletedDate) {
//            startDate = deletedDate;
//            _model.deletedDate = deletedDate;
//        }
    
        // Listen for new messages
        startDate = [startDate dateByAddingTimeInterval:1];
        
//        // Convert the start date to a Firebase timestamp
//        query = [query queryOrderedByChild:bDate];
//        if (startDate) {
//            query = [query queryStartingAtValue:[BFirebaseCoreHandler dateToTimestamp:startDate] childKey:bDate];
//        }
//
//        // Limit to 50 messages just to be safe - on a busy public thread we wouldn't want to
//        // download 50k messages!
//        query = [query queryLimitedToLast:BChatSDK.config.messageHistoryDownloadLimit];
    
    [query orderByDescending:@"updatedAt"];
    if (startDate) {
        [query whereKey:@"updatedAt" greaterThanOrEqualTo:startDate];
    }
    query.limit = BChatSDK.config.messageHistoryDownloadLimit;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            //[query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * snapshot) {
            [self observe:@"messages" query:query childChange:^(PFObject *added, PFObject *removed) {
                __typeof__(self) strongSelf = weakSelf;
                
                if (added != nil) {
                    
//                    if(BChatSDK.blocking) {
//                        if([BChatSDK.blocking isBlocked:snapshot.value[bUserFirebaseID]]) {
//                            return;
//                        }
//                    }
                    
                    [strongSelf.model setDeletedDate: Nil];
                    
                    // This gets the message if it exists and then updates it from the snapshot
                    CCMessageWrapper * message = [CCMessageWrapper messageWithParseObject:added];
                    
                    
                    BOOL newMessage = message.model.isDelivered == NO;
                    
                    // Is this a new message?
                    // When a message arrives we add it to the database
                    //newMessage = [BChatSDK.db fetchEntityWithID:snapshot.key withType:bMessageEntity] == Nil;
                    
                    // Mark the message as delivered
                    [message.model setDelivered: @YES];
                    
                    // Add the message to this thread;
                    [strongSelf.model addMessage:message.model];
                    
                    [BChatSDK.core save];
                    
                    if (newMessage) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [BHookNotification notificationMessageReceived: message.model];
                        });
                    }
                    
                    // Mark the message as received
                    [message markAsReceived];
                    
                    if(BChatSDK.readReceipt) {
                        [BChatSDK.readReceipt updateReadReceiptsForThread:self.model];
                    }
                    
                    [promise resolveWithResult:self];
                }
                else {
                    [promise rejectWithReason:Nil];
                }
            }];
        });
    

    query = [PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"thread" equalTo:[PFObject objectWithoutDataWithClassName:@"Thread" objectId:strongSelf.model.entityID]];
    [query orderByDescending:@"updatedAt"];
    // Only add deletion handlers to the last 100 messages
    query.limit = BChatSDK.config.messageDeletionListenerLimit;
    
        [self observe:@"messages2" query:query childChange:^(PFObject *added, PFObject *removed) {
            __typeof__(self) strongSelf = weakSelf;
            if (removed != nil) {
                NSLog(@"Message deleted: %@", removed.objectId);
                CCMessageWrapper * wrapper = [CCMessageWrapper messageWithParseObject:removed];
                id<PMessage> message = wrapper.model;
                [BHookNotification notificationMessageWillBeDeleted: message];
                [strongSelf.model removeMessage: message];
                [BHookNotification notificationMessageWasDeleted];
            }
        }];
    
        return promise;
}

-(void) messagesOff {
    
    ((NSManagedObject *)_model).messagesOn = NO;
    
    [self removeQueryObserver:@"messages"];
    [self removeQueryObserver:@"messages2"];
}

@end
