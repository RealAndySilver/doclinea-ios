//
//  MoreOptionsViewController.m
//  Doclinea
//
//  Created by Developer on 2/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "MoreOptionsViewController.h"
#import "ConfigurationViewController.h"
#import "ChangePasswordViewController.h"

@interface MoreOptionsViewController ()

@end

@implementation MoreOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Actions

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)favoriteDoctorsButtonPressed:(id)sender {

}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ConfigurationSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[ConfigurationViewController class]]) {
            ConfigurationViewController *configVC = (ConfigurationViewController *)segue.destinationViewController;
            configVC.user = self.user;
        }
    
    } else if ([segue.identifier isEqualToString:@"ChangePasswordSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[ChangePasswordViewController class]]) {
            ChangePasswordViewController *changePassVC = (ChangePasswordViewController *)segue.destinationViewController;
            changePassVC.userType = @"user";
        }
    }
}

@end
