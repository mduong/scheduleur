//
//  CalendarBumpConnector.m
//  SmartSchedulr
//
//  Created by Michael Duong on 5/30/11.
//  Copyright 2011 Ambitiouxs. All rights reserved.
//

#import "CalendarBumpConnector.h"


@implementation CalendarBumpConnector

@synthesize bumpViewController, scheduleOptionsViewController, scheduleViewController;

- (id) init
{
	if((self = [super init])){
		bumpObject = [BumpAPI sharedInstance];
        bumpConnected = NO;
	}
	return self;
}

// Sets up the Bump application.
- (void) configBump
{
	[bumpObject configAPIKey:@"3821084f4e524486bbf91201bab71891"];
	[bumpObject configDelegate:self];
	[bumpObject configParentView:self.bumpViewController.view];
	[bumpObject configActionMessage:@"Bump with another Scheduleur user to start scheduling."];
}

// Sets up the Bump username.
- (void) configUserName:(NSString *)userName
{
    [bumpObject configUserName:userName];
}

// Starts a request for a Bump session.
- (void) startBump
{
	[bumpObject requestSession];
}

// Ends a Bump session.
- (void) stopBump{
	[bumpObject endSession];
}

// Sends a message to the other user to say that this user is
// scheduling the event.
- (void)startScheduling
{
    if (!bumpViewController.scheduling) {
        NSMutableDictionary *scheduleDict = [[NSMutableDictionary alloc] initWithCapacity:2];
        [scheduleDict setObject:[[bumpObject me] userName] forKey:@"USER_ID"];
        [scheduleDict setObject:@"SCHEDULE" forKey:@"ACTION"];
        NSData *scheduleChunk = [NSKeyedArchiver archivedDataWithRootObject:scheduleDict];
        [scheduleDict release];
        [bumpObject sendData:scheduleChunk];
    }
}

// Sends a message to the other user to say that this user has
// canceled the scheduling of an event.
- (void)cancelScheduling
{
    if (bumpViewController.scheduling) {
        NSMutableDictionary *scheduleDict = [[NSMutableDictionary alloc] initWithCapacity:2];
        [scheduleDict setObject:[[bumpObject me] userName] forKey:@"USER_ID"];
        [scheduleDict setObject:@"CANCEL" forKey:@"ACTION"];
        NSData *scheduleChunk = [NSKeyedArchiver archivedDataWithRootObject:scheduleDict];
        [scheduleDict release];
        [bumpObject sendData:scheduleChunk];
    }
}

// Sends all events in the array passed to the method to the
// other user.
- (void)sendEvents:(NSArray *)events
{
    NSMutableDictionary *eventsDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    [eventsDict setObject:[[bumpObject me] userName] forKey:@"USER_ID"];
    [eventsDict setObject:@"EVENTS" forKey:@"ACTION"];
    [eventsDict setObject:events forKey:@"EVENTS"];
    NSData *eventsChunk = [NSKeyedArchiver archivedDataWithRootObject:eventsDict];
    [eventsDict release];
    [bumpObject sendData:eventsChunk];
}

// Sends a single event to the other user (the scheduled event).
- (void)sendEvent:(EKEvent *)event
{
    NSMutableDictionary *eventDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    [eventDict setObject:[[bumpObject me] userName] forKey:@"USER_ID"];
    [eventDict setObject:@"EVENT" forKey:@"ACTION"];
    [eventDict setObject:event forKey:@"EVENT"];
    NSData *eventChunk = [NSKeyedArchiver archivedDataWithRootObject:eventDict];
    [eventDict release];
    [bumpObject sendData:eventChunk];
}

// Sends an accept message to the other user to accept the
// scheduled event.
- (void)acceptEvent
{
    NSMutableDictionary *eventDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [eventDict setObject:[[bumpObject me] userName] forKey:@"USER_ID"];
    [eventDict setObject:@"ACCEPT" forKey:@"ACTION"];
    NSData *eventChunk = [NSKeyedArchiver archivedDataWithRootObject:eventDict];
    [eventDict release];
    [bumpObject sendData:eventChunk];
    [self.bumpViewController resetState];
}

// Sends a decline message to the other user to decline the
// scheduled event.
- (void)declineEvent
{
    NSMutableDictionary *eventDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [eventDict setObject:[[bumpObject me] userName] forKey:@"USER_ID"];
    [eventDict setObject:@"DECLINE" forKey:@"ACTION"];
    NSData *eventChunk = [NSKeyedArchiver archivedDataWithRootObject:eventDict];
    [eventDict release];
    [bumpObject sendData:eventChunk];
}

// Returns the other bumper as a Bumper object.
- (Bumper *)otherBumper
{
    return [bumpObject otherBumper];
}

// for Debug -- prints contents of NSDictionary
-(void)printDict:(NSDictionary *)ddict
{
	NSLog(@"---printing Dictionary---");
	NSArray *keys = [ddict allKeys];
	for (id key in keys) {
		NSLog(@"   key = %@     value = %@",key,[ddict objectForKey:key]);
	}	
}

// Returns YES if currently connected to another user and
// false, otherwise.
- (BOOL)bumpConnected
{
    return bumpConnected;
}

#pragma mark -
#pragma mark BumpAPIDelegate methods

