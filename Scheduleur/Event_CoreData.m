//
//  Event_CoreData.m
//  SmartSchedulr
//
//  Created by Michael Duong on 6/4/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "Event_CoreData.h"


@implementation Event (Event_CoreData)

// Returns an internal Event object for the given EKEvent.
// Creates the Event object if it doesn't already exist in
// Core Data.
+ (Event *)eventWithEKEvent:(EKEvent *)ekEvent userName:(NSString *)userName inManagedObjectContext:(NSManagedObjectContext *)context
{
    Event *event = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"eventIdentifier = %@", ekEvent.eventIdentifier];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    if (!fetchedObjects || fetchedObjects.count > 1) {
        // handle error
    } else {
        event = [fetchedObjects lastObject];
        if (!event) {
            event = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
            event.eventIdentifier = ekEvent.eventIdentifier;
            event.title = ekEvent.title;
            event.location = ekEvent.location;
            event.startDate = ekEvent.startDate;
            event.endDate = ekEvent.endDate;
            event.userName = userName;
            event.createdAt = [NSDate date];
            event.updatedAt = [NSDate date];
            
            // if we recently scheduled an autosave, cancel it
            [self cancelPreviousPerformRequestsWithTarget:self selector:@selector(autosave:) object:context];
            // request a new autosave in a few tenths of a second
            [self performSelector:@selector(autosave:) withObject:context afterDelay:0.2];
        }
    }
    
    return event;
}

// Deletes the Event object from Core Data.
- (void)remove
{
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:self];
    
    // if we recently scheduled an autosave, cancel it
    [Event cancelPreviousPerformRequestsWithTarget:self selector:@selector(autosave:) object:context];
    // request a new autosave in a few tenths of a second
    [Event performSelector:@selector(autosave:) withObject:context afterDelay:0.2];
}

// Saves a NSManagedObject Context
// This is performed "after delay," so if a batch of them happen all at the same
// time, only the last one will actually take effect (since previous ones get canceled).
+ (void)autosave:(id)context
{
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"Error in autosave from Event_CoreData: %@ %@", [error localizedDescription], [error userInfo]);
    }
}

@end
