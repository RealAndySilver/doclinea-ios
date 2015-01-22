//
//  AvailableAppointmentsViewController.m
//  Doclinea
//
//  Created by Developer on 22/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "AvailableAppointmentsViewController.h"
#import "MyTextfield.h"

@interface AvailableAppointmentsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet MyTextfield *monthTextfield;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *availableAppointments;
@property (assign, nonatomic) NSUInteger currentPage;
@property (strong, nonatomic) NSArray *monthsArray;
@end

@implementation AvailableAppointmentsViewController

-(NSArray *)monthsArray {
    if (!_monthsArray) {
        _monthsArray = @[@"Enero", @"Febrero", @"Marzo"];
    }
    return _monthsArray;
}

-(NSArray *)availableAppointments {
    if (!_availableAppointments) {
        _availableAppointments = @[@{@"day" : @"enero 10", @"appointmentsNumber" : @15},
                                   @{@"day" : @"enero 11", @"appointmentsNumber" : @7},
                                   @{@"day" : @"enero 12", @"appointmentsNumber" : @10},
                                   @{@"day" : @"enero 13", @"appointmentsNumber" : @8}];
    }
    return _availableAppointments;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPage = 0;
    [self setupUI];
}

-(void)setupUI {
    UIPickerView *monthPicker = [[UIPickerView alloc] init];
    monthPicker.delegate = self;
    monthPicker.dataSource = self;
    self.monthTextfield.inputView = monthPicker;
    
    //Create a toolbar for our picker view
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(inputAccessoryViewDidFinish)];
    [toolbar setItems:@[doneButton] animated:NO];
    self.monthTextfield.inputAccessoryView = toolbar;
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)inputAccessoryViewDidFinish {
    [self.monthTextfield resignFirstResponder];
}

- (IBAction)leftButtonPressed:(id)sender {
    if (self.currentPage == 0) {
        //Dont do anything, we are in the first page
    } else {
        self.currentPage--;
        [self updateUI];
        [self.collectionView reloadData];
    }
}

- (IBAction)rightButtonPressed:(id)sender {
    if (self.currentPage == self.availableAppointments.count - 1) {
        //We are on the last page, don't do anything
    } else {
        self.currentPage++;
        [self updateUI];
        [self.collectionView reloadData];
    }
}

-(void)updateUI {
    self.dayLabel.text = self.availableAppointments[self.currentPage][@"day"];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.availableAppointments[self.currentPage][@"appointmentsNumber"] intValue];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AvailableAppointmentCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.monthsArray[row];
}

#pragma mark - UIPickerViewDataSource

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.monthTextfield.text = [NSString stringWithFormat:@"Mes: %@", self.monthsArray[row]];
}

@end
