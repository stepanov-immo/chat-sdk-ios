//
//  NSObject+ParseHelper.h
//  ChatSDK Demo
//
//  Created by Alexander Stepanov on 03/07/2019.
//  Copyright © 2019 deluge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface NSObject (ParseHelper)

-(void)observe:(NSString*)key query:(PFQuery*)query childChange:(void(^)(PFObject* added, PFObject* removed))block;
-(void)observe:(NSString*)key query:(PFQuery*)query update:(void(^)(PFObject* o))block;

-(void)removeQueryObserver:(NSString*)key;

@end
