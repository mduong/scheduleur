//
//  ScheduleView.h
//  SmartSchedulr
//
//  Created by Michael Duong on 6/4/11.
//  Copyright 2011 Ambitiouxs Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>


@class ScheduleView;

@protocol ScheduleViewDelegate
- (EKEvent *)eventForScheduleView:(ScheduleView *)sender;
- (NSArray *)eventsForScheduleView:(ScheduleView *)sender date:(NSDate *)date;
@end

@interface ScheduleView : UIView

@property (nonatomic, assign) id <ScheduleViewDelegate> delegate;

@end
