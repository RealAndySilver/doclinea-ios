//
//  SearchByNameViewController.m
//  Doclinea
//
//  Created by Developer on 3/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "SearchByNameViewController.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"
#import "Doctor.h"
#import "DoctorsListViewController.h"

@interface SearchByNameViewController () <ServerCommunicatorDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;
@end

@implementation SearchByNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Actions 

- (IBAction)searchButtonPressed:(id)sender {
    [self searchDoctorsInServer];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

-(void)goToDoctorsListWithDoctors:(NSArray *)doctors {
    DoctorsListViewController *doctorsListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DoctorsList"];
    doctorsListVC.doctors = doctors;
    [self.navigationController pushViewController:doctorsListVC animated:YES];
}

#pragma mark - Parse Info From Server Stuff

-(void)saveDoctorsUsingArray:(NSArray *)doctorsArray {
    NSMutableArray *doctors = [[NSMutableArray alloc] initWithCapacity:[doctorsArray count]];
    for (int i = 0; i < [doctorsArray count]; i++) {
        NSDictionary *doctorDic = doctorsArray[i];
        Doctor *doctor = [[Doctor alloc] initWithDoctorInfo:doctorDic];
        [doctors addObject:doctor];
    }
    [self goToDoctorsListWithDoctors:doctors];
}

#pragma mark - Server Stuff 

-(void)searchDoctorsInServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameters = [NSString stringWithFormat:@"name=%@&lastname=%@", self.nameTextfield.text, self.lastNameTextfield.text];
    [serverCommunicator callServerWithPOSTMethod:@"Doctor/GetByParams" andParameter:parameters httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:@"Doctor/GetByParams"]) {
        if (dictionary) {
            NSLog(@"Rspuesta correcta del get doctors: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                [self saveDoctorsUsingArray:dictionary[@"response"]];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"No se encontró ningún doctor" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        } else {
            NSLog(@"Resputa incorrecta del get doctors: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Sever error : %@ %@" , error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Hubo un error al buscar los doctores. Por favor revisa que estés conectado a internet" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
