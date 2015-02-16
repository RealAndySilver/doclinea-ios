//
//  AppointmentsListViewController.m
//  Doclinea
//
//  Created by Developer on 20/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "AppointmentsListViewController.h"
#import "AppointmentCell.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"
#import "Appointment.h"
#import "Location.h"
#import "UIImageView+WebCache.h"

@interface AppointmentsListViewController () <UITableViewDataSource, UITableViewDelegate, ServerCommunicatorDelegate, AppointmentCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *takenAppointmentsArray;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) Appointment *appointmentToCancel;
@end

@implementation AppointmentsListViewController

#pragma mark - Lazy Instantiation

-(NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        _dateFormatter.locale = [NSLocale currentLocale];
        
    }
    return _dateFormatter;
}

-(NSArray *)takenAppointmentsArray {
    if (!_takenAppointmentsArray) {
        _takenAppointmentsArray = @[];
    }
    return _takenAppointmentsArray;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 240.0;
    [self getAppointmentsInServer];
}

#pragma mark - Actions 

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.takenAppointmentsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppointmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppointmentCell"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"AppointmentCell" bundle:nil] forCellReuseIdentifier:@"AppointmentCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"AppointmentCell"];
    }
    cell.delegate = self;
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(AppointmentCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    Appointment *appointment = self.takenAppointmentsArray[indexPath.row];
    cell.doctorNameLabel.text = appointment.doctorName;
    cell.reasonLabel.text = appointment.reason;
    [cell.doctorImageView sd_setImageWithURL:[NSURL URLWithString:appointment.imageURL] placeholderImage:[UIImage imageNamed:@"DoctorMale"]];
    if (appointment.locations.count > 0) {
        cell.locationNameLabel.text = ((Location *)appointment.locations[0]).locationName;
        cell.locationAddressLabel.text = ((Location *)appointment.locations[0]).locationAddress;
    }
    cell.dateLabel.text = [self.dateFormatter stringFromDate:appointment.startDate];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Server Stuff

-(void)cancelappointment {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"Appointment/Cancel/%@/user", self.appointmentToCancel.identifier] andParameter:[NSString stringWithFormat:@"user_id=%@", self.user.identifier] httpMethod:@"POST"];
}

-(void)getAppointmentsInServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:[NSString stringWithFormat:@"Appointment/GetForUser/%@", self.user.identifier] andParameter:@""];
}

#pragma mark - ServerCommunicatorDelegate

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:[NSString stringWithFormat:@"Appointment/GetForUser/%@", self.user.identifier]]) {
        if (dictionary) {
            if ([dictionary[@"status"] boolValue]) {
                NSLog(@"Resputa correcta del get appointments: %@", dictionary);
                [self parseAppointmentsFromArray:dictionary[@"response"]];
            } else {
                NSLog(@"Rsputa incorrecta del get appointments: %@", dictionary);
            }
            
        } else {
            NSLog(@"Respuesta null de get appointments: %@", dictionary);
        }
    
    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"Appointment/Cancel/%@/user", self.appointmentToCancel.identifier]]) {
        if (dictionary) {
            if ([dictionary[@"status"] boolValue]) {
                //Success
                NSLog(@"Respuesta correcta del cancel appointment: %@", dictionary);
                [[[UIAlertView alloc] initWithTitle:@"Éxito!" message:@"Se ha cancelado la cita satisfactoriamente" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                
                //Remove appointment from array
                NSMutableArray *appointmentsArray = [NSMutableArray arrayWithArray:self.takenAppointmentsArray];
                [appointmentsArray removeObject:self.appointmentToCancel];
                self.takenAppointmentsArray = appointmentsArray;
                [self.tableView reloadData];
                
            } else {
                NSLog(@"Respuesta incorrecta del cancel appointment: %@", dictionary);
                [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"No fue posible cancelar la cita. Por favor intenta de nuevo" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        } else {
            NSLog(@"Resputa null del cancel appointments: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Error en el servidor: %@", [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Ocurrió un error en el servidor. Por favor intenta de nuevo." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Parse Appointments

-(void)parseAppointmentsFromArray:(NSArray *)appointments {
    if (appointments != nil && appointments.count > 0) {
        NSMutableArray *tempAppointmentsArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < appointments.count; i++) {
            Appointment *appointment = [[Appointment alloc] initWithDictionary:appointments[i]];
            if ([appointment.status isEqualToString:@"taken"]) {
                [tempAppointmentsArray addObject:appointment];
            }
            NSLog(@"APpointment details: %@", appointment.info);
        }
        self.takenAppointmentsArray = tempAppointmentsArray;
        [self.tableView reloadData];
    }
}

#pragma mark - AppointmentCellDelegate

-(void)cancelAppointmentPressedInCell:(AppointmentCell *)appointmentCell {
    NSUInteger index = [self.tableView indexPathForCell:appointmentCell].row;
    self.appointmentToCancel = self.takenAppointmentsArray[index];
    NSLog(@"Me llegó el emnsajeeee ene l index: %i", index);
    [self cancelappointment];
}

@end
