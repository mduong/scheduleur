//
//  CustomEKEventViewController.m
//  SmartSchedulr
//
//  Created by Michael Duong on 6/4/11.
//  Copyright 2011 Ambitiouxs Software. All rights reserved.
//

#import "CustomEKEventViewController.h"


@implementation CustomEKEventViewController

@synthesize managedObjectContext;
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
    
    [Event eventWithEKEvent:event userName:[[self.bumpConn otherBumper] userName] inManagedObjectContext:self.managedObjectContext];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    [self.bumpConn acceptEvent];
    
    [self.tabBarController setSelectedIndex:1];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- initInManagedObjectContext:(NSManagedObjectContext *)context
{
    if (context) {
        self = [super init];
        if (self) {
            self.title = @"Event Details";
            self.managedObjectContext = context;
        }
    } else {
        [self release];
        self = nil;
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
    [managedObjectContext release];
    [bumpConn release];
    
    [super dealloc];
}

@end
