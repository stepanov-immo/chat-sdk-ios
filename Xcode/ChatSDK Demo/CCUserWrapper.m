//
//  CCUserWrapper.m
//  ChatSDK Demo
//
//  Created by Alexander Stepanov on 04/07/2019.
//  Copyright © 2019 deluge. All rights reserved.
//

#import "CCUserWrapper.h"
#import <Parse/Parse.h>
#import <ChatSDK/Core.h>
#import "NSManagedObject+Status.h"
#import "NSObject+ParseHelper.h"

@implementation CCUserWrapper
{
    NSObject<PUser> * _model;
}

- (instancetype)initWithAuthUserData:(PFUser *) user
{
    self = [super init];
    if (self) {
        // Get the model from the database if it exists
        _model = [BChatSDK.db fetchOrCreateEntityWithID:user.objectId withType:bUserEntity];
        
        //[self updateUserFromAuthUserData:data];
        _model.name = user.username ?: BChatSDK.shared.configuration.defaultUserName;
        _model.email = user.email;
    }
    return self;
}

- (instancetype)initWithModel:(id<PUser>)user
{
    self = [super init];
    if (self) {
        _model = user;
    }
    return self;
}

-(NSString *) entityID {
    return _model.entityID;
}

-(id<PUser>) model {
    return _model;
}

-(RXPromise *) onlineOn {
    RXPromise * promise = [RXPromise new];
    
    if (((NSManagedObject *)_model).onlineOn) {
        [promise resolveWithResult:Nil];
        return promise;
    }
    ((NSManagedObject *)_model).onlineOn = YES;
    
    
    PFQuery *query = [[PFUser query] whereKey:@"objectId" equalTo:self.entityID];
    [self observe:@"user"
            query:query
           update:^(PFObject *o) {
               if(o != nil) {
                   self.model.online = o[bOnlinePath];
                   // meta
                   self.model.name = o[@"username"] ?: BChatSDK.shared.configuration.defaultUserName;
                   self.model.email = o[@"email"];
               }
               else {
                   self.model.online = @NO;
               }
               [[NSNotificationCenter defaultCenter] postNotificationName:bNotificationUserUpdated
                                                                   object:Nil
                                                                 userInfo:@{bNotificationUserUpdated_PUser: self.model}];
           }];
    
    return promise;
}

-(void) onlineOff {
    ((NSManagedObject *)_model).onlineOn = NO;
    [self removeQueryObserver:@"user"];
}

@end
