//
//  CCMessageWrapper.h
//  ChatSDK Demo
//
//  Created by Alexander Stepanov on 08/07/2019.
//  Copyright © 2019 deluge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ChatSDK/PMessageWrapper.h>

@class CDMessage;
@class PFObject;

@interface CCMessageWrapper : NSObject<PMessageWrapper>

+(id) messageWithModel: (id<PMessage>) model;
+(id) messageWithParseObject: (PFObject *) object;

-(RXPromise *) send;
-(RXPromise *) markAsReceived;

@end
