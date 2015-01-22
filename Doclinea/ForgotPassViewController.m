//
//  DoctorForgotPassViewController.m
//  Doclinea
//
//  Created by Developer on 16/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "ForgotPassViewController.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"

@interface ForgotPassViewController () <UITextFieldDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@end

@implementation ForgotPassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Actions

- (IBAction)sendButtonPressed:(id)sender {
    if ([self.emailTextfield.text length] > 0) {
        [self sendForgotPassToServer];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Debes escribir una dirección de correo electrónico." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Server Stuff 

-(void)sendForgotPassToServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    if ([self.userType isEqualToString:@"doctor"]) {
        [serverCommunicator callServerWithGETMethod:[NSString stringWithFormat:@"Doctor/Recover/%@", self.emailTextfield.text] andParameter:@""];
    } else {
        [serverCommunicator callServerWithGETMethod:[NSString stringWithFormat:@"User/Recover/%@", self.emailTextfield.text] andParameter:@""];
    }
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:[NSString stringWithFormat:@"Doctor/Recover/%@", self.emailTextfield.text]] || [methodName isEqualToString:[NSString stringWithFormat:@"User/Recover/%@", self.emailTextfield.text]]) {
        NSLog(@"Respuesta del recover: %@", dictionary);
        if ([dictionary[@"status"] boolValue]) {
            //Success
            [[[UIAlertView alloc] initWithTitle:@"Éxito!" message:@"Se te ha enviado un correo electrónico con las instrucciones para reestablecer tu contraseña" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            //Failure
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No se ha encontrado ningún doctor con ese correo electrónico" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en la conexión. Por favor revisa que estés conectado a internet" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    NSLog(@"Error de serverrr: %@", [error localizedDescription]);
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
