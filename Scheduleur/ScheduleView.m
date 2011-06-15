//
//  ScheduleView.m
//  SmartSchedulr
//
//  Created by Michael Duong on 6/4/11.
//  Copyright 2011 Ambitiouxs Software. All rights reserved.
//

#import "ScheduleView.h"

#define VERTICAL_MARGIN  15
#define LEFT_MARGIN 50
#define RIGHT_MARGIN 10

#define ARC4RANDOM_MAX 0x100000000
#define GOLDEN_RATIO 0.618033988749895


@implementation ScheduleView

@synthesize delegate;

- (void)setup
{
    self.contentMode = UIViewContentModeRedraw;
}

/*
 * Called whenever a GraphView is created from a .xib file. In
 * other words, whenever someone drags a generic UIView out of
 * the palette in Xcode, then changes the class to be a GraphView.
 * Calls setup to get things set up the way we want.
 */
- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

// Returns an aesthetically-pleasing random color.
+ (UIColor *)randomColor
{
    CGFloat hue = ((double)arc4random() / ARC4RANDOM_MAX);
    hue += 1 / GOLDEN_RATIO;
    if (hue > 1) hue -= 1;
    CGFloat saturation = 0.5;
    CGFloat brightness = 0.95;
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.75];
    
//    CGFloat red = (arc4random() % 256 + 255.0) / 2.0 / 256.0;
//    CGFloat green = (arc4random() % 256 + 255.0) / 2.0 / 256.0;
//    CGFloat blue = (arc4random() % 256 + 255.0) / 2.0 / 256.0;
//    
//    return [UIColor colorWithRed:red green:green blue:blue alpha:0.75];
}

// Returns an NSString for a given hour.
- (NSString *)stringForHour:(int)hour
{
    if (hour == 0 || hour == 24) return @"12 AM";
    if (hour == 12) return @"12 PM";
    if (hour > 12) return [NSString stringWithFormat:@"%d PM", hour - 12];
    return [NSString stringWithFormat:@"%d AM", hour];
}

// Draws the hour lines and the respective hour labels.
- (void)drawLines
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
	UIGraphicsPushContext(context);
    
    CGFloat separation = (self.bounds.size.height - VERTICAL_MARGIN) / 25.0f;
    
    int hour = 0;
    
	CGContextBeginPath(context);
    [[UIColor grayColor] setStroke];
    for (float offset = 0; offset <= self.bounds.size.height; offset += separation) {
        NSString *time = [self stringForHour:hour];
        UIFont *font = [UIFont systemFontOfSize:12];
        CGSize fontSize = [time sizeWithFont:font];
        [time drawAtPoint:CGPointMake(self.bounds.origin.x + 5, self.bounds.origin.y + VERTICAL_MARGIN + offset - fontSize.height / 2.0) withFont:font];
        CGContextMoveToPoint(context, self.bounds.origin.x + LEFT_MARGIN, self.bounds.origin.y + VERTICAL_MARGIN + offset);
        CGContextAddLineToPoint(context, self.bounds.origin.x + self.bounds.size.width - RIGHT_MARGIN, self.bounds.origin.y + VERTICAL_MARGIN + offset);
        hour++;
        if (hour > 24) break;
    }
	CGContextStrokePath(context);
    
	UIGraphicsPopContext();
}

