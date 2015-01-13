//
//  DoctorInsurancesViewController.m
//  Doclinea
//
//  Created by Developer on 9/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "DoctorInsurancesViewController.h"

@interface DoctorInsurancesViewController ()

@end

@implementation DoctorInsurancesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)addInsuranceButtonPressed:(id)sender {
    UINavigationController *insurancesNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"InsurancesNavController"];
    [self presentViewController:insurancesNavController animated:YES completion:nil];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
