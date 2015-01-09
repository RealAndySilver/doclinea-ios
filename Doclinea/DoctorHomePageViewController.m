//
//  DoctorHomePageViewController.m
//  Doclinea
//
//  Created by Developer on 3/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "DoctorHomePageViewController.h"
#import "DoctorInfoViewController.h"
#import "Doctor.h"
#import "SharedDoctor.h"
#import "DoctorLocationViewController.h"
#import "DoctorEducationViewController.h"
#import "ChangePasswordViewController.h"
#import "DoctorInsurancesViewController.h"

@interface DoctorHomePageViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *menuArray;
@end

@implementation DoctorHomePageViewController

#pragma mark - Lazy Instantiation 

-(NSArray *)menuArray {
    if (!_menuArray) {
        _menuArray = @[@"Datos Personales", @"Contraseña", @"Educación", @"Consultorio", @"Aseguradoras"];
    }
    return _menuArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.layer.borderWidth = 1.0;
    self.tableView.layer.borderColor = [UIColor redColor].CGColor;
    self.tableView.layer.cornerRadius = 10.0;
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menuArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DoctorAccountCell" forIndexPath:indexPath];
    cell.textLabel.text = self.menuArray[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        //Personal Info
        [self goToDoctorInfoVC];
    } else if (indexPath.row == 1) {
        //Password
        [self goToChangePasswordVC];
        
    } else if (indexPath.row == 2) {
        //Estudios
        [self goToDoctorEducationVC];
    } else if (indexPath.row == 3) {
        //Consultorio
        [self goToConsultorioVC];
    } else if (indexPath.row == 4) {
        //Aseguradoras
        [self goToInsurancesList];
    }
}

#pragma mark - Navigation 

-(void)goToInsurancesList {
    DoctorInsurancesViewController *insurancesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DoctorInsurances"];
    [self.navigationController pushViewController:insurancesVC animated:YES];
}

-(void)goToChangePasswordVC {
    ChangePasswordViewController *changePassVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePassword"];
    changePassVC.userType = @"doctor";
    [self.navigationController pushViewController:changePassVC animated:YES];
}

-(void)goToDoctorEducationVC {
    DoctorEducationViewController *doctorEducationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DoctorEducation"];
    [self.navigationController pushViewController:doctorEducationVC animated:YES];
}

-(void)goToConsultorioVC {
    DoctorLocationViewController *doctorLocationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DoctorLocation"];
    [self.navigationController pushViewController:doctorLocationVC animated:YES];
}

-(void)goToDoctorInfoVC {
    DoctorInfoViewController *doctorInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DoctorInfo"];
    [self.navigationController pushViewController:doctorInfoVC animated:YES];
}

- (IBAction)exitButtonPressed:(id)sender {
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
}
@end
