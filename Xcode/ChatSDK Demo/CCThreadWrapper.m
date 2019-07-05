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

@end
