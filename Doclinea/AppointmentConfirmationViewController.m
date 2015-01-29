//
//  AppointmentConfirmationViewController.m
//  Doclinea
//
//  Created by Developer on 29/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "AppointmentConfirmationViewController.h"
#import "ServerCommunicator.h"
#import "User.h"
#import "MBProgressHUD.h"

@interface AppointmentConfirmationViewController() <UITextFieldDelegate, ServerCommunicatorDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *pacientNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *pacientNumberTextfield;
@property (weak, nonatomic) IBOutlet UITextView *reasonTextView;
@property (weak, nonatomic) IBOutlet UISwitch *isForMeSwitch;
@property (strong, nonatomic) User *user;
@end

@implementation AppointmentConfirmationViewController

#pragma mark - Lazy Instantiation 

-(User *)user {
    if (!_user) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
            NSData *userEncodedData = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
            _user = [NSKeyedUnarchiver unarchiveObjectWithData:userEncodedData];
        }
    }
    return _user;
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI {
    self.reasonTextView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
    self.reasonTextView.layer.borderWidth = 1.0;
    self.reasonTextView.layer.cornerRadius = 5.0;
}

#pragma mark - Actions 

- (IBAction)switchChanged:(UISwitch *)sender {
    if (sender.isOn) {
        self.pacientNameTextfield.enabled = NO;
        self.pacientNameTextfield.alpha = 0.5;
    } else {
        self.pacientNameTextfield.enabled = YES;
        self.pacientNameTextfield.alpha = 1.0;
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)takeAppointmentButtonPressed:(id)sender {
    if ([self formIsValid]) {
        [self takeAppointmentInServer];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Debes completar todos los campos" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

#pragma mark - Form Validation

-(BOOL)formIsValid {
    BOOL patientNameIsCorrect = NO;
    BOOL patientNumberIsCorrect = NO;
    BOOL appointmentReasonIsCorrect = NO;
    
    if (self.isForMeSwitch.isOn) {
        patientNameIsCorrect = YES;
    } else if ([self.pacientNameTextfield.text length] > 0) {
        patientNameIsCorrect = YES;
    } else {
        patientNameIsCorrect = NO;
    }
    
    if ([self.pacientNumberTextfield.text length] > 0) {
        patientNumberIsCorrect = YES;
    } else {
        patientNumberIsCorrect = NO;
    }
    
    if ([self.reasonTextView.text length] > 0) {
        appointmentReasonIsCorrect = YES;
    } else {
        appointmentReasonIsCorrect = NO;
    }
    
    if (patientNumberIsCorrect && patientNameIsCorrect && appointmentReasonIsCorrect) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - ServerCommunicatorDelegate
//Appointment/Take/id del appointment ->  user_id userName Paien phone patientn name patien_is_user status = taken reason
//Appointment/GetForUser/user_id

-(void)takeAppointmentInServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    NSString *pacientName = nil;
    BOOL pacientIsUser = NO;

    if (self.isForMeSwitch.isOn) {
        pacientName = self.user.name;
        pacientIsUser = YES;
    } else {
        pacientName = self.pacientNameTextfield.text;
        pacientIsUser = NO;
    }
    
    NSString *parameters = [NSString stringWithFormat:@"user_id=%@&user_name=%@&patient_phone=%@&patient_name=%@&patient_is_user=%@&status=%@&reason=%@", self.user.identifier, self.user.name, self.pacientNumberTextfield.text, pacientName, @(pacientIsUser), @"taken", self.reasonTextView.text];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"Appointment/Take/%@", self.appointment.identifier] andParameter:parameters httpMethod:@"POST"];
    NSLog(@"PARAMETROOOO: %@", parameters);
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:[NSString stringWithFormat:@"Appointment/Take/%@", self.appointment.identifier]]) {
        if (dictionary) {
            if ([dictionary[@"status"] boolValue]) {
                NSLog(@"Resputa correcta del take appointments: %@", dictionary);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Éxito!" message:@"Cita tomada exitosamente!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                alert.tag = 1;
                [alert show];
                
            } else {
                NSLog(@"Respuesta incorrecta del take appointments: %@", dictionary);
                [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Hubo un problema al intentar reservar la cita. Por favor intenta de nuevo" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            
        } else {
            NSLog(@"Respuat null del take appointment: %@", dictionary);
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Hubo un problema al intentar reservar la cita en el servidor. Por favor intenta de nuevo en un momento" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Error en el serverrr: %@", [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Hubo un error en el servidor. Por favor intenta de nuevo en un momento" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        //Success alert
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
