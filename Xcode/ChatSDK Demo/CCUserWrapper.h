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

- (instancetype)initWithAuthUserData:(PFUser *) user;
- (instancetype)initWithModel: (id<PUser>) user;

-(RXPromise *) onlineOn; // include metaOn
-(void) onlineOff;

@end
