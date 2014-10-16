//
//  HomeScreenViewController.m
//  Doclinea
//
//  Created by Developer on 30/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "HomeScreenViewController.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"
#import "Doctor.h"
#import "DoctorsListViewController.h"
#import "Localidad+Shared.h"
#import "SearchByNameViewController.h"
#import "NSDictionary+NullReplacement.h"
#import "NSArray+NullReplacement.h"

@interface HomeScreenViewController () <UIPickerViewDataSource, UIPickerViewDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UIButton *searchByNameButton;
@property (weak, nonatomic) IBOutlet UITextField *localidadTextfield;
@property (weak, nonatomic) IBOutlet UITextField *insuranceTextfield;
@property (weak, nonatomic) IBOutlet UITextField *citiesTextfield;
@property (weak, nonatomic) IBOutlet UITextField *specialtiesTextfield;
@property (strong, nonatomic) NSArray *specialtiesArray;
@property (strong, nonatomic) NSArray *citiesNames;
@property (strong, nonatomic) NSArray *insurancesNames;
@property (strong, nonatomic) NSArray *localidadesArray;
@end

@implementation HomeScreenViewController {
    CGRect screenBounds;
    BOOL firstTimeLayout;
}

enum {
    specialtiesPicker = 1,
    citiesPicker,
    insurancePicker,
    localidadPicker
};

#pragma mark - Lazy Instantiation

-(NSArray *)localidadesArray {
    if (!_localidadesArray) {
        _localidadesArray = [[Localidad sharedLocalidad] getLocalidadesArray];
    }
    return _localidadesArray;
}

-(NSArray *)specialtiesArray {
    if (!_specialtiesArray) {
       // _specialtiesArray = @[@{@"name" : @"Pediatra", @"id" : @1}, @{@"name" : @"Fonoaudiólogo", @"id" : @2}, @{@"name" : @"Ginecólogo", @"id" : @3}, @{@"name" : @"Ortopedista", @"id" : @4}, @{@"name" : @"Odontólogo", @"id" : @5}];
        _specialtiesArray = @[@"Todas", @"Pediatra", @"Fonoaudiólogo", @"Ginecólogo", @"Ortopedista", @"Odontólogo"];
    }
    return _specialtiesArray;
}

-(NSArray *)insurancesNames {
    if (!_insurancesNames) {
        _insurancesNames = @[@"Todas", @"Sura", @"Colpatria", @"Compensar"];
    }
    return _insurancesNames;
}

-(NSArray *)citiesNames {
    if (!_citiesNames) {
        _citiesNames = @[@"Todas", @"Bogotá", @"Medellín", @"Cali", @"Baranquilla", @"Pereira", @"Bucaramanga"];
    }
    return _citiesNames;
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    firstTimeLayout = YES;
    screenBounds = [UIScreen mainScreen].bounds;
    NSLog(@"SCREEN: %@", NSStringFromCGRect(screenBounds));
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNotifications];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (firstTimeLayout) {
        self.searchButton = [[UIButton alloc] initWithFrame:CGRectMake(72.0, self.citiesTextfield.frame.origin.y + self.citiesTextfield.frame.size.height + 20.0, screenBounds.size.width - 144.0, 35.0)];
        [self.searchButton setTitle:@"Buscar" forState:UIControlStateNormal];
        self.searchButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        [self.searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.searchButton.layer.cornerRadius = 5.0;
        self.searchButton.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:159.0/255.0 blue:225.0/255.0 alpha:1.0];
        [self.searchButton addTarget:self action:@selector(searchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.searchButton];
        firstTimeLayout = NO;
    }
}

#pragma mark - Custom Initialization Stuff 

-(void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

-(void)setupUI {
    //Hidde the localidad button
    self.localidadTextfield.alpha = 0.0;
    
    //Setup picker view for the specialties textfield
    UIPickerView *specialtiesPickerView = [[UIPickerView alloc] init];
    specialtiesPickerView.delegate = self;
    specialtiesPickerView.dataSource = self;
    specialtiesPickerView.tag = specialtiesPicker;
    self.specialtiesTextfield.inputView = specialtiesPickerView;
    
    //Setup picker view for the cities textfield
    UIPickerView *citiesPickerView = [[UIPickerView alloc] init];
    citiesPickerView.delegate = self;
    citiesPickerView.dataSource = self;
    citiesPickerView.tag = citiesPicker;
    self.citiesTextfield.inputView = citiesPickerView;
    
    //Setup picker view for the insurance textfield
    UIPickerView *insurancePickerView = [[UIPickerView alloc] init];
    insurancePickerView.delegate = self;
    insurancePickerView.dataSource = self;
    insurancePickerView.tag = insurancePicker;
    self.insuranceTextfield.inputView = insurancePickerView;
    
    //Setup the localidad picker
    UIPickerView *localidadPickerView = [[UIPickerView alloc] init];
    localidadPickerView.delegate = self;
    localidadPickerView.dataSource = self;
    localidadPickerView.tag = localidadPicker;
    self.localidadTextfield.inputView = localidadPickerView;
    
    //Create a toolbar to dimiss the pickers
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissPickerView)];
    [toolbar setItems:@[doneButton]];
    self.specialtiesTextfield.inputAccessoryView = toolbar;
    self.citiesTextfield.inputAccessoryView = toolbar;
    self.insuranceTextfield.inputAccessoryView = toolbar;
    self.localidadTextfield.inputAccessoryView = toolbar;
}

