//
//  DoctorEducationViewController.m
//  Doclinea
//
//  Created by Developer on 9/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "DoctorEducationViewController.h"
#import "Doctor.h"
#import "SharedDoctor.h"
#import "Studie.h"
#import "AddStudieView.h"
#import "MBProgressHUD.h"
#import "ServerCommunicator.h"
#import "EducationCell.h"
#import "EducationDetailsViewController.h"
#import "AddMembershipView.h"

@interface DoctorEducationViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, AddStudieViewDelegate, ServerCommunicatorDelegate, AddMembershipViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Doctor *doctor;
@property (strong, nonatomic) NSMutableArray *membershipsList;
@property (strong, nonatomic) NSMutableArray *educationList;
@end

@implementation DoctorEducationViewController {
    BOOL removingStudieInServer;
}

#pragma mark - Lazy Instantiation

-(NSMutableArray *)membershipsList {
    if (!_membershipsList) {
        _membershipsList = [NSMutableArray arrayWithArray:self.doctor.profesionalMembership];
        NSLog(@"CURRENT PROFESIONAL MEMBERSHIP: %@", _membershipsList);
    }
    return _membershipsList;
}

-(NSMutableArray *)educationList {
    if (!_educationList) {
        _educationList = [NSMutableArray arrayWithArray:self.doctor.educationList];
    }
    return _educationList;
}

-(Doctor *)doctor {
    if (!_doctor) {
        _doctor = [[SharedDoctor sharedDoctor] getSavedDoctor];
        NSLog(@"NOMBRE DEL DOC GUARDADO: %@", _doctor.name);
        NSLog(@"PROFESIONAL_MEMBERSHIOP: %@", _doctor.profesionalMembership);
    }
    return _doctor;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(educationUpdated) name:@"EducationUpdated" object:nil];
    [self setupUI];
}

#pragma mark - Custom INitialization Stuff

-(void)setupUI {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = 100.0;
}

#pragma mark - Actions 

- (IBAction)addButtonPressed:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Educación" message:@"¿Qué tipo de información deseas agregar?" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Estudios", @"Membresias Profesionales",nil] show];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Show Views 

-(void)showAddStudieView {
    AddStudieView *addStudieView = [[AddStudieView alloc] initWithFrame:CGRectMake(20.0, 20.0, self.view.bounds.size.width - 40.0, self.view.bounds.size.height - 40.0)];
    addStudieView.delegate = self;
    [addStudieView showInView:self.tabBarController.view];
}

-(void)showMembershipView {
    AddMembershipView *membershipView = [[AddMembershipView alloc] initWithFrame:CGRectMake(20.0, self.view.bounds.size.height/2.0 - 100.0, self.view.bounds.size.width - 40.0, 200.0)];
    membershipView.delegate = self;
    [membershipView showInView:self.tabBarController.view];
}

#pragma mark - UITableViewDataSource 

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        //Studies section
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            NSLog(@"Presioné borrar");
            [self removeStudieAtIndex:indexPath.row];
        }
    } else if (indexPath.section == 1) {
        //Profesional memberhip section
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [self removeMembershipAtIndex:indexPath.row];
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Educación";
    } else {
        return @"Membresías Profesionales";
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.educationList count];
    } else if (section == 1) {
        return [self.membershipsList count];
    } else {
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        //Educacion
        EducationCell *cell = (EducationCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell1"];
        if (!cell) {
            cell = [[EducationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell1"];
        }
        Studie *studie = self.educationList[indexPath.row];
        cell.instituteLabel.text = studie.instituteName;
        cell.degreeLabel.text = studie.degree;
        NSString *yearsString = [NSString stringWithFormat:@"%@ - %@", studie.startYear, studie.endYear];
        cell.studieYearsLabel.text = yearsString;
        return cell;
        
    } else {
        //Membresias profesionales
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell2"];
        }
        cell.textLabel.text = self.membershipsList[indexPath.row];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        //Go to Education Details
        EducationDetailsViewController *educationDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EducationDetails"];
        educationDetailsVC.indexForSelectedStudie = indexPath.row;
        [self.navigationController pushViewController:educationDetailsVC animated:YES];
    }
}

#pragma mark - Server Stuff

-(void)removeMembershipAtIndex:(NSUInteger)index {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    [self.membershipsList removeObjectAtIndex:index];
    NSError *error = nil;
    NSData *membershipData;
    if (self.membershipsList.count > 0) {
        membershipData = [NSJSONSerialization dataWithJSONObject:self.membershipsList options:NSJSONWritingPrettyPrinted error:nil];
    } else {
        membershipData = [NSJSONSerialization dataWithJSONObject:@[@0] options:NSJSONWritingPrettyPrinted error:nil];
    }
    if (error) {
        NSLog(@"Error creando el JSON oís: %@", [error localizedDescription]);
    }
    NSString *membershipString = [[NSString alloc] initWithData:membershipData encoding:NSUTF8StringEncoding];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"Doctor/Update/%@", self.doctor.identifier] andParameter:[NSString stringWithFormat:@"profesional_membership=%@", membershipString] httpMethod:@"POST"];
}

