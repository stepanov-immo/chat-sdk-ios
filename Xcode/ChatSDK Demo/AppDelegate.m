//
//  AppDelegate.m
//  ChatSDK Demo
//
//  Created by Benjamin Smiley-andrews on 19/12/2016.
//  Copyright © 2016 deluge. All rights reserved.
//

#import "AppDelegate.h"
#import <ChatSDK/UI.h>
#import <Parse/Parse.h>
#import <ParseLiveQuery-Swift.h>

#import "ParseAdapter.h"

@interface AppDelegate ()
@property (nonatomic, strong) PFQuery *query;
@property (nonatomic, strong) PFLiveQuerySubscription *subscription1;
@property (nonatomic, strong) PFLiveQuerySubscription *subscription2;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"com.mdcm.testchatsdk";
        configuration.clientKey = @"";
        configuration.server = @"http://localhost:1337/parse";
        //configuration.server = @"http://10.192.160.10:1337/parse";
    }]];

//    [[PFQuery queryWithClassName:@"MyUser"] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//        NSLog(@"%@", objects);
//
//        PFObject *myUser = [PFObject objectWithClassName:@"MyUser"];
//        myUser[@"name"] = @"my user2";
//        [myUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//            NSLog(@"error %@", error);
//
//            [[PFQuery queryWithClassName:@"MyUser"] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//                NSLog(@"%@", objects);
//            }];
//
//        }];
//    }];

//    PFObject *myUser = [PFObject objectWithClassName:@"MyUser"];
//    myUser[@"name"] = @"my user3";
//    //NSString* objId = myUser.objectId;
//    [myUser saveEventually];
//    //[myUser pinInBackground];
//
//    {
//        PFObject *userContact = [PFObject objectWithClassName:@"UserContact"];
//        userContact[@"type"] = @"0";
//        userContact[@"user"] = myUser;
//        [userContact saveEventually];
//        id user = userContact[@"user"];
//        NSLog(@"%@", user);
//    }
    
//    PFObject *gameScore = [PFObject objectWithClassName:@"GameScore"];
//    gameScore[@"playerName"] = @"test1";
//    [gameScore saveEventually];
    
    
    [self observe:@"user_thread" query:[PFQuery userThreads:@"7PwzQJNvxU"] childChange:^(PFObject *added, PFObject *removed) {
        if (added != nil) {
            NSLog(@"child add %@", added);
        }
        if (removed != nil) {
            NSLog(@"child remove %@", removed);
        }
    }];

    [self observe:@"user" query:[PFQuery userThreads:@"7PwzQJNvxU"] update:^(PFObject *o) {
        NSLog(@"update %@", o);
    }];

//    PFQuery *query = [PFQuery queryWithClassName:@"GameScore"];
//    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
//    [query getObjectInBackgroundWithId:@"9WJChaGT60" block:^(PFObject *gameScore, NSError *error) {
//        // Do something with the returned PFObject in the gameScore variable.
//        NSLog(@"%@", gameScore);
//        gameScore[@"score"] = @9999;
//        [gameScore saveEventually];
//    }];
    
    // Create a network adapter to communicate with Firebase
    // The network adapter handles network traffic

    BConfiguration * config = [BConfiguration configuration];
    config.rootPath = @"19_05_v1";
    config.allowUsersToCreatePublicChats = NO;
    //config.showEmptyChats = NO;
    config.googleMapsApiKey = @"AIzaSyCwwtZrlY9Rl8paM0R6iDNBEit_iexQ1aE";
    config.clearDataWhenRootPathChanges = YES;
    config.loginUsernamePlaceholder = @"Email";
    config.allowUsersToCreatePublicChats = YES;
    
    // For the demo version of the client exire rooms after 24 hours
    config.publicChatRoomLifetimeMinutes = 60 * 24;
    
    // Twitter Setup
    config.twitterApiKey = @"Kqprq5b6bVeEfcMAGoHzUmB3I";
    config.twitterSecret = @"hPd9HCt3PLnifQFrGHJWi6pSZ5jF7kcHKXuoqB8GJpSDAlVcLq";
    
    // Facebook Setup
    config.facebookAppId = @"648056098576150";
    
    // Google Setup
    config.googleClientKey = @"1088435112418-4cm46hg39okkf0skj2h5roj1q62anmec.apps.googleusercontent.com";
    
    [BChatSDK initialize:config app:application options:launchOptions];
    
    // TODO: Fix Firebase UI!!!!!!!
    UIViewController * rootViewController = BChatSDK.ui.splashScreenNavigationController;
    
    [self.window setRootViewController:rootViewController];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [BChatSDK application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

-(BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [BChatSDK application: app openURL: url options: options];
}

-(void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [BChatSDK application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [BChatSDK application:application didReceiveRemoteNotification:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

@end
