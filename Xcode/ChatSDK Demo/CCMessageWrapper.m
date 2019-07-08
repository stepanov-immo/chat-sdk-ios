//
//  CCMessageWrapper.m
//  ChatSDK Demo
//
//  Created by Alexander Stepanov on 08/07/2019.
//  Copyright © 2019 deluge. All rights reserved.
//

#import "CCMessageWrapper.h"
#import <Parse/Parse.h>
#import <ChatSDK/Core.h>
#import "NSManagedObject+Status.h"
#import "NSObject+ParseHelper.h"
#import "CCUserWrapper.h"
#import "CCThreadWrapper.h"

@implementation CCMessageWrapper
{
    NSObject<PMessage> * _model;
}

+(id) messageWithModel: (id<PMessage>) model {
    return [[self alloc] initWithModel:model];
}

-(id) initWithModel: (id<PMessage>) model {
    if((self = [super init])) {
        _model = model;
    }
    return self;
}

+(id) messageWithParseObject:(PFObject *)object {
    return [[self alloc] initWithParseObject:object];
}

-(id) initWithParseObject:(PFObject *)object {
    if ((self = [self init])) {
        _model = [BChatSDK.db fetchOrCreateEntityWithID:object[@"entityId"] withType:bMessageEntity];
        //[self deserialize:snapshot.value];
        
        NSString* userId = [object[@"from"] objectId];
        _model.meta = @{@"text": object[@"text"]};
        _model.type = object[@"type"];
        _model.date = object.updatedAt;
        _model.userModel = [BChatSDK.db fetchEntityWithID:userId withType:bUserEntity];
        if(!_model.userModel) {
            id<PUser> user = [BChatSDK.db fetchOrCreateEntityWithID:userId withType:bUserEntity];
            _model.userModel = user;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:bNotificationMessageUpdated
                                                                object:Nil
                                                              userInfo:@{bNotificationMessageUpdatedKeyMessage: self.model}];
        }
    }
    return self;
}

-(id<PMessage>) model {
    return _model;
}

-(NSString *) entityID {
    return _model.entityID;
}

-(RXPromise *) send {
    if (_model.thread) {
        
        // Get this first so it's not decrypted then pushed
        //NSDictionary * lastMessageData = [self lastMessageData];
        
        return [self push].thenOnMain(^id(id success) {
            [[CCThreadWrapper threadWithModel:_model.thread] pushLastMessage:_model.entityID threadId:_model.thread.entityID].thenOnMain(^id(id success) {
                _model.delivered = @YES;
                //return [BEntity pushThreadMessagesUpdated:_model.thread.entityID];
                return [RXPromise resolveWithResult:Nil];
            },Nil);
            return success;
        }, Nil);
    }
    else {
        return [RXPromise rejectWithReason:Nil];
    }
}

-(RXPromise *) push {
    
    RXPromise * promise = [RXPromise new];
    
    // Add the message to Firebase
    PFObject *message = [PFObject objectWithClassName:@"Message"];
    message[@"entityId"] = _model.entityID;
    message[@"text"] = _model.meta[@"text"];
    message[@"thread"] = [PFObject objectWithoutDataWithClassName:@"Thread" objectId:_model.thread.entityID];
    message[@"from"] = [PFUser objectWithoutDataWithObjectId:_model.userModel.entityID];
    message[bType] = _model.type;
    //message[@"to"] = ...;
    // read status ???
    
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {                        
            [promise resolveWithResult:self];
        }
        else {
            _model.entityID = Nil;
            [promise rejectWithReason:error];
        }
    }];
    
    return promise;
}

-(RXPromise *) markAsReceived {
    return [self setReadStatus:bMessageReadStatusDelivered];
}

-(RXPromise *) setReadStatus: (bMessageReadStatus) status {
    
    // Don't set read status for our own messages
    if(_model.senderIsMe) {
        return [RXPromise resolveWithResult:Nil];
    }
    
    NSString * entityID = BChatSDK.currentUser.entityID;
    
    // Check to see if we've already set the status?
    bMessageReadStatus currentStatus = [_model readStatusForUserID:entityID];
    
    // If the status is the same or lower than the new status just return
    if (currentStatus >= status) {
        return [RXPromise resolveWithResult:Nil];
    }
    
    // Set the status - this prevents a race condition where
    // the message is to set to be delivered later
    [_model setReadStatus:status forUserID:entityID];
    
    // Set our status area
    RXPromise * promise = [RXPromise new];
    
    
    // todo
//    FIRDatabaseReference * ref = [FIRDatabaseReference thread:_model.thread.entityID messageReadRef:_model.entityID];
//
//    [[ref child: entityID] setValue:@{bStatus: @(status), bDate: FIRServerValue.timestamp} withCompletionBlock:^(NSError * error, FIRDatabaseReference * ref ) {
//        if (!error) {
//            [promise resolveWithResult:Nil];
//        }
//        else {
//            [promise rejectWithReason:error];
//        }
//    }];
    [promise resolveWithResult:Nil];
    
    
    return promise;
    
}


@end