// Handles all data received from the other Bumper.
- (void) bumpDataReceived:(NSData *)chunk
{
	//The chunk was packaged by the other user using an NSKeyedArchiver, so we unpackage it here with our NSKeyedUnArchiver
	NSDictionary *responseDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:chunk];
	[self printDict:responseDictionary];
	
	//responseDictionary no contains an Identical dictionary to the one that the other user sent us
	NSString *userName = [responseDictionary objectForKey:@"USER_ID"];
	NSString *action = [responseDictionary objectForKey:@"ACTION"];
	
	NSLog(@"user name and action are %@, %@", userName, action);
    
    if ([action isEqualToString:@"SCHEDULE"]) {
        // Received message saying the other user is scheduling
        if (self.bumpViewController.scheduling) {
            // Error and cancel scheduling because only one user can schedule at a time.
            [self.bumpViewController resetState];
            [self.scheduleOptionsViewController.navigationController popToRootViewControllerAnimated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Only one person can do the scheduling!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } else {
            // Set up UI so user can't start scheduling
            self.bumpViewController.nameLabel.text = [NSString stringWithFormat:@"Please wait while %@ schedules the event.", userName];
            self.bumpViewController.scheduleButton.hidden = YES;
            // Sends a month's-worth of events from the user's calendar to the other user.
            dispatch_queue_t calendarQueue = dispatch_queue_create("Calendar fetcher", NULL);
            dispatch_async(calendarQueue, ^{
                SharedEventStore *sharedEventStore = [SharedEventStore sharedInstance];
                
                // Create the predicate's start and end dates.
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *dateComponents = [gregorianCalendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:[NSDate date]];
                [dateComponents setHour:0];
                [dateComponents setMinute:0];
                NSDate* startDate = [gregorianCalendar dateFromComponents:dateComponents];
                [gregorianCalendar release];
                NSDate* endDate = [NSDate dateWithTimeIntervalSinceNow:30 * 24 * 60 * 60]; // 30 days from now
                
                // Create the predicate.
                NSPredicate *predicate = [sharedEventStore.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
                
                // Fetch all events that match the predicate.
                NSArray *events = [sharedEventStore.eventStore eventsMatchingPredicate:predicate];
                if (!events) events = [NSArray array];
                [self sendEvents:events];
            });
            dispatch_release(calendarQueue);
        }
    } else if ([action isEqualToString:@"CANCEL"]) {
        // Received message saying that the other user canceled the scheduling.
        // This user can now schedule, so reset the state.
        [self.bumpViewController resetState];
    } else if ([action isEqualToString:@"EVENTS"]) {
        // Received message with all the events of the other Bumper. Set the
        // events member of the VC so that it can do processing later.
        NSArray *events = [responseDictionary objectForKey:@"EVENTS"];
        self.scheduleOptionsViewController.otherEvents = events;
    } else if ([action isEqualToString:@"EVENT"]) {
        EKEvent *event = [responseDictionary objectForKey:@"EVENT"];
        // Received message with the scheduled event. Begin accept/decline
        // process by setting the event on the VC so it can handle it.
        self.bumpViewController.event = event;
    } else if ([action isEqualToString:@"ACCEPT"]) {
        // Received message that the other user has accepted the scheduled event.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event Accepted" message:@"The event was accepted and saved!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
        [self.bumpViewController resetState];
        [self.scheduleViewController.navigationController popToRootViewControllerAnimated:YES];
    } else if ([action isEqualToString:@"DECLINE"]) {
        // Received message that the other user has declined the scheduled
        // event. Handle the decline and prompt user to schedule another event.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event Declined" message:@"The event was declined!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
        [self.scheduleViewController declineEvent];
    }
}

// Called when a Bump session is started.
- (void) bumpSessionStartedWith:(Bumper*)otherBumper
{
    bumpConnected = YES;
	[self.bumpViewController bumpConnectedWith:otherBumper];
}

// Called when a Bump session ends.
- (void) bumpSessionEnded:(BumpSessionEndReason)reason
{
    bumpConnected = NO;
	NSString *alertText;
	switch (reason) {
		case END_OTHER_USER_QUIT:
			alertText = @"Other user has quit the app.";
			break;
		case END_LOST_NET:
			alertText = @"Connection to Bump server was lost.";
			break;
		case END_OTHER_USER_LOST:
			alertText = @"Connection to other user was lost.";
			break;
		case END_USER_QUIT:
			alertText = @"You have been disconnected.";
			break;
		default:
			alertText = @"You have been disconnected.";
			break;
	}
	
	if (reason != END_USER_QUIT){ 
		//if the local user initiated the quit,restarting the app is already being handled
		//other wise we'll restart here
		[self.bumpViewController restart];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disconnected" message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

// Called when a Bump session fails to start.
- (void) bumpSessionFailedToStart:(BumpSessionStartFailedReason)reason
{	
	NSString *alertText;
	switch (reason) {
		case FAIL_NETWORK_UNAVAILABLE:
			alertText = @"Please check your network settings and try again.";
			break;
		case FAIL_INVALID_AUTHORIZATION:
			//the user should never see this, since we'll pass in the correct API auth strings.
			//just for debug.
			alertText = @"Failed to connect to the Bump service. Auth error.";
			break;
		default:
			alertText = @"Failed to connect to the Bump service.";
			break;
	}
	
    [self.bumpViewController restart];
	if(reason != FAIL_USER_CANCELED){
		//if the user canceled they know it and they don't need a popup.
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)dealloc
{
    [super dealloc];
}

@end
