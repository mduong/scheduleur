//
//  CustomEKEventViewController.m
//  SmartSchedulr
//
//  Created by Michael Duong on 6/4/11.
//  Copyright 2011 Ambitiouxs. All rights reserved.
//

#import "CustomEKEventViewController.h"


@implementation CustomEKEventViewController

@synthesize bumpConn;

// Declines the event and sends a message to the other user.
- (void)declineEvent
{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    [self.bumpConn declineEvent];
    
    [self.navigationController popViewControllerAnimated:YES];
}

// Accepts the event, saves it, and notifies the other user.
- (void)acceptEvent
{
    SharedEventStore *sharedEventStore = [SharedEventStore sharedInstance];
    EKEvent *event = [EKEvent eventWithEventStore:sharedEventStore.eventStore];
    event.title = self.event.title;
    event.location = self.event.location;
    event.startDate = self.event.startDate;
    event.endDate = self.event.endDate;
    event.calendar = [sharedEventStore.eventStore defaultCalendarForNewEvents];
    
    NSError *error = nil;
        
    [sharedEventStore.eventStore saveEvent:event span:EKSpanThisEvent error:&error];
    
    if (error) {
        NSLog(@"ERROR: %@", error);
    }
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    [self.bumpConn acceptEvent];
    
    EKEventEditViewController *eventEditViewController = [[EKEventEditViewController alloc] init];
    eventEditViewController.eventStore = sharedEventStore.eventStore;
    eventEditViewController.event = event;
    eventEditViewController.editViewDelegate = self;
    [self.navigationController presentModalViewController:eventEditViewController animated:YES];
    [eventEditViewController release];
}

// Called when the user completes the editing of an event
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Event Details";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Event Details";
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Decline" style:UIBarButtonItemStyleBordered target:self action:@selector(declineEvent)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Accept" style:UIBarButtonItemStyleDone target:self action:@selector(acceptEvent)] autorelease];
}

- (void)dealloc
{
    [bumpConn release];
    
    [super dealloc];
}

@end
