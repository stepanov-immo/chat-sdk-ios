//
//  ParseContactHandler.m
//  ChatSDK Demo
//
//  Created by Alexander Stepanov on 05/07/2019.
//  Copyright © 2019 deluge. All rights reserved.
//

#import "ParseContactHandler.h"
#import <Parse/Parse.h>
#import <ChatSDK/Core.h>

@implementation ParseContactHandler

-(RXPromise *) addContact: (id<PUser>) contact withType: (bUserConnectionType) type {
    RXPromise * promise = [RXPromise new];
    
    PFObject* userContact = [PFObject objectWithClassName:@"UserContact"];
    userContact[@"user"] = [PFUser objectWithoutDataWithObjectId:BChatSDK.currentUserID];
    userContact[@"contact"] = [PFUser objectWithoutDataWithObjectId:contact.entityID];
    userContact[bType] = @(type);
    [userContact saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            [promise resolveWithResult: Nil];
        } else {
            [promise rejectWithReason:error];
        }
    }];
    
    return promise;
}

@end
