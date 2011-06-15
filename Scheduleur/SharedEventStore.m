//
//  SharedEventStore.m
//  Scheduleur
//
//  Created by Michael Duong on 6/14/11.
//  Copyright 2011 Ambitiouxs Software. All rights reserved.
//

#import "SharedEventStore.h"

static SharedEventStore *sharedEventStore = nil;

@implementation SharedEventStore

@synthesize eventStore;

+ (SharedEventStore *)sharedInstance {
    if (sharedEventStore == nil) {
        sharedEventStore = [[super allocWithZone:NULL] init];
    }
    
    return sharedEventStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedInstance] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

@end