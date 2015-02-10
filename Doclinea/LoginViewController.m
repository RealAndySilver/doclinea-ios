//
//  ViewController.m
//  Doclinea
//
//  Created by Developer on 29/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "LoginViewController.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "DeviceInfo.h"
#import "ForgotPassViewController.h"

@interface LoginViewController () <UITextFieldDelegate, ServerCommunicatorDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *textfieldsContainer;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (strong, nonatomic) NSString *encodedEmail;
@end

@implementation LoginViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupNotifications];
    if ([self userExist]) {
        [self goToHomeScreen];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Custom Initialization Stuff 

-(void)setupNotifications {
    //Add ourselfs as an observer of the keyboard notifications,
    //to move the textfields when the keyboard appears and dissapears
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Actions

-(void)goToHomeScreen {
    UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)loginButtonPressed:(id)sender {
    if ([self formIsCorrect]) {
        [self authenticateUser];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Hay campos sin información" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

#pragma mark - Form Validation 

-(BOOL)formIsCorrect {
    if ([self.emailTextfield.text length] > 0 && [self.passwordTextfield.text length] > 0) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Server Stuff

-(void)sendVerificationAgain {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    self.encodedEmail = [[self.emailTextfield.text dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSString *parameters = [NSString stringWithFormat:@"email=%@", self.emailTextfield.text];
    
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"Account/SendEmailVerification/%@/%@", @"user", self.encodedEmail] andParameter:parameters httpMethod:@"POST"];
}

-(void)authenticateUser {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    /*NSDictionary *deviceInfoDic = @{@"type" : [UIDevice currentDevice].model, @"token" : [DeviceInfo sharedInstance].deviceToken, @"name" : [UIDevice currentDevice].name, @"os" : @"iOS"};
    NSData *deviceInfoData = [NSJSONSerialization dataWithJSONObject:deviceInfoDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *deviceInfoString = [[NSString alloc] initWithData:deviceInfoData encoding:NSUTF8StringEncoding];*/
    NSString *deviceInfoString = @"";
    
    //Encode user password
    NSString *encodedPassword = [[self.passwordTextfield.text dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    
    NSString *userParameters = [NSString stringWithFormat:@"email=%@&password=%@&device_info=%@", self.emailTextfield.text, encodedPassword, deviceInfoString];
    [serverCommunicator callServerWithPOSTMethod:@"User/Authenticate" andParameter:userParameters httpMethod:@"POST"];
}

#pragma mark - ServerCommunicatorDelegate

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:@"User/Authenticate"]) {
        NSLog(@"Respuetaaaa: %@", dictionary);
        if (dictionary) {
            NSLog(@"Resputa correcta del authenticate: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                //Succesfull authentication...Create the User object and save it in NSUserDefaults
                User *user = [[User alloc] initWithUserDictionary:dictionary[@"response"]];
                [self saveUserInUserDefaults:user];
                
                //The user can pass to the home screen
                [self goToHomeScreen];
            
            } else  {
                //There was an error in the authentication
                if ([dictionary[@"error_id"] intValue] == 0) {
                    //User not found in the database
                    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Usuario no encontrado" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                    
                } else if ([dictionary[@"error_id"] intValue] == 1) {
                    //Email account not confirmed...Show an alert and give the option to send again the confirmation email
                    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Tu cuenta no ha sido confirmada. ¿Quieres que te reenviémos el correo de confirmación?" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Reenviar", nil] show];
                }
            }
        } else {
            NSLog(@"Respuesta incorrecta del authenticate: %@", dictionary);
        }
        
    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"Account/SendEmailVerification/%@/%@", @"user", self.encodedEmail]]) {
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
    
    //Inform the user that there was an error in the server
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Hubo un error al intentar iniciar sesión. Por favor revisa que estés conectado a internet e intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - User Defaults 

-(BOOL)userExist {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
        return YES;
    } else {
        return NO;
    }
}

-(void)saveUserInUserDefaults:(User *)user {
    //It's necessary to encode our User object as an NSData object to save it in NSUserDefaults
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:user];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:@"user"];
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
            forgotPassVC.userType = @"user";
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
