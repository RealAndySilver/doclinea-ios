//
//  InsurancesTableViewController.m
//  Doclinea
//
//  Created by Developer on 12/12/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "InsurancesTableViewController.h"
#import "FormLists.h"
#import "Insurance.h"
#import "InsuranceTypeView.h"

@interface InsurancesTableViewController () <UITableViewDataSource, UITableViewDelegate, InsuranceTypeViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *insurancesNamesArray;
@end

@implementation InsurancesTableViewController

-(NSArray *)insurancesNamesArray {
    if (!_insurancesNamesArray) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [tempArray addObject:@"Cualquiera"];
        for (int i = 0; i < [FormLists sharedInstance].ensuranceArray.count; i++) {
            Insurance *insurance = [FormLists sharedInstance].ensuranceArray[i];
            if (insurance) {
                [tempArray addObject:insurance.name];
            }
        }
        _insurancesNamesArray = tempArray;
    }
    return _insurancesNamesArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 65.0, self.view.bounds.size.width, self.view.bounds.size.height - 65.0) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = 50.0;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"InsuranceCell"];
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.insurancesNamesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InsuranceCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InsuranceCell"];
    }
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.text = self.insurancesNamesArray[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"InsuranceSelected" object:nil userInfo:@{@"name" : @"", @"type" : @""}];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        Insurance *selectedInsuranc = [FormLists sharedInstance].ensuranceArray[indexPath.row - 1];
        [self showInsuranceTypeViewWithInsurance:selectedInsuranc];
    }
}

#pragma mark - Actions 

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showInsuranceTypeViewWithInsurance:(Insurance *)insurance {
    InsuranceTypeView *insuraceView = [[InsuranceTypeView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 140.0, self.view.bounds.size.height/2.0 - 140.0, 280.0, 280.0)];
    insuraceView.insurance = insurance;
    insuraceView.delegate = self;
    [insuraceView showInView:self.view];
}

#pragma mark - InsuranceTypeViewDelegate

-(void)insuranceTypeViewDidDisappear {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
