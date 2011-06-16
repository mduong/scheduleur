//
//  BumpViewController.m
//  SmartSchedulr
//
//  Created by Michael Duong on 6/3/11.
//  Copyright 2011 Ambitiouxs. All rights reserved.
//

#import "BumpViewController.h"


@implementation BumpViewController

@synthesize bumpConn, sotvc, nameLabel, scheduleButton, scheduling, event;

// Lazy-instantiation for the Bump connection object.
- (CalendarBumpConnector *)bumpConn
{
    if (!bumpConn) {
        bumpConn = [[CalendarBumpConnector alloc] init];
        bumpConn.bumpViewController = self;
        [bumpConn configBump];
    }
    return bumpConn;
}

// Lazy-instantiation for the ScheduleOptionsTableViewController object.
- (ScheduleOptionsTableViewController *)sotvc
{
    if (!sotvc) {
        sotvc = [[ScheduleOptionsTableViewController alloc] init];
        sotvc.bumpConn = self.bumpConn;
        self.bumpConn.scheduleOptionsViewController = sotvc;
    }
    return sotvc;
}

// Called from a Bump connection when it receives an event scheduled by
// another user. Brings up a custom EKEventViewController to show the
// user the event and let them accept/decline it.
- (void)setEvent:(EKEvent *)newEvent
{
    CustomEKEventViewController *eventViewController = [[CustomEKEventViewController alloc] init];
    eventViewController.bumpConn = self.bumpConn;
    eventViewController.event = newEvent;
    [self.navigationController pushViewController:eventViewController animated:YES];
    [eventViewController release];
}

// Sets up UI when a Bump session is created with another Bumper.
- (void)bumpConnectedWith:(Bumper *)otherBumper
{
    self.nameLabel.text = [NSString stringWithFormat:@"You are connected to %@", [otherBumper userName]];
    self.nameLabel.hidden = NO;
    self.scheduleButton.hidden = NO;
}

// Begin scheduling by pushing the view options controller.
- (void)startScheduling
{
    self.scheduling = YES;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:self.sotvc animated:YES];
}

// Resets the state of the app.
- (void)resetState
{
    if ([self.bumpConn bumpConnected]) {
        // If the user is still connected with another Bumper, display the name.
        self.nameLabel.text = [NSString stringWithFormat:@"You are connected to %@", [[self.bumpConn otherBumper] userName]];
        self.scheduleButton.hidden = NO;
    } else {
        // Not connected to any user, show default empty state.
        self.nameLabel.hidden = YES;
        self.scheduleButton.hidden = YES;
    }
    
    self.scheduling = NO;
}

// Restarts the app and Bump connection.
- (void)restart
{
    self.bumpConn = nil;
    [self resetState];
    if (self.navigationController.topViewController == self) [self.bumpConn startBump];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// Method shared between awakeFromNib and designated initalizer.
// Sets up this MVC's tab bar item info.
- (void)setup
{
    self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Scheduleur" image:[UIImage imageNamed:@"calendar_icon"] tag:0] autorelease];
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.scheduleButton setupAsGreenButton];
    self.scheduling = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.scheduleButton = nil;
    self.nameLabel = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    if ([self.bumpConn bumpConnected] && self.scheduling) {
        [self.bumpConn cancelScheduling];
        [self resetState];
        self.scheduling = NO;
    } else {
        NSString *userName = [[NSUserDefaults standardUserDefaults] valueForKey:@"userName"];
        if (userName && [userName length] > 0) {
            [self.bumpConn configUserName:userName];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![self.bumpConn bumpConnected]) {
        [self.bumpConn startBump];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Action called when the Schedule! button is pressed. Starts the scheduling.
- (IBAction)requestToSchedule
{
    [self.bumpConn startScheduling];
    [self startScheduling];
}

- (void)dealloc
{
    [nameLabel release];
    [scheduleButton release];
    [event release];
    [bumpConn release];
    
    [super dealloc];
}

@end
