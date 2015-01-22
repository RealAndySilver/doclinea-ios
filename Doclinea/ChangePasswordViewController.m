//
//  ChangePasswordViewController.m
//  Doclinea
//
//  Created by Developer on 16/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"
#import "SharedUser.h"
#import "User.h"
#import "Doctor.h"
#import "SharedDoctor.h"

@interface ChangePasswordViewController () <UITextFieldDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *actualPasswordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassTextfield;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Doctor *doctor;
@end

@implementation ChangePasswordViewController

#pragma mark - Lazy Instantiation

-(Doctor *)doctor {
    if (!_doctor) {
        _doctor = [[SharedDoctor sharedDoctor] getSavedDoctor];
    }
    return _doctor;
}

-(User *)user {
    if (!_user) {
        _user = [[SharedUser sharedUser] getSavedUser];
    }
    return _user;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Actions 

- (IBAction)changeButtonPressed:(id)sender {
    if ([self.passwordTextfield.text length] > 0 && [self.actualPasswordTextfield.text length] > 0 && [self.confirmPassTextfield.text length] > 0) {
        if ([self.passwordTextfield.text isEqualToString:self.confirmPassTextfield.text]) {
            [self changePassInServer];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"La nueva contraseña no coincide en ambos campos" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Debes completar todos los campos" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}


- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Server Stuff 

-(void)changePassInServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    NSLog(@"Current pass: %@", self.actualPasswordTextfield.text);
    NSString *encodedOldPassword = [[self.actualPasswordTextfield.text dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSString *encodedNewPassword = [[self.passwordTextfield.text dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    
    if ([self.userType isEqualToString:@"doctor"]) {
        [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"Doctor/ChangePassword/%@", self.doctor.identifier] andParameter:[NSString stringWithFormat:@"password=%@&new_password=%@", encodedOldPassword, encodedNewPassword] httpMethod:@"POST"];
        
    } else {
        [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"User/ChangePassword/%@", self.user.identifier] andParameter:[NSString stringWithFormat:@"password=%@&new_password=%@", encodedOldPassword, encodedNewPassword] httpMethod:@"POST"];
    }
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:[NSString stringWithFormat:@"User/ChangePassword/%@", self.user.identifier]] || [NSString stringWithFormat:@"Doctor/ChangePassword/%@", self.doctor.identifier]) {
        if (dictionary) {
            NSLog(@"Respuesta correcta del change password: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                //Success
                [[[UIAlertView alloc] initWithTitle:@"Éxito!" message:@"La contraseña se ha cambiado exitosamente" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                [self.navigationController popToRootViewControllerAnimated:YES];
            } else {
                //Failure
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"La contraseña actual no coincide con la de tu cuenta" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Error en el server: %@", [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Hubo un error de conexión. Por favor revisa que estés conectado a internet e intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
