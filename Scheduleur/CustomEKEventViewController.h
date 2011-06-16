//
//  CustomEKEventViewController.h
//  SmartSchedulr
//
//  Created by Michael Duong on 6/4/11.
//  Copyright 2011 Ambitiouxs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

#import "CalendarBumpConnector.h"
#import "SharedEventStore.h"


@class CalendarBumpConnector;

@interface CustomEKEventViewController : EKEventViewController <EKEventEditViewDelegate> {    
    CalendarBumpConnector *bumpConn;
}

@property (nonatomic, retain) CalendarBumpConnector *bumpConn;

@end
