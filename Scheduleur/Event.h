//
//  Event.h
//  SmartSchedulr
//
//  Created by Michael Duong on 6/5/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * eventIdentifier;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * userName;

@end
