//
//  ScheduleOptionsTableViewController.m
//  SmartSchedulr
//
//  Created by Michael Duong on 6/1/11.
//  Copyright 2011 Ambitiouxs Software. All rights reserved.
//

#import "ScheduleOptionsTableViewController.h"

static NSArray *daysOfTheWeek = nil;
static dispatch_semaphore_t events_sema;

@implementation ScheduleOptionsTableViewController

@synthesize pickerView, nextButton, doneButton, loadingView, activityIndicatorView, dateFormatter, options, event, otherEvents, bumpConn, managedObjectContext;

+ (void)initialize
{
    if (daysOfTheWeek == nil) {
        daysOfTheWeek = [[NSArray alloc] initWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
    }
}

- (void)setOtherEvents:(NSArray *)someOtherEvents
{
    if (otherEvents != someOtherEvents) {
        [otherEvents release];
        otherEvents = [someOtherEvents retain];
        dispatch_semaphore_signal(events_sema);
    }
}

//// Lazy-instantiation for activityIndicatorView.
//- (UIActivityIndicatorView *)activityIndicatorView
//{
//    if (!activityIndicatorView) {
//        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    }
//    return activityIndicatorView;
//}

// Given a date, returns the date rounded to the neartest five minutes.
- (NSDate *)roundDateToCeiling5Minutes:(NSDate *)date
{
    // Get the nearest 5 minute block
    NSDateComponents *time = [[NSCalendar currentCalendar]
                              components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit
                              fromDate:date];
    NSInteger minutes = [time minute];
    int remain = minutes % 5;
    // Add the remainder of time to the date to round it up evenly
    date = [date dateByAddingTimeInterval:60*(5-remain)];
    // Subtract the number of seconds
    date = [date dateByAddingTimeInterval:(-1 * [time second])];
    return date;
}

// Given a number of seconds, returns the amount of time in hours and
// minutes.
- (NSString *)niceDurationStringForSeconds:(int)seconds
{
    // Get the number of hours
    int hours = seconds / 3600;
    seconds -= hours * 3600;
    // Get the number of minutes
    int minutes = seconds / 60;
    NSString *duration = @"";
    if (hours > 0) {
        if (hours == 1) duration = [NSString stringWithFormat:@"%d hour", hours];
        else duration = [NSString stringWithFormat:@"%d hours", hours];
        if (minutes > 0) {
            duration = [duration stringByAppendingFormat:@" "];
        }
    }
    if (minutes > 0) {
        if (minutes == 1) duration = [duration stringByAppendingFormat:@"%d min", minutes];
        else duration = [duration stringByAppendingFormat:@"%d mins", minutes];
    }
    
    return duration;
}

// Method shared between awakeFromNib and designated initalizer.
// Sets up this MVC's tab bar item info.
- (void)setup
{
    self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:0] autorelease];
}

- (void)awakeFromNib
{
    [self setup];
}

- initInManagedObjectContext:(NSManagedObjectContext *)context
{
    if (context) {
        self = [super initWithNibName:@"ScheduleOptionsTableViewController" bundle:nil];
        if (self) {
            [self setup];
            self.title = @"Options";
            self.managedObjectContext = context;
        }
    } else {
        [self release];
        self = nil;
    }
    return self;
}

#pragma mark UITableViewDelegate

