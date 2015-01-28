//
//  SearchByLocationViewController.m
//  Doclinea
//
//  Created by Developer on 8/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "SearchByLocationViewController.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"
#import "Doctor.h"
#import "DoctorsListViewController.h"
@import CoreLocation;

@interface SearchByLocationViewController () <UITextFieldDelegate, CLLocationManagerDelegate, ServerCommunicatorDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *metersTextfield;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *userLocation;
@property (strong, nonatomic) NSArray *distancesArray;
@end

@implementation SearchByLocationViewController

#pragma mark - Lazy Instantiation

-(NSArray *)distancesArray {
    if (!_distancesArray) {
        _distancesArray = @[@"1000", @"2000", @"5000", @"10000"];
    }
    return _distancesArray;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getUserLocation];
    [self setupUI];
}

#pragma mark - Custom Initialization Stuff

-(void)setupUI {
    //Set the picker for the meters textfield
    UIPickerView *metersPickerView = [[UIPickerView alloc] init];
    metersPickerView.delegate = self;
    metersPickerView.dataSource = self;
    self.metersTextfield.inputView = metersPickerView;
    
    //Set the done button for the picker
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissPicker)];
    [toolbar setItems:@[doneButton]];
    self.metersTextfield.inputAccessoryView = toolbar;
}

-(void)getUserLocation {
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = 500;
    [self.locationManager startUpdatingLocation];
}

#pragma mark - Actions 

-(void)dismissPicker {
    [self.metersTextfield resignFirstResponder];
}

- (IBAction)viewTapped:(id)sender {
    [self.metersTextfield resignFirstResponder];
}

- (IBAction)searchButtonPressed:(id)sender {
    [self getNearDoctors];
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

-(void)getNearDoctors {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSUInteger meters;
    if ([self.metersTextfield.text length] > 0) {
        meters = [self.metersTextfield.text intValue];
    } else {
        meters = 10000;
    }
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameters = [NSString stringWithFormat:@"lat=%f&lon=%f&meters=%lu", self.userLocation.coordinate.latitude, self.userLocation.coordinate.longitude, (unsigned long)meters];
    [serverCommunicator callServerWithPOSTMethod:@"Doctor/GetByParams" andParameter:parameters httpMethod:@"POST"];
}

#pragma mark - ServerCommunicatorDelegate

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:@"Doctor/GetByParams"]) {
        if (dictionary){
            NSLog(@"Respuesta correcta del get doctor: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                [self saveDoctorsUsingArray:dictionary[@"response"]];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"No se encontraron doctores que se encuentren a la distancia escogida" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        } else {
            NSLog(@"Error en la respuesta del get doctor: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Error: %@", [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Hubo un error al intentar buscar los doctores. Por favor intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.distancesArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%@m", self.distancesArray[row]];
}

#pragma mark - UIPickerViewDelegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.metersTextfield.text = [NSString stringWithFormat:@"%@m", self.distancesArray[row]];
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"Encontré una locacion");
    //Get the most recent location
    self.userLocation = [locations lastObject];
    NSLog(@"Datos de la locación: %f - %f", self.userLocation.coordinate.latitude, self.userLocation.coordinate.longitude);
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error obteniendo la locacion: %@", [error localizedDescription]);
}

@end
