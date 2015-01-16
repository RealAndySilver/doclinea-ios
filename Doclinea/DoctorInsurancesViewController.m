//
//  DoctorInsurancesViewController.m
//  Doclinea
//
//  Created by Developer on 9/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "DoctorInsurancesViewController.h"
#import "InsurancesListViewController.h"
#import "ServerCommunicator.h"
#import "Doctor.h"
#import "SharedDoctor.h"
#import "MBProgressHUD.h"

@interface DoctorInsurancesViewController () <ServerCommunicatorDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) Doctor *doctor;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *doctorInsurancesArray;
@end

@implementation DoctorInsurancesViewController

#pragma mark - Lazy Instantiation

-(NSMutableArray *)doctorInsurancesArray {
    if (!_doctorInsurancesArray) {
        _doctorInsurancesArray = [[NSMutableArray alloc] initWithArray:self.doctor.insuranceList];
    }
    return _doctorInsurancesArray;
}

-(Doctor *)doctor {
    if (!_doctor) {
        _doctor = [[SharedDoctor sharedDoctor] getSavedDoctor];
    }
    return _doctor;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    NSLog(@"INSURANCESSSSSS: %@", self.doctorInsurancesArray);
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.doctorInsurancesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyInsurancesCell"];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *insuranceDic = self.doctorInsurancesArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", insuranceDic[@"insurance"], insuranceDic[@"insurance_type"]];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.doctorInsurancesArray removeObject:self.doctorInsurancesArray[indexPath.row]];
        [self.tableView reloadData];
        NSLog(@"Insurances left: %@", self.doctorInsurancesArray);
    }
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Server Stuff

-(void)updateInsurancesInServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    //NSArray *insurancesArray = @[@{@"insurance" : @"Colpatria", @"insurance_type": @"Platino"}];
    NSData *insuranceData = [NSJSONSerialization dataWithJSONObject:self.doctorInsurancesArray options:0 error:nil];
    NSString *insuranceString = [[NSString alloc] initWithData:insuranceData encoding:NSUTF8StringEncoding];
    
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"Doctor/Update/%@", self.doctor.identifier] andParameter:[NSString stringWithFormat:@"insurance_list=%@", insuranceString] httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:[NSString stringWithFormat:@"Doctor/Update/%@", self.doctor.identifier]]) {
        if (dictionary) {
            NSLog(@"Recibi el diccionario con la info: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                [[[UIAlertView alloc] initWithTitle:@"Éxito!" message:@"Tus aseguradoras se han actualizado correctamente" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Hubo un error actualizando las aseguradoras. Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Hubo un error en el servidor. Por favor intenta de nuevo" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            NSLog(@"No llegó nada, hubo algún error");
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Se encontró un error en el servidor. Por favor intenta de nuevo en un momento." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    NSLog(@"Error en el server: %@", [error localizedDescription]);
}

#pragma mark - Actions

- (IBAction)saveButtonPressed:(id)sender {
    [self updateInsurancesInServer];
}

- (IBAction)addInsuranceButtonPressed:(id)sender {
    UINavigationController *insurancesNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"InsurancesNavController"];
    InsurancesListViewController *insurancesListVC = insurancesNavController.viewControllers[0];
    insurancesListVC.doctorInsurancesArray = self.doctorInsurancesArray;
    [self presentViewController:insurancesNavController animated:YES completion:nil];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