// Adapted from iOS Developer Library's DateCell example.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2) {
            if (indexPath.row == 0 || indexPath.row == 1) {
                [self.pickerView setDatePickerMode:UIDatePickerModeTime];
                if (indexPath.row == 0) {
                    self.pickerView.date = [self.options objectForKey:@"starts"];
                } else if (indexPath.row == 1) {
                    self.pickerView.date = [self.options objectForKey:@"ends"];
                }
            }
            // check if our date picker is already on screen
            if (self.pickerView.superview == nil)
            {
                [self.view.window addSubview: self.pickerView];
                
                // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
                //
                // compute the start frame
                CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
                CGSize pickerSize = [self.pickerView sizeThatFits:CGSizeZero];
                CGRect startRect = CGRectMake(0.0,
                                              screenRect.origin.y + screenRect.size.height,
                                              pickerSize.width, pickerSize.height);
                self.pickerView.frame = startRect;
                
                // compute the end frame
                CGRect pickerRect = CGRectMake(0.0,
                                               screenRect.origin.y + screenRect.size.height - pickerSize.height - 49,
                                               pickerSize.width,
                                               pickerSize.height);
                // start the slide up animation
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.3];
                
                // we need to perform some post operations after the animation is complete
                [UIView setAnimationDelegate:self];
                
                self.pickerView.frame = pickerRect;
                
                // shrink the table vertical size to make room for the date picker
                CGRect newFrame = self.tableView.frame;
                newFrame.size.height -= self.pickerView.frame.size.height;
                self.tableView.frame = newFrame;
                [UIView commitAnimations];
                
                // add the "Done" button to the nav bar
                self.navigationItem.rightBarButtonItem = self.doneButton;
            }
        }
    } else if (indexPath.section == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([[[self.options objectForKey:@"days"] objectAtIndex:indexPath.row] boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [[self.options objectForKey:@"days"] replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [[self.options objectForKey:@"days"] replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
        }
    }
}

#pragma mark UITableViewDataSource

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"] autorelease];
	}
    
	// Set up the cell...
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Starts";
            cell.detailTextLabel.text = [self.dateFormatter stringFromDate:[self.options valueForKey:@"starts"]];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Ends";
            cell.detailTextLabel.text = [self.dateFormatter stringFromDate:[self.options valueForKey:@"ends"]];
        }
    } else if (indexPath.section == 1) {
        cell.textLabel.text = [daysOfTheWeek objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = @"";
        if ([[[self.options objectForKey:@"days"] objectAtIndex:indexPath.row] boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
	return cell;
}

// Number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 2;
    else if (section == 1) return 7;
    else return 0;
}

// Number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Event Details";
    else if (section == 1)
        return @"Event Options";
    else
        return @"";
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create the semaphore, specifying the initial pool size
    events_sema = dispatch_semaphore_create(0);
    
    self.navigationItem.rightBarButtonItem = nextButton;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"h:mm aa"];
    
    // Initialize the options array to the current time
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *startDateComponents = [gregorianCalendar components:(NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:[NSDate date]];
    NSDateComponents *endDateComponents = [gregorianCalendar components:(NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:[NSDate date]];
    if ([startDateComponents hour] == 23) {
        if ([startDateComponents minute] < 55)
            [endDateComponents setHour:0];
    } else {
        [endDateComponents setHour:[startDateComponents hour] + 1];
    }
    
    self.options = [[NSMutableDictionary alloc] initWithCapacity:4];
    [self.options setValue:[self roundDateToCeiling5Minutes:[gregorianCalendar dateFromComponents:startDateComponents]] forKey:@"starts"];
    [self.options setValue:[self roundDateToCeiling5Minutes:[gregorianCalendar dateFromComponents:endDateComponents]] forKey:@"ends"];
    
    [self.options setValue:[NSMutableArray arrayWithObjects:[NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], nil] forKey:@"days"];
//    [self.options setValue:[NSMutableDictionary dictionaryWithObjects:daysOptions forKeys:daysOfTheWeek] forKey:@"days"];

    [gregorianCalendar release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.pickerView = nil;
    self.nextButton = nil;
    self.doneButton = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.pickerView.superview) {
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGRect endFrame = self.pickerView.frame;
        endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
        
        // start the slide down animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
        
        self.pickerView.frame = endFrame;
        
        // grow the table back again in vertical size to make room for the date picker
        CGRect newFrame = self.tableView.frame;
        newFrame.size.height += self.pickerView.frame.size.height;
        self.tableView.frame = newFrame;
        [UIView commitAnimations];
        
        // remove the "Done" button in the nav bar
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)slideDownDidStop
{
	// the date picker has finished sliding downwards, so remove it
	[self.pickerView removeFromSuperview];
}

// Validates that the start date comes before the end date.
- (BOOL)validateValues
{
    NSDate *startDate = [self.options objectForKey:@"starts"];
    NSDate *endDate = [self.options objectForKey:@"ends"];
    NSComparisonResult order = [startDate compare:endDate];
    
    BOOL selectedDay = NO;
    NSArray *days = [self.options objectForKey:@"days"];
    for (NSNumber *day in days) {
        if ([day boolValue]) {
            selectedDay = YES;
            break;
        }
    }
    
    return order == NSOrderedAscending && selectedDay;
}

// Called everytime the date picker value changes. Updates the
// values in the dictionary and does validation to visually
// show the user if they are entering invalid options.
- (IBAction)timeAction:(id)sender
{
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
    if (indexPath.row == 0) {
        [self.options setValue:self.pickerView.date forKey:@"starts"];
        cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.pickerView.date];
        NSComparisonResult dateCompare = [[self.options objectForKey:@"starts"] compare:[self.options objectForKey:@"ends"]];
        UITableViewCell *otherCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        if (dateCompare == NSOrderedDescending) {
            // Invalid data
            otherCell.detailTextLabel.textColor = [UIColor redColor];
        } else {
            otherCell.detailTextLabel.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
        }
    } else if (indexPath.row == 1) {
        [self.options setValue:self.pickerView.date forKey:@"ends"];
        cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.pickerView.date];
        NSComparisonResult dateCompare = [[self.options objectForKey:@"starts"] compare:[self.options objectForKey:@"ends"]];
        UITableViewCell *otherCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if (dateCompare != NSOrderedAscending) {
            // Invalid data
            otherCell.detailTextLabel.textColor = [UIColor redColor];
        } else {
            otherCell.detailTextLabel.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
        }
    }
}

// Called when the user is set on particular event options. This
// is the meat of the event processing. At this point, the user
// should have gotten a month's worth of the other user's events
// and will algorithmically find the first time that works for
// both parties that fit the given options.
- (IBAction)nextAction:(id)sender
{
    // Only start processing if the options are valid.
    if ([self validateValues]) {
        [self.tableView setUserInteractionEnabled:NO];
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;
        [self.view addSubview:self.loadingView];
        self.activityIndicatorView.center = self.loadingView.center;
        [self.activityIndicatorView startAnimating];
        [self.loadingView addSubview:self.activityIndicatorView];
        [self.view bringSubviewToFront:self.loadingView];
        // Spawn another thread to do the processing
        dispatch_queue_t calendarQueue = dispatch_queue_create("Calendar processor", nil);
        dispatch_async(calendarQueue, ^{
            dispatch_semaphore_wait(events_sema, DISPATCH_TIME_FOREVER);
            
            // Find available time
            EKEvent *newEvent = nil;
            
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *currentStartComponents = [gregorianCalendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSWeekdayCalendarUnit) fromDate:[NSDate date]];
            NSDateComponents *currentEndComponents = [gregorianCalendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSWeekdayCalendarUnit) fromDate:[NSDate date]];
            NSDateComponents *startComponents = [gregorianCalendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSWeekdayCalendarUnit) fromDate:[self.options objectForKey:@"starts"]];
            NSDateComponents *endComponents = [gregorianCalendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSWeekdayCalendarUnit) fromDate:[self.options objectForKey:@"ends"]];
            [currentStartComponents setHour:[startComponents hour]];
            [currentStartComponents setMinute:[startComponents minute]];
            [currentEndComponents setHour:[endComponents hour]];
            [currentEndComponents setMinute:[endComponents minute]];
            
            NSDate *startDate = [gregorianCalendar dateFromComponents:currentStartComponents];
            NSDate *endDate = [gregorianCalendar dateFromComponents:currentEndComponents];
            
            // If the beginning startDate already passed, start with the same time on the next day.
            NSComparisonResult dateCompare = [startDate compare:[NSDate date]];
            if (dateCompare == NSOrderedAscending) {
                [currentStartComponents setDay:[currentStartComponents day] + 1];
                [currentEndComponents setDay:[currentStartComponents day]];
            }
            
            startDate = [gregorianCalendar dateFromComponents:currentStartComponents];
            endDate = [gregorianCalendar dateFromComponents:currentEndComponents];
            
            SharedEventStore *sharedEventStore = [SharedEventStore sharedInstance];
            
            // Find the first time that works for both parties.
            while (true) {
                NSDateComponents *currentDateComponents = [gregorianCalendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSWeekdayCalendarUnit) fromDate:startDate];
                if ([[[self.options objectForKey:@"days"] objectAtIndex:[currentDateComponents weekday] - 1] boolValue]) {
                    NSPredicate *predicate = [sharedEventStore.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
                    NSArray *events = [sharedEventStore.eventStore eventsMatchingPredicate:predicate];
                    
                    // No conflicts with the user's calendar
                    if ([events count] == 0) {
                        BOOL conflict = NO;
                        if ([self.otherEvents count] > 0) {
                            // Check for conflicts with the other user's calendar
                            for (EKEvent *e in self.otherEvents) {
                                NSComparisonResult startCompareStart = [startDate compare:e.startDate];
                                NSComparisonResult endCompareStart = [endDate compare:e.startDate];
                                NSComparisonResult startCompareEnd = [startDate compare:e.endDate];
                                NSComparisonResult endCompareEnd = [endDate compare:e.endDate];
                                
                                if (!((startCompareStart == NSOrderedAscending && endCompareStart == NSOrderedAscending) || (startCompareEnd == NSOrderedDescending && endCompareEnd == NSOrderedDescending))) {
                                    conflict = YES;
                                    break;
                                }
                            }
                        }
                        if (!conflict) {
                            newEvent = [EKEvent eventWithEventStore:sharedEventStore.eventStore];
                        }
                    }
                    
                    if (newEvent) {
                        // Found a day that works!
                        newEvent.startDate = startDate;
                        newEvent.endDate = endDate;
                        break;
                    }
                }
                
                // Keep going...
                NSDateComponents *addDateComponents = [[NSDateComponents alloc] init];
                [addDateComponents setDay:1];
                startDate = [gregorianCalendar dateByAddingComponents:addDateComponents toDate:startDate options:0];
                endDate = [gregorianCalendar dateByAddingComponents:addDateComponents toDate:endDate options:0];
                [addDateComponents release];
            }
            
            [gregorianCalendar release];
            
            // Update the UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicatorView stopAnimating];
                [self.loadingView removeFromSuperview];
                [self.tableView setUserInteractionEnabled:YES];
                self.navigationItem.rightBarButtonItem = self.nextButton;
                self.navigationItem.hidesBackButton = NO;
                dispatch_semaphore_signal(events_sema);
                // Show the user a visual schedule of the chosen day.
                ScheduleViewController *scheduleViewController = [[ScheduleViewController alloc] init];
                scheduleViewController.event = newEvent;
                scheduleViewController.events = self.otherEvents;
                scheduleViewController.bumpConn = self.bumpConn;
                scheduleViewController.managedObjectContext = self.managedObjectContext;
                self.bumpConn.scheduleViewController = scheduleViewController;
                [self.navigationController pushViewController:scheduleViewController animated:YES];
                [scheduleViewController release];
            });
        });
        dispatch_release(calendarQueue);
    } else {
        // Invalid options
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The start time must be before the end time! Also, make sure to select at least one day of the week." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
    }
}

// Called when the user hits the done button. Removes the date picker
// from the view.
- (IBAction)doneAction:(id)sender
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect endFrame = self.pickerView.frame;
	endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
	
	// start the slide down animation
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	
    // we need to perform some post operations after the animation is complete
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
	
    self.pickerView.frame = endFrame;
	
	// grow the table back again in vertical size to make room for the date picker
	CGRect newFrame = self.tableView.frame;
	newFrame.size.height += self.pickerView.frame.size.height;
	self.tableView.frame = newFrame;
    [UIView commitAnimations];
	
	// remove the "Done" button in the nav bar
	self.navigationItem.rightBarButtonItem = nextButton;
	
	// deselect the current table row
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc
{
    [pickerView release];
    [nextButton release];
    [doneButton release];
    [activityIndicatorView release];
    [dateFormatter release];
    [options release];
    [bumpConn release];
    [event release];
    [otherEvents release];
    [managedObjectContext release];
    
    [super dealloc];
}

@end