// Draws everyone's events except for the event to be scheduled.
- (void)drawEvents
{
    EKEvent *event = [self.delegate eventForScheduleView:self];
    NSArray *events = [self.delegate eventsForScheduleView:self date:event.startDate];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
	UIGraphicsPushContext(context);
    
    CGFloat yMidnight = (self.bounds.size.height - VERTICAL_MARGIN) / 25.0f;
    CGFloat hourSeparation = yMidnight;
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    // Draw each event.
    for (EKEvent *e in events) {
        NSDateComponents *startDateComponents = [gregorianCalendar components:(NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:e.startDate];
        NSDateComponents *endDateComponents = [gregorianCalendar components:(NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:e.endDate];
        int startHour = [startDateComponents hour] - 1;
        int startMinute = [startDateComponents minute];
        int endHour = [endDateComponents hour] - 1;
        int endMinute = [endDateComponents minute];
        
        CGFloat yStart = (hourSeparation + 1) * startHour + (hourSeparation / 60.0f) * startMinute;
        CGFloat yEnd = (hourSeparation + 1) * endHour + (hourSeparation / 60.f) * endMinute;
        
        CGContextBeginPath(context);
        [[UIColor blackColor] setStroke];
        UIColor *lightGrayColor = [UIColor colorWithRed:170.0/256.0 green:170.0/256.0 blue:170.0/256.0 alpha:0.75 ];
        [lightGrayColor setFill];
        CGContextMoveToPoint(context, self.bounds.origin.x + LEFT_MARGIN, yStart + VERTICAL_MARGIN);
        CGContextAddLineToPoint(context, self.bounds.origin.x + self.bounds.size.width - RIGHT_MARGIN, yStart + VERTICAL_MARGIN);
        CGContextAddLineToPoint(context, self.bounds.origin.x + self.bounds.size.width - RIGHT_MARGIN, yEnd + VERTICAL_MARGIN);
        CGContextAddLineToPoint(context, self.bounds.origin.x + LEFT_MARGIN, yEnd + VERTICAL_MARGIN);
        CGContextClosePath(context);
        
        CGContextDrawPath(context, kCGPathFillStroke);
        
        [[UIColor blackColor] setFill];
        NSString *title = e.title;
        // Draw the title of the event if present.
        if (title && [title length] > 0) {
            UIFont *font = [UIFont systemFontOfSize:12];
            [title drawAtPoint:CGPointMake(self.bounds.origin.x + LEFT_MARGIN + 5, self.bounds.origin.y + VERTICAL_MARGIN + yStart + 5) withFont:font];
            CGContextStrokePath(context);
        }
    }
    
    [gregorianCalendar release];
    
    UIGraphicsPopContext();
}

// Draw the event to be scheduled to show the user where the event
// would be relative to all other events on the same day.
- (void)drawEvent
{
    EKEvent *event = [self.delegate eventForScheduleView:self];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIGraphicsPushContext(context);
    
    CGFloat yMidnight = (self.bounds.size.height - VERTICAL_MARGIN) / 25.0f;
    CGFloat hourSeparation = yMidnight;
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *startDateComponents = [gregorianCalendar components:(NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:event.startDate];
    NSDateComponents *endDateComponents = [gregorianCalendar components:(NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:event.endDate];
    int startHour = [startDateComponents hour];
    int startMinute = [startDateComponents minute];
    int endHour = [endDateComponents hour];
    int endMinute = [endDateComponents minute];
    
    [gregorianCalendar release];
    
    CGFloat yStart = hourSeparation * startHour + (hourSeparation / 60.0f) * startMinute;
    CGFloat yEnd = hourSeparation * endHour + (hourSeparation / 60.f) * endMinute;
    
    [[UIColor redColor] setStroke]; // Red outline to distinguish from the other events
    [[ScheduleView randomColor] setFill];
    CGContextSetLineWidth(context, 2.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.bounds.origin.x + LEFT_MARGIN, self.bounds.origin.y + yStart + VERTICAL_MARGIN);
    CGContextAddLineToPoint(context, self.bounds.origin.x + self.bounds.size.width - RIGHT_MARGIN, self.bounds.origin.y + yStart + VERTICAL_MARGIN);
    CGContextAddLineToPoint(context, self.bounds.origin.x + self.bounds.size.width - RIGHT_MARGIN, self.bounds.origin.y + yEnd + VERTICAL_MARGIN);
    CGContextAddLineToPoint(context, self.bounds.origin.x + LEFT_MARGIN, self.bounds.origin.y + yEnd + VERTICAL_MARGIN);
    CGContextClosePath(context);
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    UIGraphicsPopContext();
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self drawLines];
    [self drawEvents];
    [self drawEvent];
}

- (void)dealloc
{
    [super dealloc];
}

@end
