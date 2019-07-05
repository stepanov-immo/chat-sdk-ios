//
//  NSObject+ParseHelper.m
//  ChatSDK Demo
//
//  Created by Alexander Stepanov on 03/07/2019.
//  Copyright © 2019 deluge. All rights reserved.
//

#import "NSObject+ParseHelper.h"
#import <ParseLiveQuery-Swift.h>
#import <objc/runtime.h>

static const void *InfoKey = &InfoKey;

@implementation NSObject (ParseHelper)

-(void)observe:(NSString *)key query:(PFQuery *)query childChange:(void (^)(PFObject *, PFObject *))block {
    
    PFQuery *query1 = [query copy];
    [query1 findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        for (PFObject* o in objects) {
            block(o, nil);
        }
    }];
    
    PFLiveQuerySubscription* sub = [[PFLiveQueryClient sharedClient] subscribeToQuery:query];
    sub = [sub addCreateHandler:^(PFQuery* q, PFObject* o) {
        block(o, nil);
    }];
    
    sub = [sub addDeleteHandler:^(PFQuery* q, PFObject* o) {
        block(nil, o);
    }];
    
    [self subscribe:key query:query sub:sub];
}

-(void)observe:(NSString *)key query:(PFQuery *)query update:(void (^)(PFObject *))block {
    
    PFQuery *query1 = [query copy];
    [query1 findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        for (PFObject* o in objects) {
            block(o);
        }
    }];
    
    PFLiveQuerySubscription* sub = [[PFLiveQueryClient sharedClient] subscribeToQuery:query];
    sub = [sub addUpdateHandler:^(PFQuery* q, PFObject* o) {
        block(o);
    }];
    
    [self subscribe:key query:query sub:sub];
}

-(void)subscribe:(NSString *)key query:(PFQuery *)query sub:(PFLiveQuerySubscription*)sub {
    NSMutableDictionary* dict = objc_getAssociatedObject(self, InfoKey);
    if (dict == nil) {
        dict = [NSMutableDictionary new];
        objc_setAssociatedObject(self, InfoKey, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    NSAssert(dict[key] == nil, @"parse add query observer - key exists: %@", key);
    
    // subscription should retained
    dict[key] = @{@"sub": sub, @"query": query};
}

-(void)removeQueryObserver:(NSString *)key {
    NSMutableDictionary* dict = objc_getAssociatedObject(self, InfoKey);
    
    NSAssert(dict[key] != nil, @"parse remove query observer - key not exists: %@", key);
    
    PFQuery* query = dict[key][@"query"];
    if (query != nil) {
        [[PFLiveQueryClient sharedClient] unsubscribeFromQuery:query];
    }
    dict[key] = nil;
}

@end
