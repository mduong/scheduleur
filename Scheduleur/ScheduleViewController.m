//
//  ScheduleViewController.m
//  SmartSchedulr
//
//  Created by Michael Duong on 6/4/11.
//  Copyright 2011 Ambitiouxs Software. All rights reserved.
//

#import "ScheduleViewController.h"


@interface ScheduleViewController()
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) ScheduleView *scheduleView;
@end

@implementation ScheduleViewController

@synthesize scrollView, scheduleView;
@synthesize event, events;
@synthesize bumpConn;
@synthesize managedObjectContext;

// Lazy-instantiation for the schedule view.
- (ScheduleView *)scheduleView
{
    if (!scheduleView) {
        CGRect frame = [[UIScreen mainScreen] applicationFrame];
        frame.size.height *= 2;
        scheduleView = [[ScheduleView alloc] initWithFrame:frame];
        scheduleView.backgroundColor = [UIColor whiteColor];
        scheduleView.delegate = self;
        
        self.scrollView.contentSize = frame.size;
    }
    return scheduleView;
}

#pragma mark - ScheduleViewDelegate

// Delegate method for the schedule view to get the event
// to be scheduled.
- (EKEvent *)eventForScheduleView:(ScheduleView *)sender
{
    return self.event;
}

// Delegate method for the schedule view to get all events
// other than the event to be scheduled.
- (NSArray *)eventsForScheduleView:(ScheduleView *)sender date:(NSDate *)date
{
    SharedEventStore *sharedEventStore = [SharedEventStore sharedInstance];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dayComponents = [gregorianCalendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:date];
    NSDateComponents *nextDayComponents = [gregorianCalendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:date];
    [dayComponents setHour:0];
    [dayComponents setMinute:0];
    [nextDayComponents setDay:[dayComponents day] + 1];
    [nextDayComponents setHour:0];
    [nextDayComponents setMinute:0];
    NSDate *startDate = [gregorianCalendar dateFromComponents:dayComponents];
    NSDate *endDate = [gregorianCalendar dateFromComponents:nextDayComponents];
    [gregorianCalendar release];
    NSPredicate *predicate = [sharedEventStore.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    // Get user's events (months-worth)
    NSArray *myEvents = [sharedEventStore.eventStore eventsMatchingPredicate:predicate];
    NSMutableArray *allEvents = [NSMutableArray arrayWithArray:myEvents];
    if ([self.events count] > 0) {
        for (EKEvent *e in self.events) {
            NSComparisonResult startCompare = [startDate compare:e.startDate];
            NSComparisonResult endCompare = [endDate compare:e.endDate];
            if (startCompare == NSOrderedAscending && endCompare == NSOrderedDescending) {
                // Censor event titles of other user's events for privacy
                e.title = @"";
                e.location = @"";
                [allEvents addObject:e];
            }
        }
    }
    
    return allEvents;
}

// Edit event view to allow the user to do some event editing before
// sending it off to the other user.
- (void)editEvent
{
    SharedEventStore *sharedEventStore = [SharedEventStore sharedInstance];
    EKEventEditViewController *eventEditViewController = [[EKEventEditViewController alloc] init];
    eventEditViewController.eventStore = sharedEventStore.eventStore;
    eventEditViewController.event = self.event;
    eventEditViewController.editViewDelegate = self;
    [self presentModalViewController:eventEditViewController animated:YES];
    [eventEditViewController release];
}

// Called when the other user declined an event this user had scheduled.
// Deletes the event from Core Data and sets up the app so that the user
// can begin to schedule another event.
- (void)declineEvent
{
    SharedEventStore *sharedEventStore = [SharedEventStore sharedInstance];
    
    [[Event eventWithEKEvent:event userName:[[bumpConn otherBumper] userName] inManagedObjectContext:self.managedObjectContext] remove];
    
    NSError *error = nil;
    [sharedEventStore.eventStore removeEvent:event span:EKSpanThisEvent error:&error];
    self.event = nil;
    
    int count = [self.navigationController.viewControllers count];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:count - 3] animated:YES];
}

- (id)initInManagedObjectContext:(NSManagedObjectContext *)context
{
    if (context) {
        self = [super init];
        if (self) {
            self.managedObjectContext = context;
        }
    } else {
        [self release];
        self = nil;
    }
    return self;
}

// Called when the user completes the editing of an event
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    [self dismissModalViewControllerAnimated:YES];
    if (action == EKEventEditViewActionSaved) {
        self.event = controller.event;
        EKEventViewController *eventViewController = [[EKEventViewController alloc] init];
        eventViewController.event = self.event;
        eventViewController.allowsEditing = NO;
        eventViewController.navigationItem.hidesBackButton = YES;
        eventViewController.navigationItem.rightBarButtonItem = nil;
        [self.navigationController pushViewController:eventViewController animated:YES];
        [eventViewController release];
        // Send the proposed event to the other user.
        [bumpConn sendEvent:self.event];
        
        NSError *error = nil;
        
        if (error) {
            NSLog(@"ERROR: %@", error);
        }
        
        [Event eventWithEKEvent:event userName:[[self.bumpConn otherBumper] userName] inManagedObjectContext:self.managedObjectContext];
    }
}

- (void)dealloc
{
    [event release];
    [events release];
    [scheduleView release];
    [bumpConn release];
    [managedObjectContext release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView
{
    // Set up the scroll view to be ready to show the day's events.
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
    [self.scrollView addSubview:self.scheduleView];
    self.view = self.scrollView;
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(editEvent)];
    self.navigationItem.rightBarButtonItem = nextButton;
    [nextButton release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, MMM d, yyyy"];
    self.title = [dateFormatter stringFromDate:self.event.startDate];
    [dateFormatter release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
