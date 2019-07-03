//
//  BFirebaseNetworkAdapterModule.m
//  ChatSDK Demo
//
//  Created by Ben on 2/1/18.
//  Copyright © 2018 deluge. All rights reserved.
//

#import "FirebaseAdapter.h"
#import "BFirebaseNetworkAdapterModule.h"

@implementation BFirebaseNetworkAdapterModule

-(void) activate {
    BChatSDK.shared.networkAdapter = [[BFirebaseNetworkAdapter alloc] init];
}

@end
