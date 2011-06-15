//
//  EventTableViewCell.h
//  SmartSchedulr
//
//  Created by Michael Duong on 6/5/11.
//  Copyright 2011 Ambitiouxs Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EventTableViewCell : UITableViewCell

@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain) UILabel *location;
@property (nonatomic, retain) UILabel *date;
@property (nonatomic, retain) UILabel *time;
@property (nonatomic, retain) UILabel *userName;

@end