#pragma mark - Actions 

-(IBAction)searchByNameButtonPressed {
    //Go to search by name view controller
    SearchByNameViewController *searchByNameVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchByName"];
    searchByNameVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController pushViewController:searchByNameVC animated:YES];
}

- (IBAction)logoutButtonPressed:(id)sender {
    //Erase user from user defaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissPickerView {
    [self.insuranceTextfield resignFirstResponder];
    [self.citiesTextfield resignFirstResponder];
    [self.specialtiesTextfield resignFirstResponder];
    [self.localidadTextfield resignFirstResponder];
}

- (void)searchButtonPressed:(id)sender {
    [self searchDoctorInServer];
}

#pragma mark - Navigation 

-(void)goToDoctorsListWithDoctors:(NSArray *)doctors {
    DoctorsListViewController *doctorsListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DoctorsList"];
    doctorsListVC.doctors = doctors;
    [self.navigationController pushViewController:doctorsListVC animated:YES];
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
    [self goToDoctorsListWithDoctors:doctors];
}

#pragma mark - Server Stuff 

-(void)searchDoctorInServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameter = [NSString stringWithFormat:@"city=%@&insurance=%@&practice_list=%@&localidad=%@", self.citiesTextfield.text, self.insuranceTextfield.text, self.specialtiesTextfield.text, self.localidadTextfield.text];
    [serverCommunicator callServerWithPOSTMethod:@"Doctor/GetByParams" andParameter:parameter httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:@"Doctor/GetByParams"]) {
        if (dictionary) {
            NSLog(@"Respuesta valida del get doctors: %@", dictionary);
            if (![dictionary[@"status"] boolValue]) {
                //Doctor not found
                [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"No se encontró ningún doctor" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            } else {
                //Doctor found
                NSArray *doctorsWithoutNulls = [dictionary[@"response"] arrayByReplacingNullsWithBlanks];
                [self saveDoctorsUsingArray:doctorsWithoutNulls];
            }
        } else {
            NSLog(@"Rspuesta invalida del get doctors: %@", dictionary);
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Hubo un problema realizando la búsqueda. Por favor intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Server error ois: %@ %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Hubo un error en el servidor. Por favor intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - BUttons Animations 

-(void)activateLocalidadTextfield {
    NSLog(@"Activareeeeeee");
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.localidadTextfield.alpha = 1.0;
                         self.searchButton.transform = CGAffineTransformMakeTranslation(0.0, self.searchButton.frame.size.height + 20.0);
                     } completion:nil];
}

-(void)deactivateLocalidadTextfield {
    self.localidadTextfield.text = @"";
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.localidadTextfield.alpha = 0.0;
                         self.searchButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                     } completion:nil];
}

#pragma mark - UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == specialtiesPicker) {
        return [self.specialtiesArray count];
    } else if (pickerView.tag == citiesPicker) {
        return [self.citiesNames count];
    } else if (pickerView.tag == insurancePicker) {
        return [self.insurancesNames count];
    } else if (pickerView.tag == localidadPicker) {
        return [self.localidadesArray count];
    } else return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == specialtiesPicker) {
        return self.specialtiesArray[row];
    } else if (pickerView.tag == citiesPicker) {
        return self.citiesNames[row];
    } else if (pickerView.tag == insurancePicker) {
        return self.insurancesNames[row];
    } else if (pickerView.tag == localidadPicker) {
        return ((Localidad *)self.localidadesArray[row]).name;
    } else return nil;
}

#pragma mark - UIPickerViewDelegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == specialtiesPicker) {
        if (row == 0) {
            self.specialtiesTextfield.text = @"";
        } else {
            self.specialtiesTextfield.text = self.specialtiesArray[row];
        }
        
    } else if (pickerView.tag == citiesPicker) {
        if (row == 0) {
            self.citiesTextfield.text = @"";
            [self deactivateLocalidadTextfield];
        } else {
            self.citiesTextfield.text = self.citiesNames[row];
            if ([self.citiesTextfield.text isEqualToString:@"Bogotá"]) {
                //Activate the localidad textfield
                [self activateLocalidadTextfield];
            } else {
                [self deactivateLocalidadTextfield];
            }
        }
        
    } else if (pickerView.tag == insurancePicker) {
        if (row == 0) {
            self.insuranceTextfield.text = @"";
        } else {
            self.insuranceTextfield.text = self.insurancesNames[row];
        }
        
    } else if (pickerView.tag == localidadPicker) {
        self.localidadTextfield.text = ((Localidad *)self.localidadesArray[row]).name;
    }
}

#pragma mark - Notification Handlers 

-(void)keyboardWillShow {
    
}

-(void)keyboardWillHide {
    
}

@end
