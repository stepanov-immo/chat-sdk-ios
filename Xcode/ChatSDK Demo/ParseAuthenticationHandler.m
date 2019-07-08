//
//  ParseAuthenticationHandler.m
//  ChatSDK Demo
//
//  Created by Alexander Stepanov on 04/07/2019.
//  Copyright © 2019 deluge. All rights reserved.
//

#import "ParseAuthenticationHandler.h"
#import <Parse/Parse.h>
#import <ChatSDK/Core.h>
#import "CCUserWrapper.h"
#import <ChatSDK/PEventHandler.h>

@implementation ParseAuthenticationHandler
{
    BOOL _isAuthenticatedThisSession;
}

-(BOOL)isAuthenticated {
    return [PFUser currentUser] != nil;
}

//-(BOOL)isAuthenticatedThisSession {
//    return YES;
//}

-(RXPromise *)authenticate {
    [BChatSDK.core goOnline];

    BOOL authenticated = [self isAuthenticated];
    if (authenticated) {

        // If the user listeners have been added then authenticate completed successfully
        if(_isAuthenticatedThisSession) {
            return [RXPromise resolveWithResult:BChatSDK.currentUser];
        }
        else {
            return [self loginWithUser:[PFUser currentUser] details:nil];
        }
    }
    else {
        return [RXPromise rejectWithReason:Nil];
    }
}

-(RXPromise *)authenticate:(BAccountDetails *)details {
    [BChatSDK.core goOnline];
    
    RXPromise * promise = [RXPromise new];
    
    // Create a completion block to handle the login result
    void(^handleResult)(PFUser *user, NSError * error) = ^(PFUser *user, NSError * error) {
        if (!error) {
            [promise resolveWithResult:user];
        }
        else {
            [promise rejectWithReason:error];
        }
    };
    
    promise = promise.thenOnMain(^id(PFUser *user) {
        return [self loginWithUser:user details:details];
    }, Nil);
    
    // Depending on the login method we need to authenticate with Firebase
    if (details.type == bAccountTypeRegister) {
        // sign up
        PFUser *user = [PFUser user];
        user.username = details.username;
        user.password = details.password;
        //user.email = @"email@example.com";
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            handleResult(user, error);
        }];
    }
    
    if (details.type == bAccountTypeUsername) {
        // sign in
        [PFUser logInWithUsernameInBackground:details.username password:details.password
                                        block:^(PFUser *user, NSError *error) {
                                            handleResult(user, error);
                                        }];
    }
    
    return promise;
}

-(RXPromise *)loginWithUser:(PFUser*)parseUser details:(BAccountDetails *)details {
    
    // If the user isn't authenticated they'll need to login
    if (!parseUser) {
        return [RXPromise resolveWithResult:Nil];
    }
    
    
    // Get the token
    RXPromise * tokenPromise = [RXPromise new];
    [PFSession getCurrentSessionInBackgroundWithBlock:^(PFSession * _Nullable session, NSError * _Nullable error) {
        if (!error) {
            [tokenPromise resolveWithResult:session.sessionToken];
        }
        else {
            [tokenPromise rejectWithReason:error];
        }
    }];
    
    __weak __typeof__(self) weakSelf = self;
    return tokenPromise.thenOnMain(^id(NSString * token) {
        __typeof__(self) strongSelf = weakSelf;
        
        NSString * uid = parseUser.objectId;
        
        // Save the authentication ID for the current user
        // Set the current user
        [strongSelf setLoginInfo:@{bAuthenticationIDKey: uid,
                                   bTokenKey: [NSString safe: token]}];
        
        CCUserWrapper * user = [CCUserWrapper userWithAuthUserData:parseUser];
        if (details.name && !user.model.name) {
            [user.model setName:details.name];
        }
        
        if (!strongSelf->_isAuthenticatedThisSession) {
            strongSelf->_isAuthenticatedThisSession = YES;
            
            // If the user was authenticated automatically
            if (!details) {
                [BHookNotification notificationDidAuthenticate:user.model type:bHook_AuthenticationTypeCached];
            }
            else if (details.type == bAccountTypeRegister) {
                [BHookNotification notificationDidAuthenticate:user.model type:bHook_AuthenticationTypeSignUp];
            }
            else {
                [BHookNotification notificationDidAuthenticate:user.model type:bHook_AuthenticationTypeLogin];
            }
            
            [BChatSDK.core save];
            
            //                NSLog(@"User On: %@", user.entityID);
            
            // Add listeners here
            [BChatSDK.event currentUserOn:user.entityID];
            
            [BChatSDK.core setUserOnline];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:bNotificationAuthenticationComplete object:Nil];
            
            strongSelf->_authenticatedThisSession = true;
            
            //= [user push];
        }
        
        return user.model;
        
    }, Nil);
    
}

-(RXPromise *) logout {
    RXPromise * promise = [RXPromise new];
    
    id<PUser> user = BChatSDK.currentUser;
    
    // Stop observing the user
    if(user) {
        [BHookNotification notificationWillLogout:user];
        [BChatSDK.event currentUserOff: user.entityID];
    }
    
    NSError * error = Nil;
    [PFUser logOut];
    
    _isAuthenticatedThisSession = NO;
    [self setLoginInfo:Nil];
    [BChatSDK.core goOffline];
    
    [[NSNotificationCenter  defaultCenter] postNotificationName:bNotificationBadgeUpdated object:Nil];
    
    if (user) {
        [BHookNotification notificationDidLogout:user];
    }
    
    [promise resolveWithResult:Nil];
    
    return promise;
}

@end
