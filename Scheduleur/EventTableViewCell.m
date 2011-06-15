//
//  EventTableViewCell.m
//  SmartSchedulr
//
//  Created by Michael Duong on 6/5/11.
//  Copyright 2011 Ambitiouxs Software. All rights reserved.
//

#import "EventTableViewCell.h"


@implementation EventTableViewCell

@synthesize title;
@synthesize location;
@synthesize date;
@synthesize time;
@synthesize userName;

// Custom UITableViewCell for an event.
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        title = [[UILabel alloc] init];
        title.font = [UIFont boldSystemFontOfSize:20];
        
        location = [[UILabel alloc] init];
        location.font = [UIFont systemFontOfSize:14];
        location.textColor = [UIColor lightGrayColor];
        
        UIColor *blue = [UIColor colorWithRed:71.0/256.0 green:98.0/256.0 blue:151.0/256.0 alpha:1.0];
        
        date = [[UILabel alloc] init];
        date.font = [UIFont boldSystemFontOfSize:12];
        date.textColor = blue;
        
        time = [[UILabel alloc] init];
        time.font = [UIFont boldSystemFontOfSize:12];
        time.textColor = blue;
        
        userName = [[UILabel alloc] init];
        userName.font = [UIFont systemFontOfSize:12];
        
        [self.contentView addSubview:title];
        [self.contentView addSubview:location];
        [self.contentView addSubview:date];
        [self.contentView addSubview:time];
        [self.contentView addSubview:userName];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    title.frame = CGRectMake(10, 10, 280, 21);
    location.frame = CGRectMake(10, 30, 280, 21);
    date.frame = CGRectMake(10, 50, 280, 21);
    time.frame = CGRectMake(10, 66, 280, 21);
    userName.frame = CGRectMake(10, 84, 280, 21);
}

- (void)dealloc
{
    [title release];
    [location release];
    [date release];
    [time release];
    [userName release];
    
    [super dealloc];
}

@end
