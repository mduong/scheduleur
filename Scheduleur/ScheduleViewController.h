//
//  ScheduleViewController.h
//  SmartSchedulr
//
//  Created by Michael Duong on 6/4/11.
//  Copyright 2011 Ambitiouxs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

#import "ScheduleView.h"
#import "CalendarBumpConnector.h"
#import "SharedEventStore.h"

@class CalendarBumpConnector;

@interface ScheduleViewController : UIViewController <ScheduleViewDelegate, EKEventEditViewDelegate> {
    CalendarBumpConnector *bumpConn;
}

@property (nonatomic, retain) EKEvent *event;
@property (nonatomic, retain) NSArray *events;

@property (nonatomic, retain) CalendarBumpConnector *bumpConn;

- (void)declineEvent;

@end
