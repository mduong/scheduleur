//
//  Event_CoreData.h
//  SmartSchedulr
//
//  Created by Michael Duong on 6/4/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

#import "Event.h"


@interface Event (Event_CoreData)
+ (Event *)eventWithEKEvent:(EKEvent *)ekEvent userName:(NSString*)userName inManagedObjectContext:(NSManagedObjectContext *)context;
- (void)remove;
@end
