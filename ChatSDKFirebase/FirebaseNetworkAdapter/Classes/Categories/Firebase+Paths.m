//
//  Firebase+Paths2.m
//  Chat SDK
//
//  Created by Benjamin Smiley-andrews on 13/03/2014.
//  Copyright (c) 2014 deluge. All rights reserved.
//

#import "Firebase+Paths.h"

#import "FirebaseAdapter.h"


@implementation FIRUser
-(void)getIDTokenWithCompletion:(FIRAuthTokenCallback)completion {
    completion(@"123", nil);
}
-(NSString *)uid { return @"abc"; }
@end
@implementation FIRAuthDataResult
-(FIRUser *)user { return [FIRUser new]; }
@end
@implementation FIRAuthCredential
@end
@implementation FIRAuth
+(FIRAuth *)auth { return [FIRAuth new]; }
-(FIRUser *)currentUser { return [FIRUser new]; }
-(void)signInWithEmail:(NSString *)email password:(NSString *)password completion:(FIRAuthDataResultCallback)completion {
    completion([FIRAuthDataResult new], nil);
}
@end

@implementation FIRServerValue
+(NSNumber *)timestamp { return @([[NSDate date] timeIntervalSince1970] * 1000); }
@end
@implementation FIRDataSnapshot
-(NSString *)key { return @"key1"; }
-(id)value { return @{@"type_v4": @(51)}; }
@end
@implementation FIRDatabaseQuery
-(FIRDatabaseQuery *)queryOrderedByChild:(NSString *)key {
    NSLog(@"query ordered by child, key %@", key);
    return self;
}
-(FIRDatabaseQuery *)queryStartingAtValue:(id)startValue {
    NSLog(@"query starting at value %@", startValue);
    return self;
}
-(FIRDatabaseQuery *)queryEndingAtValue:(id)endValue childKey:(NSString *)childKey {
    NSLog(@"query ending at value %@", endValue);
    return self;
}
-(FIRDatabaseQuery *)queryLimitedToLast:(NSUInteger)limit {
    NSLog(@"query limited to last %@", @(limit));
    return self;
}
@end
@implementation FIRDatabaseReference
{
    NSString* _path;
}
+(void)goOnline { NSLog(@"goOnline"); }
+(void)goOffline { NSLog(@"goOffline"); }
-(FIRDatabaseReference *)child:(NSString *)pathString {
    NSLog(@"[%@] child %@", self->_path, pathString);
    FIRDatabaseReference* ref = [FIRDatabaseReference new];
    ref->_path = [NSString stringWithFormat:@"%@/%@", (_path ?: @""), pathString];
    return ref;
}
-(NSString *)description { return @"fb_ref_path"; }
-(void)setValue:(id)value { NSLog(@"[%@] set value %@", self->_path, value); }
-(void)onDisconnectSetValue:(id)value {}
-(void)onDisconnectRemoveValue {}
-(FIRDatabaseHandle)observeEventType:(FIRDataEventType)eventType withBlock:(void (^)(FIRDataSnapshot *))block {
    NSLog(@"[%@] observe type %@", self->_path, @(eventType));
    if ([_path hasSuffix:@"/threads"] && eventType == FIRDataEventTypeChildAdded) {
        FIRDataSnapshot* s = [FIRDataSnapshot new];
        block(s);
    }
    if ([_path hasSuffix:@"/threads/key1/details"] && eventType == FIRDataEventTypeValue) {
        FIRDataSnapshot* s = [FIRDataSnapshot new];
        block(s);
    }
    return 0;
}
-(void)observeSingleEventOfType:(FIRDataEventType)eventType withBlock:(void (^)(FIRDataSnapshot *))block {
    NSLog(@"[%@] observe single type %@", self->_path, @(eventType));
}
-(void)updateChildValues:(NSDictionary *)values withCompletionBlock:(void (^)(NSError * _Nullable, FIRDatabaseReference *))block {
    NSLog(@"[%@] update child %@", self->_path, values);
}
-(void)removeValueWithCompletionBlock:(void (^)(NSError * _Nullable, FIRDatabaseReference *))block {}
@end
@implementation FIRDatabase
+(FIRDatabase *)database {
    return [FIRDatabase new];
}
-(FIRDatabaseReference *)reference {
    return [FIRDatabaseReference new];
}
@end


@implementation FIRDatabaseReference (Paths)

+(FIRDatabaseReference *) firebaseRef {
    return [[[FIRDatabase database] reference] c: BChatSDK.config.rootPath];
}

-(FIRDatabaseReference *) c: (NSString *) component {
    return [self child:component];
}

#pragma Users

// users
+(FIRDatabaseReference *) usersRef {
    return [[self firebaseRef] child:bUsersPath];
}

// users/[user id]
+(FIRDatabaseReference *) userRef: (NSString *) firebaseID {
    return [[self usersRef] child:firebaseID];
}

+(FIRDatabaseReference *) userMetaRef: (NSString *) firebaseID {
    return [[[self usersRef] child:firebaseID] child:bMetaPath];
}

+(FIRDatabaseReference *) userThreadsRef: (NSString *) firebaseID {
    return [[self userRef:firebaseID] child:bThreadsPath];
}

+(FIRDatabaseReference *) userContactsRef: (NSString *) firebaseID {
    return [[self userRef:firebaseID] child:bContactsPath];
}

+(FIRDatabaseReference *) userOnlineRef: (NSString *) firebaseID {
    return [[self userRef: firebaseID] child:bOnlinePath];
}

+(FIRDatabaseReference *) onlineRef: (NSString *) firebaseID {
    return [[[self firebaseRef] child:bOnlinePath] child:firebaseID];
}

#pragma Flag ref

+(FIRDatabaseReference *) flaggedMessagesRef {
    return [[self.firebaseRef c:bFlaggedKey] c:bMessagesPath];
}

+(FIRDatabaseReference *) flaggedRefWithMessage: (NSString *) messageID {
    return [[self flaggedMessagesRef] c:messageID];
}

#pragma Messages / Threads

+(FIRDatabaseReference *) threadsRef {
    return [[self firebaseRef] child:bThreadsPath];
}

+(FIRDatabaseReference *) threadRef: (NSString *) firebaseID {
    return [[self threadsRef] child:firebaseID];
}

+(FIRDatabaseReference *) threadLastMessageRef: (NSString *) firebaseID {
    return [[[self threadsRef] child:firebaseID] child:bLastMessage];;
}

+(FIRDatabaseReference *) threadUsersRef: (NSString *) firebaseID {
    return [[[self threadsRef] child:firebaseID] child:bUsersPath];
}

+(FIRDatabaseReference *) threadMessagesRef: (NSString *) firebaseID  {
    return [[self threadRef:firebaseID] child:bMessagesPath];
}

+(FIRDatabaseReference *) publicThreadsRef {
    return [[self firebaseRef] child:bPublicThreadsPath];
}

+(FIRDatabaseReference *) threadTypingRef: (NSString *) firebaseID {
    return [[self threadRef:firebaseID] child:bTypingPath];
}

+(FIRDatabaseReference *) threadMetaRef: (NSString *) firebaseID {
    return [[self threadRef:firebaseID] child:bMetaPath];
}

+(FIRDatabaseReference *) thread: (NSString *) threadID messageRef: (NSString *) messageID {
    return [[self threadMessagesRef:threadID] child:messageID];
}

+(FIRDatabaseReference *) thread: (NSString *) threadID messageReadRef: (NSString *) messageID {
    return [[self thread:threadID messageRef:messageID] child:bReadPath];
}


@end
