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

@interface AppointmentsListViewController () <UITableViewDataSource, UITableViewDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation AppointmentsListViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 140.0;
    [self getAppointmentsInServer];
}

#pragma mark - Actions 

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppointmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppointmentCell"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"AppointmentCell" bundle:nil] forCellReuseIdentifier:@"AppointmentCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"AppointmentCell"];
    }
    return cell;
}

#pragma mark - Server Stuff
//Appointment/GetForUser/user_id

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
            } else {
                NSLog(@"Rsputa incorrecta del get appointments: %@", dictionary);
            }
            
        } else {
            NSLog(@"Respuesta null de get appointments: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Error en el servidor: %@", [error localizedDescription]);
}

@end
