//
//  FavouriteDoctorsViewController.m
//  Doclinea
//
//  Created by Developer on 2/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "FavouriteDoctorsViewController.h"
#import "DoctorCell.h"
#import "Doctor.h"
#import "UIImageView+WebCache.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "NSArray+NullReplacement.h"
#import "NSDictionary+NullReplacement.h"
#import "DoctorDetailsViewController.h"

@interface FavouriteDoctorsViewController () <UITableViewDataSource, UITableViewDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *doctors; //Of Doctor
@property (strong, nonatomic) User *user;
@end

@implementation FavouriteDoctorsViewController

#pragma mark - Lazy Instantiation 

-(User *)user {
    if (!_user) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
            NSData *userEncodedData = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
            _user = [NSKeyedUnarchiver unarchiveObjectWithData:userEncodedData];
        }
    }
    return _user;
}

-(NSArray *)doctors {
    if (!_doctors) {
        _doctors = @[];
    }
    return _doctors;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = 120.0;
    [self.tableView registerClass:[DoctorCell class] forCellReuseIdentifier:@"DoctorsCell"];
    [self getFavDoctorsFromServer];
}

#pragma mark - Actions

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeFavDoctorAtIndex:indexPath.row];
    }
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.doctors.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DoctorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DoctorsCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[DoctorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DoctorsCell"];
    }
    Doctor *doctor = self.doctors[indexPath.row];
    if ([doctor.gender intValue] == 1) {
        //Male
        cell.doctorNameLabel.text = [NSString stringWithFormat:@"Dr. %@", doctor.completeName];
    } else {
        //Female
        cell.doctorNameLabel.text = [NSString stringWithFormat:@"Dra. %@", doctor.completeName];
    }
    if (doctor.locationList.count > 0) {
        cell.doctorAddressLabel.text = doctor.locationList[0][@"location_address"];
    } else {
        cell.doctorAddressLabel.text = @"";
    }
    cell.doctorProfesionLabel.text = doctor.practiceList[0];
    NSLog(@"PARSED PRACTICE LISTTT ***************** %@", doctor.parsedPracticeList);
    if ([doctor.gender intValue] == 1) {
        //Male
        [cell.doctorImageView sd_setImageWithURL:doctor.profilePic placeholderImage:[UIImage imageNamed:@"DoctorMale"]];
    } else {
        //Female
        [cell.doctorImageView sd_setImageWithURL:doctor.profilePic placeholderImage:[UIImage imageNamed:@"DoctorFemale"]];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DoctorDetailsViewController *doctorDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DoctorDetails"];
    doctorDetailsVC.doctor = self.doctors[indexPath.row];
    [self.navigationController pushViewController:doctorDetailsVC animated:YES];
}

#pragma mark - Server Stuff

-(void)removeFavDoctorAtIndex:(NSUInteger)index {
    Doctor *doctor = self.doctors[index];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"User/UnFav/%@", self.user.identifier] andParameter:[NSString stringWithFormat:@"doctor_id=%@", doctor.identifier] httpMethod:@"POST"];
}

-(void)getFavDoctorsFromServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:[NSString stringWithFormat:@"User/GetFavorites/%@", self.user.identifier] andParameter:@""];
}

#pragma mark - ServerCommunicatorDelegate

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:[NSString stringWithFormat:@"User/GetFavorites/%@", self.user.identifier]]) {
        if (dictionary) {
            if ([dictionary[@"status"] boolValue]) {
                //Success
                NSLog(@"Respuesta correcta del get favs: %@", dictionary);
                NSArray *doctorsWithoutNulls = [dictionary[@"response"] arrayByReplacingNullsWithBlanks];
                [self saveDoctorsUsingArray:doctorsWithoutNulls];

            } else {
                NSLog(@"Resputa incorrecta del get favs: %@", dictionary);
            }
        } else {
            NSLog(@"Resputa null del get favs: %@", dictionary);
        }
    
    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"User/UnFav/%@", self.user.identifier]]) {
        if (dictionary) {
            if ([dictionary[@"status"] boolValue]) {
                //Success
                NSLog(@"Resputa correcta del delete fav: %@", dictionary);
                [[[UIAlertView alloc] initWithTitle:@"Éxito!" message:@"Se ha borrado el doctor de tus favoritos" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                NSArray *doctorsWithoutNulls = [dictionary[@"response"] arrayByReplacingNullsWithBlanks];
                [self saveDoctorsUsingArray:doctorsWithoutNulls];
                
            } else {
                NSLog(@"Respuesta incorrecta del delete fav: %@", dictionary);
                [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Ocurrió un error al intentar borrar el doctor de tus favoritos. Por favor intenta de nuevo en un momento" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        } else {
            NSLog(@"Restpuesta null del delete fav: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Error en el server: %@", [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Ocurrió un error en el servidor. Por favor intenta de nuevo en un momento" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Parse Info From Server Stuff

-(void)saveDoctorsUsingArray:(NSArray *)doctorsArray {
    NSMutableArray *doctors = [[NSMutableArray alloc] initWithCapacity:[doctorsArray count]];
    for (int i = 0; i < [doctorsArray count]; i++) {
        NSDictionary *doctorDic = doctorsArray[i];
        NSDictionary *dictWithoutNulls = [doctorDic dictionaryByReplacingNullWithBlanks];
        Doctor *doctor = [[Doctor alloc] initWithDoctorInfo:dictWithoutNulls];
        [doctors addObject:doctor];
    }
    self.doctors = doctors;
    [self.tableView reloadData];
}

@end
