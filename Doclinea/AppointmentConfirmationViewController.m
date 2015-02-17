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
#import "InsuranceConfirmationViewController.h"

@interface AppointmentConfirmationViewController() <UITextFieldDelegate, ServerCommunicatorDelegate, UIAlertViewDelegate, InsuranceConfirmationDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *insuranceTextfield;
@property (weak, nonatomic) IBOutlet UITextField *pacientNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *pacientNumberTextfield;
@property (weak, nonatomic) IBOutlet UITextView *reasonTextView;
@property (weak, nonatomic) IBOutlet UISwitch *isForMeSwitch;
@property (assign, nonatomic) NSUInteger selectedInsuranceIndex;
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
    BOOL insuranceIsCorrect = NO;
    
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
    
    if ([self.insuranceTextfield.text length] > 0) {
        insuranceIsCorrect = YES;
    } else {
        insuranceIsCorrect = NO;
    }
    
    if (patientNumberIsCorrect && patientNameIsCorrect && appointmentReasonIsCorrect && insuranceIsCorrect) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - ServerCommunicatorDelegate

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
    
    NSArray *selectedInsuranceArray;
    if (self.selectedInsuranceIndex == 0) {
        //User selected "Pagaré cita particular"
        selectedInsuranceArray = @[@{@"insurance" : @"", @"insurance_type" : @""}];
    } else {
        //User selected insurance
        selectedInsuranceArray = @[@{@"insurance" : self.doctor.insuranceList[self.selectedInsuranceIndex - 1][@"insurance"], @"insurance_type" : self.doctor.insuranceList[self.selectedInsuranceIndex - 1][@"insurance_type"]}];
    }
    NSData *insuranceData = [NSJSONSerialization dataWithJSONObject:selectedInsuranceArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *insuranceString = [[NSString alloc] initWithData:insuranceData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Selecte insurance: %@", selectedInsuranceArray);
    
    NSString *parameters = [NSString stringWithFormat:@"user_id=%@&user_name=%@&patient_phone=%@&patient_name=%@&patient_is_user=%@&status=%@&reason=%@&insurance=%@", self.user.identifier, self.user.name, self.pacientNumberTextfield.text, pacientName, @(pacientIsUser), @"taken", self.reasonTextView.text, insuranceString];
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

#pragma mark - Navigation

-(void)goToInsuranceConfirmation {
    InsuranceConfirmationViewController *insuranceConfirmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"InsuranceConfirmation"];
    insuranceConfirmVC.doctor = self.doctor;
    insuranceConfirmVC.delegate = self;
    [self.navigationController pushViewController:insuranceConfirmVC animated:YES];
}

#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 1) {
        //Insurance textfield
        [self goToInsuranceConfirmation];
        return NO;
    }
    return YES;
}

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

#pragma mark - InsuranceConfirmationDelegate 

-(void)insuranceSelectedAtIndex:(NSUInteger)index {
    NSLog(@"Me llegó el index: %i", index);
    self.selectedInsuranceIndex = index;
    if (index == 0) {
        //User selected "Pagaré cita particular"
        self.insuranceTextfield.text = @"Pagaré cita particular";
    } else {
        self.insuranceTextfield.text = [NSString stringWithFormat:@"%@ - %@", self.doctor.insuranceList[index - 1][@"insurance"], self.doctor.insuranceList[index - 1][@"insurance_type"]];
    }
}

@end
