//
//  ScheduleViewController.h
//  SmartSchedulr
//
//  Created by Michael Duong on 6/4/11.
//  Copyright 2011 Ambitiouxs Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

#import "ScheduleView.h"
#import "CalendarBumpConnector.h"
#import "Event_CoreData.h"
#import "SharedEventStore.h"

@class CalendarBumpConnector;

@interface ScheduleViewController : UIViewController <ScheduleViewDelegate, EKEventEditViewDelegate> {
    CalendarBumpConnector *bumpConn;
    
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) EKEvent *event;
@property (nonatomic, retain) NSArray *events;

@property (nonatomic, retain) CalendarBumpConnector *bumpConn;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- initInManagedObjectContext:(NSManagedObjectContext *)context;

- (void)declineEvent;

@end
