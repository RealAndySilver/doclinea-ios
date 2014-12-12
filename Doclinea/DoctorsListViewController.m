//
//  DoctorsListViewController.m
//  Doclinea
//
//  Created by Developer on 1/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "DoctorsListViewController.h"
#import "RatingView.h"
#import "DoctorCell.h"
#import "Doctor.h"
#import "UIImageView+WebCache.h"
#import "DoctorDetailsViewController.h"

@interface DoctorsListViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation DoctorsListViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Actions

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.doctors count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DoctorCell *cell = (DoctorCell *)[tableView dequeueReusableCellWithIdentifier:@"DoctorsCell" forIndexPath:indexPath];
    Doctor *doctor = self.doctors[indexPath.row];
    if ([doctor.gender intValue] == 1) {
        //Male
        cell.doctorNameLabel.text = [NSString stringWithFormat:@"Dr. %@", doctor.completeName];
    } else {
        //Female
        cell.doctorNameLabel.text = [NSString stringWithFormat:@"Dra. %@", doctor.completeName];
    }
    cell.doctorAddressLabel.text = doctor.address;
    cell.doctorProfesionLabel.text = doctor.parsedPracticeList;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self goToDetailsOfDoctorAtIndex:indexPath.row];
}

#pragma mark - Navigation 

-(void)goToDetailsOfDoctorAtIndex:(NSUInteger)index {
    DoctorDetailsViewController *doctorDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DoctorDetails"];
    doctorDetailsVC.doctor = self.doctors[index];
    [self.navigationController pushViewController:doctorDetailsVC animated:YES];
}

@end
