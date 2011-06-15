//
//  RecentsViewController.h
//  SmartSchedulr
//
//  Created by Michael Duong on 5/28/11.
//  Copyright 2011 Ambitiouxs Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

#import "CoreDataTableViewController.h"
#import "Event_CoreData.h"
#import "EventTableViewCell.h"
#import "SharedEventStore.h"


@interface RecentsViewController : CoreDataTableViewController

- initInManagedObjectContext:(NSManagedObjectContext *)context;

@end
