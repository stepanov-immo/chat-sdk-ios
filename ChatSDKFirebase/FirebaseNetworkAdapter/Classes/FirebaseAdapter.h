//
//  FirebaseAdapter.h
//  Pods
//
//  Created by Benjamin Smiley-andrews on 13/11/2016.
//
//

#ifndef ChatFirebaseAdapter_h
#define ChatFirebaseAdapter_h

#import <ChatSDK/Core.h>
//#import <Parse/Parse.h>
//#import <ParseLiveQuery-Swift.h>


//#import <Firebase/Firebase.h>
typedef void (^FIRAuthTokenCallback)(NSString *_Nullable token, NSError *_Nullable error);
@protocol FIRUserInfo <NSObject>
@property(nonatomic, copy, readonly) NSString *providerID;
@property(nonatomic, copy, readonly) NSString *uid;
@property(nonatomic, copy, readonly, nullable) NSString *displayName;
@property(nonatomic, copy, readonly, nullable) NSURL *photoURL;
@property(nonatomic, copy, readonly, nullable) NSString *email;
@property(nonatomic, readonly, nullable) NSString *phoneNumber;
@end

@interface FIRUser : NSObject <FIRUserInfo>
@property(nonatomic, copy, readonly) NSString *uid;
@property(nonatomic, readonly, nonnull) NSArray<id<FIRUserInfo>> *providerData;
- (void)getIDTokenWithCompletion:(nullable FIRAuthTokenCallback)completion;
@end

@interface FIRAuthDataResult : NSObject
@property(nonatomic, readonly) FIRUser *user;
//@property(nonatomic, readonly, nullable) FIRAdditionalUserInfo *additionalUserInfo;
@end

typedef void (^FIRAuthDataResultCallback)(FIRAuthDataResult *_Nullable authResult,
                                          NSError *_Nullable error)
NS_SWIFT_NAME(AuthDataResultCallback);

@interface FIRAuthCredential : NSObject
@property(nonatomic, copy, readonly) NSString *provider;
@end

@interface FIRAuth : NSObject
+ (FIRAuth *)auth NS_SWIFT_NAME(auth());
@property(nonatomic, strong, readonly, nullable) FIRUser *currentUser;
- (void)signInWithEmail:(NSString *)email
               password:(NSString *)password
             completion:(nullable FIRAuthDataResultCallback)completion;
- (void)signInAnonymouslyWithCompletion:(nullable FIRAuthDataResultCallback)completion;
- (void)signInWithCustomToken:(NSString *)token
                   completion:(nullable FIRAuthDataResultCallback)completion;
//- (void)signInAndRetrieveDataWithCredential:(FIRAuthCredential *)credential
//                                 completion:(nullable FIRAuthDataResultCallback)completion;
- (BOOL)signOut:(NSError *_Nullable *_Nullable)error;
@end

@class FIRDatabaseReference;

typedef NS_ENUM(NSInteger, FIRDataEventType) {
    /// A new child node is added to a location.
    FIRDataEventTypeChildAdded,
    /// A child node is removed from a location.
    FIRDataEventTypeChildRemoved,
    /// A child node at a location changes.
    FIRDataEventTypeChildChanged,
    /// A child node moves relative to the other child nodes at a location.
    FIRDataEventTypeChildMoved,
    /// Any data changes at a location or, recursively, at any child node.
    FIRDataEventTypeValue
} NS_SWIFT_NAME(DataEventType);

typedef NSUInteger FIRDatabaseHandle NS_SWIFT_NAME(DatabaseHandle);

@interface FIRServerValue : NSObject
+ (NSDictionary *) timestamp;
@end

@interface FIRDataSnapshot : NSObject
- (FIRDataSnapshot *)childSnapshotForPath:(NSString *)childPathString;
@property (strong, readonly, nonatomic, nullable) id value;
@property (nonatomic, readonly, strong) FIRDatabaseReference * ref;
@property (strong, readonly, nonatomic) NSString* key;
@end

@interface FIRDatabaseQuery : NSObject
- (FIRDatabaseHandle)observeEventType:(FIRDataEventType)eventType withBlock:(void (^)(FIRDataSnapshot *snapshot))block;
- (FIRDatabaseQuery *)queryOrderedByChild:(NSString *)key;
- (FIRDatabaseQuery *)queryStartingAtValue:(nullable id)startValue;
- (FIRDatabaseQuery *)queryStartingAtValue:(nullable id)startValue childKey:(nullable NSString *)childKey;
- (FIRDatabaseQuery *)queryEndingAtValue:(nullable id)endValue childKey:(nullable NSString *)childKey;
- (FIRDatabaseQuery *)queryLimitedToFirst:(NSUInteger)limit;
- (FIRDatabaseQuery *)queryLimitedToLast:(NSUInteger)limit;
- (void)observeSingleEventOfType:(FIRDataEventType)eventType withBlock:(void (^)(FIRDataSnapshot *snapshot))block;
@end

@interface FIRDatabaseReference : FIRDatabaseQuery
+ (void) goOffline;
+ (void) goOnline;
- (FIRDatabaseReference *) childByAutoId;
- (FIRDatabaseReference *)child:(NSString *)pathString;
- (void) removeValue;
- (void) setValue:(nullable id)value;
- (void) setValue:(nullable id)value withCompletionBlock:(void (^)(NSError *__nullable error, FIRDatabaseReference * ref))block;
- (void) setValue:(nullable id)value andPriority:(nullable id)priority withCompletionBlock:(void (^)(NSError *__nullable error, FIRDatabaseReference * ref))block;
- (void) removeValueWithCompletionBlock:(void (^)(NSError *__nullable error, FIRDatabaseReference * ref))block;
- (void) updateChildValues:(NSDictionary *)values;
- (void) updateChildValues:(NSDictionary *)values withCompletionBlock:(void (^)(NSError *__nullable error, FIRDatabaseReference * ref))block;
- (FIRDatabaseHandle)observeEventType:(FIRDataEventType)eventType withBlock:(void (^)(FIRDataSnapshot *snapshot))block;
- (void)observeSingleEventOfType:(FIRDataEventType)eventType withBlock:(void (^)(FIRDataSnapshot *snapshot))block;
- (void) removeAllObservers;
- (void) removeObserverWithHandle:(FIRDatabaseHandle)handle;
- (void) onDisconnectSetValue:(nullable id)value;
- (void) onDisconnectRemoveValue;
- (FIRDatabaseQuery *)queryOrderedByChild:(NSString *)key;
@property (strong, readonly, nonatomic, nullable) FIRDatabaseReference * parent;
@property (strong, readonly, nonatomic, nullable) NSString* key;
@end

@interface FIRDatabase : NSObject
+ (FIRDatabase *) database;
- (FIRDatabaseReference *) reference;
@end


#import "NSManagedObject+Status.h"

#import "CCThreadWrapper.h"
#import "CCUserWrapper.h"
#import "CCMessageWrapper.h"
#import "BFirebaseEventHandler.h"
#import "BFirebaseUsersHandler.h"
#import "BEntity.h"

#import "Firebase+Paths.h"

#import "BFirebaseNetworkAdapter.h"

#import "BFirebaseCoreHandler.h"
#import "BFirebaseAuthenticationHandler.h"
#import "BFirebaseSearchHandler.h"
#import "BFirebaseModerationHandler.h"
#import "BFirebasePublicThreadHandler.h"
#import "BFirebaseUsersHandler.h"
#import "BFirebaseContactHandler.h"

#endif /* ChatFirebaseAdapter_h */
