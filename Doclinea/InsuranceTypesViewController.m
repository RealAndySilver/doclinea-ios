//
//  InsuranceTypesViewController.m
//  Doclinea
//
//  Created by Developer on 8/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "InsuranceTypesViewController.h"
#import "Insurance.h"
#import "InsuranceType.h"
#import "InsuranceTypeCell.h"

@interface InsuranceTypesViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *currentActivatedInsurancesTypes; //Of NSString
@end

@implementation InsuranceTypesViewController

#pragma mark - Lazy Instantiation

-(NSMutableArray *)currentActivatedInsurancesTypes {
    if (!_currentActivatedInsurancesTypes) {
        _currentActivatedInsurancesTypes = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.doctorInsurancesArray.count; i++) {
            NSDictionary *insuranceDic = self.doctorInsurancesArray[i];
            if ([insuranceDic[@"insurance"] isEqualToString:self.insurance.name]) {
                [_currentActivatedInsurancesTypes addObject:insuranceDic[@"insurance_type"]];
            }
        }
    }
    return _currentActivatedInsurancesTypes;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"THE INSURANCES: %@", self.doctorInsurancesArray);
    NSLog(@"Insurances types that the doctor has in this insurance: %@", self.currentActivatedInsurancesTypes);
    [self setupUI];
}

-(void)setupUI {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - UITableviewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.insurance.typeList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InsuranceTypeCell *cell = (InsuranceTypeCell *)[tableView dequeueReusableCellWithIdentifier:@"InsuranceTypeCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(InsuranceTypeCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    InsuranceType *insuranceType = self.insurance.typeList[indexPath.row];
    cell.insuranceTypeLabel.text = insuranceType.name;
    if ([self.currentActivatedInsurancesTypes containsObject:insuranceType.name]) {
        cell.checkmarkImageView.hidden = NO;
    } else {
        cell.checkmarkImageView.hidden = YES;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    InsuranceTypeCell *cell = (InsuranceTypeCell *)[tableView cellForRowAtIndexPath:indexPath];
    InsuranceType *insuranceType = self.insurance.typeList[indexPath.row];
    NSDictionary *insuranceDic = @{@"insurance" : self.insurance.name, @"insurance_type" : insuranceType.name};

    if (cell.checkmarkImageView.isHidden) {
        cell.checkmarkImageView.hidden = NO;
        //Add this insurance to the insurances array
        [self.doctorInsurancesArray addObject:insuranceDic];
        
    } else {
        //Remove this insurance from the insurances array
        [self.doctorInsurancesArray removeObject:insuranceDic];
        cell.checkmarkImageView.hidden = YES;
    }
    NSLog(@"El nuevo array: %@", self.doctorInsurancesArray);
}

#pragma mark - Actions

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
