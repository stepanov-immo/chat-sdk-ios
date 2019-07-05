//
//  ParseEventHandler.h
//  ChatSDK Demo
//
//  Created by Alexander Stepanov on 05/07/2019.
//  Copyright © 2019 deluge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ChatSDK/PEventHandler.h>

@protocol PUser;

@interface ParseEventHandler : NSObject<PEventHandler>

-(void) contactsOn: (id<PUser>) user;
-(void) contactsOff: (id<PUser>) user;

@end
