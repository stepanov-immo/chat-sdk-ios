//
//  ParseSearchHandler.m
//  ChatSDK Demo
//
//  Created by Alexander Stepanov on 05/07/2019.
//  Copyright © 2019 deluge. All rights reserved.
//

#import "ParseSearchHandler.h"
#import <Parse/Parse.h>
#import <ChatSDK/Core.h>
#import "CCUserWrapper.h"

@implementation ParseSearchHandler

-(RXPromise *) usersForIndex: (NSString *) index withValue: (NSString *) value limit: (int) limit userAdded: (void(^)(id<PUser> user)) userAdded {
    
    RXPromise * promise = [RXPromise new];
    
    if ([index isEqual:bUserNameLowercase]) {
        value = [value lowercaseString];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if(!index || !index.length || !value || !value.length) {
            // TODO: Localise this
            [promise rejectWithReason:[NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Index or value is blank"}]];
        }
        else {
            
            [[PFUser query] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if (objects != nil) {
                    for (PFUser* user in objects) {
                        CCUserWrapper * wrapper = [[CCUserWrapper alloc]initWithAuthUserData:user];
                        if(![wrapper.model isEqual:BChatSDK.currentUser]) {
                            userAdded(wrapper.model);
                        }
                    }
                }
                [promise resolveWithResult:Nil];
            }];
            
//            NSString * childPath = [NSString stringWithFormat:@"%@/%@", bMetaPath, index];
//            FIRDatabaseQuery * query = [[FIRDatabaseReference usersRef] queryOrderedByChild: childPath];
//            query = [query queryStartingAtValue:value];
//            query = [query queryLimitedToFirst:limit];
//
//            [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * snapshot) {
//                if(snapshot.value != [NSNull null]) {
//                    for(NSString * key in [snapshot.value allKeys]) {
//                        NSDictionary * meta = snapshot.value[key][bMetaPath];
//                        if(meta && [meta[index] containsString:value]) {
//                            CCUserWrapper * wrapper = [CCUserWrapper userWithSnapshot:[snapshot childSnapshotForPath:key]];
//                            if(![wrapper.model isEqual:BChatSDK.currentUser]) {
//                                userAdded(wrapper.model);
//                            }
//                        }
//                    }
//                }
//                [promise resolveWithResult:Nil];
//            }];
        }
    });
    
    return promise;
}

-(RXPromise *) usersForIndexes: (NSArray *) indexes withValue: (NSString *) value limit: (int) limit userAdded: (void(^)(id<PUser> user)) userAdded {

    if(!indexes) {
        indexes = @[bUserNameKey, bUserEmailKey, bUserPhoneKey, bUserNameLowercase];
    }

    NSMutableArray * promises = [NSMutableArray new];
    for (NSString * index in indexes) {
        [promises addObject:[self usersForIndex:index withValue:value limit: limit userAdded:userAdded]];
    }

    // Return null when all the promises finish
    return [RXPromise all:promises].thenOnMain(^id(id success) {
        return Nil;
    }, Nil);
}
//
//-(NSString *) processForQuery: (NSString *) string {
//    return [[string stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
//}
//
-(RXPromise *) availableIndexes {
    return [RXPromise resolveWithResult:Nil];
}

@end
