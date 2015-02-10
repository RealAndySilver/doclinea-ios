//
//  InsuranceConfirmationViewController.m
//  Doclinea
//
//  Created by Developer on 10/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "InsuranceConfirmationViewController.h"

@interface InsuranceConfirmationViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation InsuranceConfirmationViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Actions

- (IBAction)backButtonPresed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.doctor.insuranceList.count + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InsuranceID" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Pagaré cita particular";
        cell.detailTextLabel.text = @"";
    
    } else {
        cell.textLabel.text = self.doctor.insuranceList[indexPath.row - 1][@"insurance"];
        cell.detailTextLabel.text = self.doctor.insuranceList[indexPath.row - 1][@"insurance_type"];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate insuranceSelectedAtIndex:indexPath.row];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
