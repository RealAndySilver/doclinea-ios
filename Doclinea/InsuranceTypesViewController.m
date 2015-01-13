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
@end

@implementation InsuranceTypesViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
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
    InsuranceType *insuranceType = self.insurance.typeList[indexPath.row];
    cell.insuranceTypeLabel.text = insuranceType.name;
    return cell;
}

#pragma mark - Actions

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
