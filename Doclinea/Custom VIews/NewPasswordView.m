//
//  NewPasswordView.m
//  Doclinea
//
//  Created by Developer on 16/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "NewPasswordView.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"

@interface NewPasswordView() <UITextFieldDelegate, ServerCommunicatorDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) UITextField *passwordTextfield;
@property (strong, nonatomic) UITextField *confirmPassTextfield;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *userType;
@end

@implementation NewPasswordView

#define ANIMATION_DURATION 0.3

#pragma mark - Lazy Instantiation 

-(NSString *)token {
    if (!_token) {
        _token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    }
    return _token;
}

-(NSString *)userType {
    if (!_userType) {
        _userType = [[NSUserDefaults standardUserDefaults] objectForKey:@"userType"];
    }
    return _userType;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.alpha = 0.0;
        self.layer.cornerRadius = 10.0;
        self.backgroundColor = [UIColor whiteColor];
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        //Main title
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0, frame.size.width - 40.0, 20.0)];
        title.text = @"Crear nueva contraseña";
        title.textColor = [UIColor colorWithRed:34.0/255.0 green:159.0/255.0 blue:225.0/255.0 alpha:1.0];
        title.font = [UIFont fontWithName:@"OpenSans" size:18.0];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];
        
        //Passwrod textfield
        self.passwordTextfield = [[UITextField alloc] initWithFrame:CGRectMake(20.0, title.frame.origin.y + title.frame.size.height + 20.0, frame.size.width - 40.0, 30.0)];
        self.passwordTextfield.borderStyle = UITextBorderStyleRoundedRect;
        self.passwordTextfield.textColor = [UIColor darkGrayColor];
        self.passwordTextfield.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        self.passwordTextfield.placeholder = @"Nueva Contraseña";
        self.passwordTextfield.delegate = self;
        self.passwordTextfield.secureTextEntry = YES;
        [self addSubview:self.passwordTextfield];
        
        //Confirm Pass Textfield
        self.confirmPassTextfield = [[UITextField alloc] initWithFrame:CGRectMake(20.0, self.passwordTextfield.frame.origin.y + self.passwordTextfield.frame.size.height + 20.0, frame.size.width - 40.0, 30.0)];
        self.confirmPassTextfield.borderStyle = UITextBorderStyleRoundedRect;
        self.confirmPassTextfield.textColor = [UIColor darkGrayColor];
        self.confirmPassTextfield.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        self.confirmPassTextfield.placeholder = @"Confirmar Contraseña";
        self.confirmPassTextfield.delegate = self;
        self.confirmPassTextfield.secureTextEntry = YES;
        [self addSubview:self.confirmPassTextfield];
        
        //Ok button
        UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(60.0, self.confirmPassTextfield.frame.origin.y + self.confirmPassTextfield.frame.size.height + 20.0, frame.size.width - 120.0, 30.0)];
        [okButton setTitle:@"OK" forState:UIControlStateNormal];
        [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        okButton.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:159.0/255.0 blue:225.0/255.0 alpha:1.0];
        okButton.layer.cornerRadius = 5.0;
        okButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14.0];
        [okButton addTarget:self action:@selector(okButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:okButton];
    }
    return self;
}

-(void)showInWindow:(UIWindow *)window {
    self.opacityView = [[UIView alloc] initWithFrame:window.bounds];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.0;
    [window addSubview:self.opacityView];
    [window addSubview:self];
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 1.0;
                         self.opacityView.alpha = 0.7;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:nil];
}

-(void)closeView {
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                         self.opacityView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self.opacityView removeFromSuperview];
                         [self removeFromSuperview];
                     }];
}

-(void)okButtonPressed {
    if ([self.passwordTextfield.text length] > 0 && [self.confirmPassTextfield.text length] > 0) {
        if ([self.passwordTextfield.text isEqualToString:self.confirmPassTextfield.text]) {
            [self sendNewPassToServer];
            
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Las contraseñas no coinciden. Por favor escríbelas de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Debes escribir tu nueva contraseña en ambos campos" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

#pragma mark - Server Stuff 

-(void)sendNewPassToServer {
    [MBProgressHUD showHUDAddedTo:self animated:YES];
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    NSString *encodedPassword = [[self.passwordTextfield.text dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    
    if ([self.userType isEqualToString:@"doctor"]) {
        [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"Doctor/NewPassword/%@", self.token] andParameter:[NSString stringWithFormat:@"password=%@", encodedPassword] httpMethod:@"POST"];
    } else if ([self.userType isEqualToString:@"user"]) {
        [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"User/NewPassword/%@", self.token] andParameter:[NSString stringWithFormat:@"password=%@", encodedPassword] httpMethod:@"POST"];
    }
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self animated:YES];
    if ([methodName isEqualToString:[NSString stringWithFormat:@"Doctor/NewPassword/%@", self.token]]) {
        NSLog(@"Respueta del doctor pass: %@", dictionary);
        if ([dictionary[@"status"] boolValue]) {
            [self showSuccessAlert];
        }
        
    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"User/NewPassword/%@", self.token]]) {
        NSLog(@"Respuesta del user pass: %@", dictionary);
        if ([dictionary[@"status"] boolValue]) {
            [self showSuccessAlert];
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self animated:YES];
    NSLog(@"Erorr en el server: %@", [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error en la conexión. Por favor revisa que estés conectado a internet e intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Alerts

-(void)showSuccessAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Éxito!" message:@"La contraseña se ha reestablecido de manera exitosa. Ya puedes ingresar con tu nueva contraseña" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    alert.tag = 1;
    [alert show];
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
        [self closeView];
    }
}

@end
