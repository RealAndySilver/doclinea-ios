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

@interface LoginViewController () <UITextFieldDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UIView *textfieldsContainer;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@end

@implementation LoginViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
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

-(void)setupUI {
    self.emailTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
}

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

-(void)authenticateUser {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSDictionary *deviceInfoDic = @{@"type" : [UIDevice currentDevice].model, @"token" : [DeviceInfo sharedInstance].deviceToken, @"name" : [UIDevice currentDevice].name, @"os" : @"iOS"};
    NSData *deviceInfoData = [NSJSONSerialization dataWithJSONObject:deviceInfoDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *deviceInfoString = [[NSString alloc] initWithData:deviceInfoData encoding:NSUTF8StringEncoding];
    
    //Encode user password
    NSString *encodedPassword = [[self.passwordTextfield.text dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    
    NSString *userParameters = [NSString stringWithFormat:@"email=%@&password=%@&device_info=%@", self.emailTextfield.text, encodedPassword, deviceInfoString];
    [serverCommunicator callServerWithPOSTMethod:@"User/Authenticate" andParameter:userParameters httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:@"User/Authenticate"]) {
        NSLog(@"Respuetaaaa: %@", dictionary);
        if (dictionary) {
            NSLog(@"Resputa correcta del authenticate: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                //Successull authenticate
                User *user = [[User alloc] initWithUserDictionary:dictionary[@"response"]];
                [self saveUserInUserDefaults:user];
                [self goToHomeScreen];
            
            } else  {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Usuario no encontrado" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        } else {
            NSLog(@"Respuesta incorrecta del authenticate: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Server errorrr: %@ %@", error, [error localizedDescription]);
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

@end
