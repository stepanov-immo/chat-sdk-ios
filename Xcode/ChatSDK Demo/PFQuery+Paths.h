//
//  PFQuery+Paths.h
//  ChatSDK Demo
//
//  Created by Alexander Stepanov on 03/07/2019.
//  Copyright © 2019 deluge. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFQuery (Paths)

+(PFQuery*)online:(NSString*)userId;

+(PFQuery*)users;
+(PFQuery*)user:(NSString*)userId;
+(PFQuery*)userThreads:(NSString*)userId;
+(PFQuery*)userContacts:(NSString*)userId;

+(PFQuery*)threadUsers:(NSString*)threadId;

@end
