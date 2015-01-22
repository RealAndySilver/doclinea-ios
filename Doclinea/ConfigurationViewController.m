//
//  ConfigurationViewController.m
//  Doclinea
//
//  Created by Developer on 20/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"

@interface ConfigurationViewController () <ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *emailAppointmentSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *emailMarketingSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *mobileAppointmentSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *mobileMarketingSwitch;
@end

@implementation ConfigurationViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI {
    self.emailAppointmentSwitch.on = self.user.settings.emailAppointmentNotifications;
    self.emailMarketingSwitch.on = self.user.settings.emailMarketingNotifications;
    self.mobileAppointmentSwitch.on = self.user.settings.mobileAppointmentNotifications;
    self.mobileMarketingSwitch.on = self.user.settings.mobileMarketingNotifications;
}

#pragma mark - Actions

- (IBAction)saveButtonPressed:(id)sender {
    [self saveSettingsInServer];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Server Stuff

-(void)saveSettingsInServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    NSDictionary *settingsDic = @{@"email_appointment_notifications" : @(self.emailAppointmentSwitch.isOn),
                                  @"email_marketing_notifications" : @(self.emailMarketingSwitch.isOn),
                                  @"mobile_appointment_notifications" : @(self.mobileAppointmentSwitch.isOn),
                                  @"mobile_marketing_notifications" : @(self.mobileMarketingSwitch.isOn)};
    NSData *settingsData = [NSJSONSerialization dataWithJSONObject:settingsDic options:0 error:nil];
    NSString *settingsString = [[NSString alloc] initWithData:settingsData encoding:NSUTF8StringEncoding];
    
    NSString *userParameters = [NSString stringWithFormat:@"settings=%@", settingsString];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"User/Update/%@", self.user.identifier] andParameter:userParameters httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:[NSString stringWithFormat:@"User/Update/%@", self.user.identifier]]) {
        if (dictionary) {
            if ([dictionary[@"status"] boolValue]) {
                NSLog(@"Actualización exitosa: %@", dictionary);
                [self saveUpdatedUserWithDic:dictionary[@"response"]];
                [self.delegate userUpdatedInConfigVC];
                [[[UIAlertView alloc] initWithTitle:@"Éxito!" message:@"Configuración actualizada correctamente." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                [self.navigationController popViewControllerAnimated:YES];
                
            } else {
                NSLog(@"No se pudo actualizar, algo pasó: %@", dictionary);
            }
        } else {
            NSLog(@"Resputa null del update: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Ocurrió un error en el servidor. Por favor intenta de nuevo en un momento." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - User Defaults

-(void)saveUpdatedUserWithDic:(NSDictionary *)userDic {
    User *user = [[User alloc] initWithUserDictionary:userDic];
    NSData *encodedUser = [NSKeyedArchiver archivedDataWithRootObject:user];
    [[NSUserDefaults standardUserDefaults] setObject:encodedUser forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
