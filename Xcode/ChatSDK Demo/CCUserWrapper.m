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

-(NSString *) entityID {
    return _model.entityID;
}

-(id<PUser>) model {
    return _model;
}

@end