-(void)removeStudieAtIndex:(NSUInteger)index {
    removingStudieInServer = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    NSMutableArray *studiesArray = [NSMutableArray arrayWithArray:self.educationList];
    [studiesArray removeObjectAtIndex:index];
    
    NSMutableArray *educationArray = [[NSMutableArray alloc] init];
    if ([studiesArray count] > 0) {
        for (int i = 0; i < [studiesArray count]; i++) {
            Studie *studie = studiesArray[i];
            NSLog(@"legare al dic %@ %@ %@ %@ %@", studie.instituteName, studie.degree, studie.startYear, studie.endYear, studie.highlights);
            /*studie.instituteName = [studie.instituteName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            studie.degree = [studie.degree stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            studie.highlights = [studie.highlights stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];*/

            NSDictionary *studieDic = [NSDictionary dictionaryWithDictionary:[studie studieAsDictionary]];
            [educationArray addObject:studieDic];
            NSLog(@"guarde uno");
        }
    } else {
        educationArray = [NSMutableArray arrayWithArray:@[@0]];
    }
    
    NSData *educationData = [NSJSONSerialization dataWithJSONObject:educationArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *educationString = [[NSString alloc] initWithData:educationData encoding:NSUTF8StringEncoding];
    
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"Doctor/Update/%@", self.doctor.identifier] andParameter:[NSString stringWithFormat:@"education_list=%@", educationString] httpMethod:@"POST"];
}

-(void)saveMembershipsInServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSError *error = nil;
    NSData *membershipData = [NSJSONSerialization dataWithJSONObject:self.membershipsList options:NSJSONWritingPrettyPrinted error:nil];
    if (error) {
        NSLog(@"Error creando el JSON oís: %@", [error localizedDescription]);
    }
    NSString *membershipString = [[NSString alloc] initWithData:membershipData encoding:NSUTF8StringEncoding];
    
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"Doctor/Update/%@", self.doctor.identifier] andParameter:[NSString stringWithFormat:@"profesional_membership=%@", membershipString] httpMethod:@"POST"];
}

-(void)saveStudiesInServer {
    removingStudieInServer = NO;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    NSMutableArray *educationArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.educationList count]; i++) {
        Studie *studie = self.educationList[i];
        NSLog(@"legare al dic %@ %@ %@ %@ %@", studie.instituteName, studie.degree, studie.startYear, studie.endYear, studie.highlights);
        //studie.instituteName = [studie.instituteName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //studie.degree = [studie.degree stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //studie.highlights = [studie.highlights stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *studieDic = [NSDictionary dictionaryWithDictionary:[studie studieAsDictionary]];
        NSLog(@"STUDIE DIC: %@", studieDic);
        [educationArray addObject:studieDic];
        NSLog(@"guarde uno");
    }
    
    for (NSDictionary *studieDic in educationArray) {
        NSLog(@"Diccionario del estudioooo: %@", studieDic);
    }
    
    NSError *error;
    NSData *educationData = [NSJSONSerialization dataWithJSONObject:educationArray options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"************** ERRORRRRRRRRRRR: %@", [error localizedDescription]);
    }
    NSString *educationString = [[NSString alloc] initWithData:educationData encoding:NSUTF8StringEncoding];
    NSLog(@"Education striiinnnggg: %@", educationString);
    
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"Doctor/Update/%@", self.doctor.identifier] andParameter:[NSString stringWithFormat:@"education_list=%@", educationString] httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:[NSString stringWithFormat:@"Doctor/Update/%@", self.doctor.identifier]]) {
        if (dictionary) {
            NSLog(@"Rspuesta correcta del update: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                //Success saving studies
                self.doctor = nil;
                self.educationList = nil;
                self.membershipsList = nil;
                
                Doctor *doctor = [[Doctor alloc] initWithDoctorInfo:dictionary[@"response"]];
                [self saveDoctorInUserDefaults:doctor];
                if (removingStudieInServer) {
                    self.educationList = nil; //Because this is nil, educationList will get again the
                    //updated education list from the doctor.
                }
                [self.tableView reloadData];
            }
        } else {
            NSLog(@"Respueta incorrecta del update: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error intentanto enviar la información al servidor. Por favor revisa que estés conectado a internet e intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - User Defaults 

-(void)saveDoctorInUserDefaults:(Doctor *)doctor {
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:doctor];
    [[NSUserDefaults standardUserDefaults] setObject:encodedData forKey:@"doctor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //Educacion
        [self showAddStudieView];
    } else if (buttonIndex == 2) {
        //Membresías Profesionales
        [self showMembershipView];
    }
}

#pragma mark - AddMembershipViewDelegate

-(void)membershipAdded:(NSString *)membershipName {
    NSLog(@"Me llego la membresia: %@", membershipName);
    [self.membershipsList addObject:membershipName];
    [self saveMembershipsInServer];
}

#pragma mark - AddStudieViewDelegate

-(void)addStudieViewDidSaveStudie:(Studie *)studie {
    NSLog(@"Isssssss nombre: %@ %@ %@ %@ %@", studie.instituteName, studie.degree, studie.startYear, studie.endYear, studie.highlights);
    [self.educationList addObject:studie];
    NSLog(@"pase de acaaa");
    [self saveStudiesInServer];
}

#pragma mark - Notification Handlers 

-(void)educationUpdated {
    NSLog(@"Entré al notificatiooooonnn");
    self.doctor = nil;
    self.educationList = nil;
    [self.tableView reloadData];
}

@end
