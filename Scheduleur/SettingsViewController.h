//
//  SettingsViewController.h
//  Scheduleur
//
//  Created by Michael Duong on 6/15/11.
//  Copyright 2011 Ambitiouxs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "InfoViewController.h"


@interface SettingsViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    IBOutlet UITextField *userNameField;
    IBOutlet UIButton *emailButton;
    IBOutlet UIButton *infoButton;
}

@end
