//
//  PFQuery+Paths.m
//  ChatSDK Demo
//
//  Created by Alexander Stepanov on 03/07/2019.
//  Copyright © 2019 deluge. All rights reserved.
//

#import "PFQuery+Paths.h"
#import <Parse/Parse.h>
#import <ParseLiveQuery-Swift.h>

@implementation PFQuery (Paths)

+(PFQuery *)users {
    PFQuery *query = [PFQuery queryWithClassName:@"MyUser"];
    return [query whereKeyExists:@"name"];
}

+(PFQuery *)user:(NSString *)userId {
    PFQuery *query = [PFQuery queryWithClassName:@"MyUser"];
    return [query whereKey:@"objectId" equalTo:userId];
}

+(PFQuery *)userThread:(NSString *)userId {
    PFQuery *query = [PFQuery queryWithClassName:@"UserThread"];
    return [query whereKey:@"user" equalTo:[PFObject objectWithoutDataWithClassName:@"MyUser" objectId:userId]];
}

+(PFQuery *)userContacts:(NSString *)userId {
    PFQuery *query = [PFQuery queryWithClassName:@"UserContact"];
    return [query whereKey:@"user" equalTo:[PFObject objectWithoutDataWithClassName:@"MyUser" objectId:userId]];
}

+(PFQuery *)threadUsers:(NSString *)threadId {
    PFQuery *query = [PFQuery queryWithClassName:@"UserThread"];
    return [query whereKey:@"thread" equalTo:[PFObject objectWithoutDataWithClassName:@"Thread" objectId:threadId]];
}
@end
