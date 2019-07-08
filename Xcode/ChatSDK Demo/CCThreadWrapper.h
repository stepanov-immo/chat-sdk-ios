//
//  CCThreadWrapper.h
//  ChatSDK Demo
//
//  Created by Alexander Stepanov on 05/07/2019.
//  Copyright © 2019 deluge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ChatSDK/PThreadWrapper.h>

@class CCUserWrapper;
@class PFObject;

@interface CCThreadWrapper : NSObject<PThreadWrapper>

+(CCThreadWrapper *) threadWithModel: (id<PThread>) model;
//+(CCThreadWrapper *) threadWithEntityID: (NSString *) entityID;
+(CCThreadWrapper *) threadWithParseObject: (PFObject *) object;

-(RXPromise *) push;

-(RXPromise *) addUser: (CCUserWrapper *) user;
-(void) usersOn;

-(RXPromise *) pushLastMessage: (NSString *) messageId threadId:(NSString*)threadId;

-(RXPromise *) messagesOn;
-(void) messagesOff;

@end

