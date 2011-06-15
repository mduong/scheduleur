//
//  BumpViewController.h
//  SmartSchedulr
//
//  Created by Michael Duong on 6/3/11.
//  Copyright 2011 Ambitiouxs Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "MOGlassButton.h"
#import "CalendarBumpConnector.h"
#import "ScheduleOptionsTableViewController.h"
#import "CustomEKEventViewController.h"
#import "SharedEventStore.h"

@class CalendarBumpConnector;
@class ScheduleOptionsTableViewController;

@interface BumpViewController : UIViewController <UIAlertViewDelegate> {
    CalendarBumpConnector *bumpConn;
    ScheduleOptionsTableViewController *sotvc;
    
    NSManagedObjectContext *managedObjectContext;
    UILabel *nameLabel;
    MOGlassButton *scheduleButton;
    
    BOOL scheduling;
    
    EKEvent *event;
}

@property (nonatomic, retain) CalendarBumpConnector *bumpConn;
@property (nonatomic, assign) ScheduleOptionsTableViewController *sotvc;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet MOGlassButton *scheduleButton;

@property (nonatomic, retain) EKEvent *event;

@property BOOL scheduling;

- initInManagedObjectContext:(NSManagedObjectContext *)context;

- (void)bumpConnectedWith:(Bumper *)otherBumper;
- (void)startScheduling;
- (void)resetState;
- (void)restart;

@end
