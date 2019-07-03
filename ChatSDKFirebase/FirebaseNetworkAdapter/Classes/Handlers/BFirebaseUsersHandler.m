//
//  BFirebaseUserHandler.m
//  Pods
//
//  Created by Benjamin Smiley-andrews on 13/07/2017.
//
//

#import "BFirebaseUsersHandler.h"

#import "FirebaseAdapter.h"
#import "ParseAdapter.h"

@implementation BFirebaseUsersHandler

@synthesize allUsers;

-(instancetype) init {
    if((self = [super init])) {
        allUsers = [NSMutableArray new];
    }
    return self;
}

-(void) allUsersOn {
    if(!_allUsersOn) {
        _allUsersOn = YES;
        
        [self observe:@"users_change" query:[PFQuery users] childChange:^(PFObject *added, PFObject *removed) {
            if(added != nil) {
                id<PUser> user = [CCUserWrapper userWithPFObject:added].model;
                if(user && ![allUsers containsObject:user]) {
                    [allUsers addObject:user];
                    [[NSNotificationCenter defaultCenter] postNotificationName:bNotificationUserUpdated object:Nil userInfo:@{bNotificationUserUpdated_PUser: user}];
                }
            }
            
            if(removed != nil) {
                id<PUser> user = [CCUserWrapper userWithPFObject:removed].model;
                if(user && [allUsers containsObject:user]) {
                    [allUsers removeObject:user];
                    [[NSNotificationCenter defaultCenter] postNotificationName:bNotificationUserUpdated object:Nil userInfo:@{bNotificationUserUpdated_PUser: user}];
                }
            }
        }];
        
        [self observe:@"users_update" query:[PFQuery users] update:^(PFObject *o) {
            [CCUserWrapper userWithPFObject:o];
        }];        
    }
}

-(void) allUsersOff {
    //[[FIRDatabaseReference usersRef] removeAllObservers];
    [self removeQueryObserver:@"users_change"];
    [self removeQueryObserver:@"users_update"];
    _allUsersOn = NO;
}

@end
