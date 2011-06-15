//
//  EKEvent+NSCoding.h
//  SmartSchedulr
//
//  Created by Michael Duong on 6/3/11.
//  Copyright 2011 Ambitiouxs Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>


@interface EKEvent (EKEvent_NSCoding) <NSCoding>
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
@end
