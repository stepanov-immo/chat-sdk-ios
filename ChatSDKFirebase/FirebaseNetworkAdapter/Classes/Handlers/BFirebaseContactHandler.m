//
//  BFirebaseContactHandler.m
//  AFNetworking
//
//  Created by Benjamin Smiley-andrews on 08/02/2019.
//

#import "BFirebaseContactHandler.h"
#import "FirebaseAdapter.h"
#import "ParseAdapter.h"

@implementation BFirebaseContactHandler

-(RXPromise *) addContact: (id<PUser>) contact withType: (bUserConnectionType) type {
    RXPromise * promise = [RXPromise new];
    
    PFObject* c = [PFObject objectWithoutDataWithClassName:@"MyUser" objectId:contact.entityID];
    PFQuery* query = [[PFQuery userContacts:BChatSDK.currentUserID] whereKey:@"contact" equalTo:c];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject* object, NSError* error) {
        if (object != nil) {
            object[bType] = @(type);
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    [promise resolveWithResult: Nil];
                } else {
                    [promise rejectWithReason:error];
                }
            }];
        } else {
            [promise rejectWithReason:error];
        }
    }];
    
    return promise;
}

/**
 * @brief Remove a contact locally and on the server if necessary
 */
-(RXPromise *) deleteContact: (id<PUser>) contact withType:(bUserConnectionType)type {
    RXPromise * promise = [RXPromise new];
    
    PFObject* c = [PFObject objectWithoutDataWithClassName:@"MyUser" objectId:contact.entityID];
    PFQuery* query = [[PFQuery userContacts:BChatSDK.currentUserID] whereKey:@"contact" equalTo:c];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject* object, NSError* error) {
        if (object != nil) {
            [object removeObjectForKey:bType];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    [promise resolveWithResult: Nil];
                } else {
                    [promise rejectWithReason:error];
                }
            }];
        } else {
            [promise rejectWithReason:error];
        }
    }];
    
    return promise;
}

@end
