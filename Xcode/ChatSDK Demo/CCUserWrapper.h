//
//  CCUserWrapper.h
//  ChatSDK Demo
//
//  Created by Alexander Stepanov on 04/07/2019.
//  Copyright © 2019 deluge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ChatSDK/PUserWrapper.h>

@class PFUser;

@interface CCUserWrapper : NSObject<PUserWrapper>

+(CCUserWrapper *) userWithModel: (id<PUser>) user;
+(CCUserWrapper *) userWithAuthUserData: (PFUser *) user;
//+(CCUserWrapper *) userWithEntityID: (NSString *) entityID;

-(RXPromise *) onlineOn; // include metaOn
-(void) onlineOff;

@end
