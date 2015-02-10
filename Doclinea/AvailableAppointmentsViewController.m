//
//  AvailableAppointmentsViewController.m
//  Doclinea
//
//  Created by Developer on 22/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "AvailableAppointmentsViewController.h"
#import "MyTextfield.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"
#import "Appointment.h"
#import "AppointmentsParser.h"
#import "AvailableAppointmentCell.h"
#import "AppointmentConfirmationViewController.h"

@interface AvailableAppointmentsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ServerCommunicatorDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet MyTextfield *monthTextfield;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *availableAppointments;
@property (assign, nonatomic) NSUInteger currentMonth;
@property (assign, nonatomic) NSUInteger currentDay;
@property (strong, nonatomic) NSArray *monthsArray;
@property (strong, nonatomic) NSArray *parsedAppointmentsArray;
@end

@implementation AvailableAppointmentsViewController

-(NSArray *)parsedAppointmentsArray {
    if (!_parsedAppointmentsArray) {
        _parsedAppointmentsArray = @[];
    }
    return _parsedAppointmentsArray;
}

-(NSArray *)monthsArray {
    if (!_monthsArray) {
        _monthsArray = @[];
    }
    return _monthsArray;
}

-(NSArray *)availableAppointments {
    if (!_availableAppointments) {
        _availableAppointments = @[@{@"day" : @"enero 10", @"appointmentsNumber" : @15},
                                   @{@"day" : @"enero 11", @"appointmentsNumber" : @7},
                                   @{@"day" : @"enero 12", @"appointmentsNumber" : @10},
                                   @{@"day" : @"enero 13", @"appointmentsNumber" : @8}];
    }
    return _availableAppointments;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getAvailableAppointments];
    self.currentMonth = 0;
    self.currentDay = 0;
    [self setupUI];
}

-(void)setupUI {
    UIPickerView *monthPicker = [[UIPickerView alloc] init];
    monthPicker.delegate = self;
    monthPicker.dataSource = self;
    self.monthTextfield.inputView = monthPicker;
    
    //Create a toolbar for our picker view
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(inputAccessoryViewDidFinish)];
    [toolbar setItems:@[doneButton] animated:NO];
    self.monthTextfield.inputAccessoryView = toolbar;
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)inputAccessoryViewDidFinish {
    [self.monthTextfield resignFirstResponder];
}

- (IBAction)leftButtonPressed:(id)sender {
    if (self.currentDay == 0) {
        //Dont do anything, we are in the first page
    } else {
        self.currentDay--;
        [self updateUI];
        [self.collectionView reloadData];
    }
}

- (IBAction)rightButtonPressed:(id)sender {
    if (self.currentDay == [self.parsedAppointmentsArray[self.currentMonth][@"daysWithAppointments"] count] - 1) {
        //We are on the last page, don't do anything
    } else {
        self.currentDay++;
        [self updateUI];
        [self.collectionView reloadData];
    }
}

-(void)updateUI {
    //self.dayLabel.text = self.availableAppointments[self.currentMonth][@"day"];
    self.dayLabel.text = [NSString stringWithFormat:@"%@ %@", self.parsedAppointmentsArray[self.currentMonth][@"month"], self.parsedAppointmentsArray[self.currentMonth][@"daysWithAppointments"][self.currentDay][@"day"]];
    self.monthTextfield.text = [NSString stringWithFormat:@"Mes: %@", self.parsedAppointmentsArray[self.currentMonth][@"month"]];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //return [self.availableAppointments[self.currentMonth][@"appointmentsNumber"] intValue];
    if (self.parsedAppointmentsArray.count > 0) {
        return [self.parsedAppointmentsArray[self.currentMonth][@"daysWithAppointments"][self.currentDay][@"appointments"] count];
    } else {
        return 0;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AvailableAppointmentCell *cell = (AvailableAppointmentCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"AvailableAppointmentCell" forIndexPath:indexPath];
    
    Appointment *appointment = self.parsedAppointmentsArray[self.currentMonth][@"daysWithAppointments"][self.currentDay][@"appointments"][indexPath.item];
    NSLog(@"HOurrrrr: %@", appointment.startDate);
    cell.appointmentHourLabel.text = appointment.startHour;
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Appointment *selectedAppointment = self.parsedAppointmentsArray[self.currentMonth][@"daysWithAppointments"][self.currentDay][@"appointments"][indexPath.item];
    NSLog(@"Selected appintment: %@", selectedAppointment.info);
    [self goToConfirmationVCWithAppointment:selectedAppointment];
}

#pragma mark - Navigation 

-(void)goToConfirmationVCWithAppointment:(Appointment *)appointment {
    AppointmentConfirmationViewController *confirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AppointmentConfirmation"];
    confirmationVC.appointment = appointment;
    confirmationVC.doctor = self.doctor;
    [self.navigationController pushViewController:confirmationVC animated:YES];
}

#pragma mark - Server Stuff

-(void)getAvailableAppointments {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:[NSString stringWithFormat:@"Appointment/GetAvailableForDoctor/%@", self.doctor.identifier] andParameter:@""];
}

#pragma mark - ServerCommunicatorDelegate

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:[NSString stringWithFormat:@"Appointment/GetAvailableForDoctor/%@", self.doctor.identifier]]) {
        if (dictionary) {
            if ([dictionary[@"status"] boolValue]) {
                NSLog(@"Respuesta correcta del get appointments: %@", dictionary);
                if ([dictionary[@"response"] count] > 0 && [dictionary[@"response"] isKindOfClass:[NSArray class]]) {
                    [self parseAppointmentsFromArray:dictionary[@"response"]];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"El doctor no tiene citas disponibles en este momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                }
            } else {
                NSLog(@"Respuesta incorrecta del get appointments: %@", dictionary);
            }
            
        } else {
            NSLog(@"Respuesta null del get appointments: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error accediendo a las citas del doctor. por favor intenta de nuevo" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Parse Appointments

-(void)parseAppointmentsFromArray:(NSArray *)appointments {
    if (appointments != nil && appointments.count > 0) {
        NSMutableArray *tempAppointmentsArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < appointments.count; i++) {
            Appointment *appointment = [[Appointment alloc] initWithDictionary:appointments[i]];
            [tempAppointmentsArray addObject:appointment];
            NSLog(@"APpointment details: %@", appointment.info);
        }
        self.parsedAppointmentsArray = [AppointmentsParser getOrderedAppointmentsFromArray:tempAppointmentsArray];
        [self.collectionView reloadData];
        [self updateUI];
    }
}

#pragma mark - UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.parsedAppointmentsArray.count > 0) {
        return self.parsedAppointmentsArray.count;
    } else {
        return 0;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    //return self.monthsArray[row];
    if (self.parsedAppointmentsArray.count > 0) {
        return self.parsedAppointmentsArray[row][@"month"];
    } else {
        return @"";
    }
}

#pragma mark - UIPickerViewDataSource

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.currentMonth = row;
    self.currentDay = 0;
    self.monthTextfield.text = [NSString stringWithFormat:@"Mes: %@", self.parsedAppointmentsArray[self.currentMonth][@"month"]];
    [self updateUI];
    [self.collectionView reloadData];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //No appointments alert
    [self.navigationController popViewControllerAnimated:YES];
}

@end
