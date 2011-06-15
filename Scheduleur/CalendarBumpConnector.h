//
//  CalendarBumpConnector.h
//  SmartSchedulr
//
//  Created by Michael Duong on 5/30/11.
//  Copyright 2011 Ambitiouxs Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "BumpAPI.h"
#import "Bumper.h"
#import "BumpViewController.h"
#import "ScheduleViewController.h"
#import "SharedEventStore.h"

@class BumpViewController;
@class ScheduleOptionsTableViewController;
@class ScheduleViewController;

@interface CalendarBumpConnector : NSObject <BumpAPIDelegate> {
    BumpViewController *bumpViewController;
    ScheduleOptionsTableViewController *scheduleOptionsViewController;
    ScheduleViewController *scheduleViewController;
    
    BumpAPI *bumpObject;
    
    BOOL bumpConnected;
}

@property (nonatomic, assign) BumpViewController *bumpViewController;
@property (nonatomic, assign) ScheduleOptionsTableViewController *scheduleOptionsViewController;
@property (nonatomic, assign) ScheduleViewController *scheduleViewController;

- (void)configBump;

- (void)startScheduling;
- (void)cancelScheduling;
- (void)sendEvents:(NSArray *)events;
- (void)sendEvent:(EKEvent *)event;
- (void)acceptEvent;
- (void)declineEvent;
- (void)startBump;
- (void)stopBump;

- (Bumper *)otherBumper;
- (BOOL)bumpConnected;

@end
