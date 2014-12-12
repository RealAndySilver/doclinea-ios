//
//  PracticeListViewController.m
//  Doclinea
//
//  Created by Developer on 11/12/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "PracticeListViewController.h"
#import "PracticeListCell.h"
#import "FormLists.h"
#import "Practice.h"

@interface PracticeListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *selectedPractices;
@end

@implementation PracticeListViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedPractices = [[NSMutableArray alloc] initWithArray:self.currentPractices];
    [self setupUI];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate doctorSelectedPractices:self.selectedPractices];
}

#pragma mark - Custom UI Stuff

-(void)setupUI {
    //Create our table view to display the practice list
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 65.0, self.view.bounds.size.width, self.view.bounds.size.height - 65.0) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 50.0;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[PracticeListCell class] forCellReuseIdentifier:@"PracticeCell"];
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [FormLists sharedInstance].specialtiesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PracticeListCell *cell = (PracticeListCell *)[tableView dequeueReusableCellWithIdentifier:@"PracticeCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[PracticeListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PracticeCell"];
    }
    
    Practice *practice = [FormLists sharedInstance].specialtiesArray[indexPath.row];
    cell.practiceNameLabel.text = practice.name;
    
    if ([self.currentPractices containsObject:practice.name]) {
        //show checkmark the cell
        cell.checkView.hidden = NO;
    } else {
        cell.checkView.hidden = YES;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PracticeListCell *cell = (PracticeListCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.checkView.isHidden) {
        cell.checkView.hidden = NO;
        if (![self.selectedPractices containsObject:cell.practiceNameLabel.text]) {
            NSLog(@"Agregare la practica al listadooo");
            [self.selectedPractices addObject:cell.practiceNameLabel.text];
        }
        
    } else {
        cell.checkView.hidden = YES;
        if ([self.selectedPractices containsObject:cell.practiceNameLabel.text]) {
            NSLog(@"Lo quitaréeee del listado");
            [self.selectedPractices removeObject:cell.practiceNameLabel.text];
        }
    }
}

#pragma mark - Actions

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
