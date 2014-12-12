//
//  DoctorLoginViewController.m
//  Doclinea
//
//  Created by Developer on 3/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "DoctorLoginViewController.h"
#import "MBProgressHUD.h"
#import "ServerCommunicator.h"
#import "Doctor.h"
#import "ForgotPassViewController.h"

@interface DoctorLoginViewController () <UITextFieldDelegate, ServerCommunicatorDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UIView *textfieldsContainer;
@property (strong, nonatomic) NSString *encodedEmail;
@end

@implementation DoctorLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNotifications];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Custom Initialization Stuff 

-(void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Actions 
- (IBAction)loginButtonPressed:(id)sender {
    if ([self.emailTextfield.text length] > 0 && [self.passwordTextfield.text length] > 0) {
        [self loginDoctorInServer];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Debes completar ambos campos" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

- (IBAction)forgotPassButtonPressed:(id)sender {
    
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Server Stuff 

-(void)sendVerificationAgain {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    self.encodedEmail = [[self.emailTextfield.text dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSString *parameters = [NSString stringWithFormat:@"email=%@", self.emailTextfield.text];
    
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"Account/SendEmailVerification/%@/%@", @"doctor", self.encodedEmail] andParameter:parameters httpMethod:@"POST"];
}

-(void)loginDoctorInServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    //Encode user password
    NSString *encodedPassword = [[self.passwordTextfield.text dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    
    NSString *parameters = [NSString stringWithFormat:@"email=%@&password=%@", self.emailTextfield.text, encodedPassword];
    [serverCommunicator callServerWithPOSTMethod:@"Doctor/Authenticate" andParameter:parameters httpMethod:@"POST"];
}

//Doctor/Recover/email del doc

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:@"Doctor/Authenticate"]) {
        NSLog(@"Respuestaaaa: %@", dictionary);
        if (dictionary) {
            NSLog(@"Respuesta correcta del authenticate doctor: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                //Successfull authentication
                Doctor *doctor = [[Doctor alloc] initWithDoctorInfo:dictionary[@"response"]];
                [self saveDoctorInUserDefaults:doctor];
                [self goToDoctorHomePage];
                
            } else {
                if ([dictionary[@"error_id"] intValue] == 0) {
                    //Usuario no encontrado
                    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Usuario no encontrado" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                } else if ([dictionary[@"error_id"] intValue] == 1) {
                    //Cuenta no confirmada
                    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Tu cuenta no ha sido confirmada. ¿Quieres que te reenviémos el correo de confirmación?" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Reenviar", nil] show];
                }
            }
        } else {
            NSLog(@"Repuesta incorrecta del authenticate doctor: %@", dictionary);
        }
    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"Account/SendEmailVerification/%@/%@", @"doctor", self.encodedEmail]]) {
        if (dictionary) {
            NSLog(@"Respuesta correcta del send verification again: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                //Email verification sent successfully
                [[[UIAlertView alloc] initWithTitle:@"Éxito!" message:@"El correo de verificación se ha enviado correctamente" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            } else {
                //Email not send, there was an error
                [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Hubo un error reenviando el correo de verificación" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        } else {
            NSLog(@"Reespuesta incorrecta del sendverification: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Error ene le server: %@ %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Hubo un error intentando ingresar. Por favor revisa que estés conectado a internet e intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Navigation 

-(void)goToDoctorHomePage {
    UITabBarController *tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"DoctorTabBarController"];
    [self presentViewController:tabBarController animated:YES completion:nil];
}

#pragma mark - User Defaults 

-(void)saveDoctorInUserDefaults:(Doctor *)doctor {
    NSLog(@"NOMBRE DEL DOCTOR A GUARDA: %@", doctor.name);
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:doctor];
    [[NSUserDefaults standardUserDefaults] setObject:encodedData forKey:@"doctor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Notification Handlers

-(void)keyboardWillShow {
    //Move the textfields up
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.textfieldsContainer.transform = CGAffineTransformMakeTranslation(0.0, -100.0);
                     } completion:nil];
}

-(void)keyboardWillHide {
    //Move the textfields down
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.textfieldsContainer.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                     } completion:nil];
}

#pragma mark - Navigation 

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ForgotPasswordSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[ForgotPassViewController class]]) {
            ForgotPassViewController *forgotPassVC = (ForgotPassViewController *)segue.destinationViewController;
            forgotPassVC.userType = @"doctor";
        }
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self sendVerificationAgain];
    }
}

@end
