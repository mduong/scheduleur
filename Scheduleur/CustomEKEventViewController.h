//
//  CustomEKEventViewController.h
//  SmartSchedulr
//
//  Created by Michael Duong on 6/4/11.
//  Copyright 2011 Ambitiouxs Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

#import "Event_CoreData.h"
#import "CalendarBumpConnector.h"
#import "SharedEventStore.h"


@class CalendarBumpConnector;

@interface CustomEKEventViewController : EKEventViewController {
    NSManagedObjectContext *managedObjectContext;
    
    CalendarBumpConnector *bumpConn;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) CalendarBumpConnector *bumpConn;

- initInManagedObjectContext:(NSManagedObjectContext *)context;

@end
