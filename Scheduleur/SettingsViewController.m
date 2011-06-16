//
//  SettingsViewController.m
//  Scheduleur
//
//  Created by Michael Duong on 6/15/11.
//  Copyright 2011 Ambitiouxs. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController

- (void)setup
{
    self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"gear_icon.png"] tag:1] autorelease];
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
        self.title = @"Settings";
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] valueForKey:@"userName"];
    if (userName && [userName length] > 0) {
        userNameField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"userName"];
    } else {
        userNameField.text = [[UIDevice currentDevice] name];
    }
}

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITextField class]])
            [view resignFirstResponder];
    }    
}

- (IBAction)nameChanged
{
    if ([userNameField.text length] > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:userNameField.text forKey:@"userName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSString *userName = [[NSUserDefaults standardUserDefaults] valueForKey:@"userName"];
        if (userName && [userName length] > 0) {
            userNameField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"userName"];
        } else {
            userNameField.text = [[UIDevice currentDevice] name];
        }
    }
}

- (IBAction)emailPressed
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:[NSArray arrayWithObject:@"support@scheduleur.com"]];
        
        [self presentModalViewController:mailViewController animated:YES];
        [mailViewController release];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device is unable to send email in its current state." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)infoButtonPressed
{
    InfoViewController *infoViewController = [[InfoViewController alloc] init];
    [self presentModalViewController:infoViewController animated:YES];
    [infoViewController release];
}

@end
