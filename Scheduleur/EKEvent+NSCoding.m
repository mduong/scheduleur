//
//  EKEvent+NSCoding.m
//  SmartSchedulr
//
//  Created by Michael Duong on 6/3/11.
//  Copyright 2011 Ambitiouxs. All rights reserved.
//

#import "EKEvent+NSCoding.h"


@implementation EKEvent (EKEvent_NSCoding)

// Category for EKEvent to make it NSCodeable for Bump.

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.location forKey:@"location"];
    [coder encodeObject:self.startDate forKey:@"startDate"];
    [coder encodeObject:self.endDate forKey:@"endDate"];    
}

- (id)initWithCoder:(NSCoder *)coder
{
    [super init];
    
    self.title = [coder decodeObjectForKey:@"title"];
    self.location = [coder decodeObjectForKey:@"location"];
    self.startDate = [coder decodeObjectForKey:@"startDate"];
    self.endDate = [coder decodeObjectForKey:@"endDate"];
    
    return self;
}

@end
