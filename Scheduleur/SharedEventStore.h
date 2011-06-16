//
//  SharedEventStore.h
//  Scheduleur
//
//  Created by Michael Duong on 6/14/11.
//  Copyright 2011 Ambitiouxs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>


@interface SharedEventStore : NSObject {
    EKEventStore *eventStore;
}

@property (nonatomic, retain) EKEventStore *eventStore;

+ (SharedEventStore *)sharedInstance;

@end