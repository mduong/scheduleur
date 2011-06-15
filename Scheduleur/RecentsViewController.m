//
//  RecentsViewController.m
//  SmartSchedulr
//
//  Created by Michael Duong on 5/28/11.
//  Copyright 2011 Ambitiouxs Software. All rights reserved.
//

#import "RecentsViewController.h"


@implementation RecentsViewController

// Method shared between awakeFromNib and designated initalizer.
// Sets up this MVC's tab bar item info.
- (void)setup
{
    self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemRecents tag:1] autorelease];
}

- (void)awakeFromNib
{
    [self setup];
}

- initInManagedObjectContext:(NSManagedObjectContext *)context
{
    if (context) {
        self = [super initWithStyle:UITableViewStylePlain];
        if (self) {
            [self setup];
            self.title = @"Recents";
            // Fetch the 10 most recently scheduled events.
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            fetchRequest.entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
            fetchRequest.fetchLimit = 10;
            fetchRequest.sortDescriptors = [NSArray arrayWithObject: [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO selector:@selector(compare:)]];
            NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
            [fetchRequest release];
            self.fetchedResultsController = frc;
            [frc release];
        }
    } else {
        [self release];
        self = nil;
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventTableViewCell";
    
    EventTableViewCell *cell = (EventTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[EventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMM d, yyyy"];
    
    // Configure the cell...
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.title.text = (event.title) ? event.title : @"New Event";
    cell.location.text = event.location;
    cell.date.text = [formatter stringFromDate:event.startDate];
    [formatter setDateFormat:@"h:mm a"];
    cell.time.text = [NSString stringWithFormat:@"from %@ to %@", [formatter stringFromDate:event.startDate], [formatter stringFromDate:event.endDate]];
    cell.userName.text = [NSString stringWithFormat:@"Scheduled with %@", event.userName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [formatter release];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SharedEventStore *sharedEventStore = [SharedEventStore sharedInstance];
    
    // Create and push an EKEventViewController for the selected event in the current context.
    Event *selectedEvent = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    EKEvent *event = [sharedEventStore.eventStore eventWithIdentifier:selectedEvent.eventIdentifier];
    if (event) {
        EKEventViewController *eventViewController = [[EKEventViewController alloc] init];
        eventViewController.event = event;
        eventViewController.allowsEditing = NO;
        [self.navigationController pushViewController:eventViewController animated:YES];
        [eventViewController release];
    } else {
        // Event was deleted from the user's calendar so delete it from Core Data
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Oops! It looks like you deleted this event from your calendar." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
        [selectedEvent remove];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 115;
}

#pragma mark - View lifecycle

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

- (void)dealloc
{
    [super dealloc];
}

@end
