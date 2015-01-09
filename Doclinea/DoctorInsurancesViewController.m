//
//  DoctorInsurancesViewController.m
//  Doclinea
//
//  Created by Developer on 8/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "DoctorInsurancesViewController.h"
#import "FormLists.h"
#import "Insurance.h"
#import "InsuranceTypesViewController.h"

@interface DoctorInsurancesViewController() <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation DoctorInsurancesViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [FormLists sharedInstance].ensuranceArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AseguradorasCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AseguradorasCell"];
    }
    Insurance *insurance = [FormLists sharedInstance].ensuranceArray[indexPath.row];
    cell.textLabel.text = insurance.name;
    return cell;
}

#pragma mark - UITableviewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    InsuranceTypesViewController *insurancesTypesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"InsuranceTypes"];
    insurancesTypesVC.insurance = [FormLists sharedInstance].ensuranceArray[indexPath.row];
    [self.navigationController pushViewController:insurancesTypesVC animated:YES];
}

#pragma mark - Actions

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
