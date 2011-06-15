//
//  ScheduleOptionsTableViewController.h
//  SmartSchedulr
//
//  Created by Michael Duong on 6/1/11.
//  Copyright 2011 Ambitiouxs Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

#import "CoreDataTableViewController.h"
#import "CalendarBumpConnector.h"
#import "Event_CoreData.h"
#import "ScheduleViewController.h"
#import "ScheduleView.h"
#import "SharedEventStore.h"

@class CalendarBumpConnector;

@interface ScheduleOptionsTableViewController : CoreDataTableViewController {
    UIDatePicker *pickerView;
    UIBarButtonItem *nextButton;
    UIBarButtonItem *doneButton;
    
    EKEvent *event;
    
    NSArray *otherEvents;    
    CalendarBumpConnector *bumpConn;
    
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) IBOutlet UIDatePicker *pickerView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *nextButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;


//@property (readonly) UIView *loadingView;
//@property (readonly) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) NSDictionary *options;

@property (nonatomic, retain) EKEvent *event;

@property (nonatomic, retain) NSArray *otherEvents;

@property (nonatomic, retain) CalendarBumpConnector *bumpConn;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- initInManagedObjectContext:(NSManagedObjectContext *)context;

- (IBAction)nextAction:(id)sender;  // when the next button is clicked
- (IBAction)doneAction:(id)sender;	// when the done button is clicked
- (IBAction)timeAction:(id)sender;	// when the user has changed the date picker values

@end
