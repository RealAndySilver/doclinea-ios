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
#import "FormLists.h"
#import "Practice.h"
#import "Insurance.h"
#import "InsurancesTableViewController.h"

@interface HomeScreenViewController () <UIPickerViewDataSource, UIPickerViewDelegate, ServerCommunicatorDelegate, UITextFieldDelegate>
@property (strong, nonatomic) UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UIButton *searchByNameButton;
@property (weak, nonatomic) IBOutlet UITextField *localidadTextfield;
@property (weak, nonatomic) IBOutlet UITextField *insuranceTextfield;
@property (weak, nonatomic) IBOutlet UITextField *citiesTextfield;
@property (weak, nonatomic) IBOutlet UITextField *specialtiesTextfield;
//@property (strong, nonatomic) NSArray *specialtiesArray;
@property (strong, nonatomic) NSArray *citiesNames;
//@property (strong, nonatomic) NSArray *insurancesNames;
@property (strong, nonatomic) NSArray *localidadesArray;
@property (strong, nonatomic) NSArray *practicesArray;
@property (strong, nonatomic) NSArray *insurancesArray;
@property (strong, nonatomic) NSString *selectedInsurance;
@property (strong, nonatomic) NSString *selectedInsuranceType;
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

-(NSArray *)practicesArray {
    if (!_practicesArray) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [tempArray addObject:@"Todas"];
        for (int i = 0; i < [FormLists sharedInstance].specialtiesArray.count; i++) {
            Practice *practice = [FormLists sharedInstance].specialtiesArray[i];
            [tempArray addObject:practice.name];
        }
        _practicesArray = tempArray;
    }
    return _practicesArray;
}

-(NSArray *)insurancesArray {
    if (!_insurancesArray) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [tempArray addObject:@"Todas"];
        for (int i = 0; i < [FormLists sharedInstance].ensuranceArray.count; i++) {
            Insurance *insurance = [FormLists sharedInstance].ensuranceArray[i];
            if (insurance) {
                [tempArray addObject:insurance.name];
            }
        }
        _insurancesArray = tempArray;
    }
    return _insurancesArray;
}

-(NSArray *)localidadesArray {
    if (!_localidadesArray) {
        _localidadesArray = [[Localidad sharedLocalidad] getLocalidadesArray];
    }
    return _localidadesArray;
}

/*-(NSArray *)specialtiesArray {
    if (!_specialtiesArray) {
       // _specialtiesArray = @[@{@"name" : @"Pediatra", @"id" : @1}, @{@"name" : @"Fonoaudiólogo", @"id" : @2}, @{@"name" : @"Ginecólogo", @"id" : @3}, @{@"name" : @"Ortopedista", @"id" : @4}, @{@"name" : @"Odontólogo", @"id" : @5}];
        _specialtiesArray = @[@"Todas", @"Pediatra", @"Fonoaudiólogo", @"Ginecólogo", @"Ortopedista", @"Odontólogo"];
    }
    return _specialtiesArray;
}*/

/*-(NSArray *)insurancesNames {
    if (!_insurancesNames) {
        _insurancesNames = @[@"Todas", @"Sura", @"Colpatria", @"Compensar"];
    }
    return _insurancesNames;
}*/

-(NSArray *)citiesNames {
    if (!_citiesNames) {
        _citiesNames = @[@"Todas", @"Bogotá", @"Medellín", @"Cali", @"Baranquilla", @"Pereira", @"Bucaramanga"];
    }
    return _citiesNames;
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insuranceSelectedReceived:) name:@"InsuranceSelected" object:nil];
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
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
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
    self.localidadTextfield.tag = 1;
    
    //Setup picker view for the specialties textfield
    UIPickerView *specialtiesPickerView = [[UIPickerView alloc] init];
    specialtiesPickerView.delegate = self;
    specialtiesPickerView.dataSource = self;
    specialtiesPickerView.tag = specialtiesPicker;
    self.specialtiesTextfield.inputView = specialtiesPickerView;
    self.specialtiesTextfield.tag = 2;
    
    //Setup picker view for the cities textfield
    UIPickerView *citiesPickerView = [[UIPickerView alloc] init];
    citiesPickerView.delegate = self;
    citiesPickerView.dataSource = self;
    citiesPickerView.tag = citiesPicker;
    self.citiesTextfield.inputView = citiesPickerView;
    self.citiesTextfield.tag = 3;
    
    //Setup picker view for the insurance textfield
    UIPickerView *insurancePickerView = [[UIPickerView alloc] init];
    insurancePickerView.delegate = self;
    insurancePickerView.dataSource = self;
    insurancePickerView.tag = insurancePicker;
    self.insuranceTextfield.inputView = insurancePickerView;
    self.insuranceTextfield.tag = 4;
    
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

-(void)goToInsurancesList {
    InsurancesTableViewController *insurancesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Insurances"];
    [self presentViewController:insurancesVC animated:YES completion:nil];
}

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
    
    NSArray *insurancArray;
    if ([self.selectedInsurance length] > 0) {
        insurancArray = @[@{@"insurance" : self.selectedInsurance, @"insurance_type" : self.selectedInsuranceType}];
    } else {
        insurancArray = @[@{@"insurance" : @"", @"insurance_type" : @""}];
    }
    NSData *insuranceData = [NSJSONSerialization dataWithJSONObject:insurancArray options:0 error:nil];
    NSString *insuranceString = [[NSString alloc] initWithData:insuranceData encoding:NSUTF8StringEncoding];
    NSLog(@"Insurance sstringggg: %@", insuranceString);
    
    //NSDictionary *localidadDic = @{@"name": self.localidadTextfield.text, @"lat" : @4.5, @"lon" : @74.5};
    NSDictionary *localidadDic = @{@"name" : self.localidadTextfield.text};
    NSData *localidadData = [NSJSONSerialization dataWithJSONObject:localidadDic options:0 error:nil];
    NSString *localidadString = [[NSString alloc] initWithData:localidadData encoding:NSUTF8StringEncoding];
    
    NSString *parameter;
    if ([self.selectedInsurance length] > 0) {
        if ([self.localidadTextfield.text length] > 0) {
             parameter = [NSString stringWithFormat:@"city=%@&insurance_list=%@&practice_list=%@&localidad=%@", self.citiesTextfield.text,insuranceString, self.specialtiesTextfield.text, localidadString];
        } else {
             parameter = [NSString stringWithFormat:@"city=%@&insurance_list=%@&practice_list=%@", self.citiesTextfield.text, insuranceString, self.specialtiesTextfield.text];
        }
       
    } else {
        if ([self.localidadTextfield.text length] > 0) {
                parameter = [NSString stringWithFormat:@"city=%@&practice_list=%@&localidad=%@", self.citiesTextfield.text, self.specialtiesTextfield.text, localidadString];
        } else {
                parameter = [NSString stringWithFormat:@"city=%@&practice_list=%@", self.citiesTextfield.text, self.specialtiesTextfield.text];
        }
    }
    
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
        return self.practicesArray.count;
    } else if (pickerView.tag == citiesPicker) {
        return [self.citiesNames count];
    } else if (pickerView.tag == insurancePicker) {
        return [self.insurancesArray count];
    } else if (pickerView.tag == localidadPicker) {
        return [self.localidadesArray count];
    } else return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == specialtiesPicker) {
        return self.practicesArray[row];
        
    } else if (pickerView.tag == citiesPicker) {
        return self.citiesNames[row];
        
    } else if (pickerView.tag == insurancePicker) {
        return self.insurancesArray[row];
        
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
            self.specialtiesTextfield.text = self.practicesArray[row];
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
            self.insuranceTextfield.text = self.insurancesArray[row];
        }
        
    } else if (pickerView.tag == localidadPicker) {
        self.localidadTextfield.text = ((Localidad *)self.localidadesArray[row]).name;
    }
}

#pragma mark - Notification Handlers 

-(void)insuranceSelectedReceived:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSString *insuranceName = info[@"name"];
    NSString *insuranceType = info[@"type"];
    self.selectedInsurance = insuranceName;
    self.selectedInsuranceType = insuranceType;
    NSLog(@"Recibi la notificacion con nombre: %@ y tipo: %@", insuranceName, insuranceType);
    if ([self.selectedInsurance length] > 0) {
        self.insuranceTextfield.text = [NSString stringWithFormat:@"%@ / %@", insuranceName, insuranceType];
    } else {
        self.insuranceTextfield.text = @"";
    }
}

-(void)keyboardWillShow {
    
}

-(void)keyboardWillHide {
    
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"Deberia empezar a editarmeee");
    if (textField.tag == 4) {
        //Insurance textfield.
        [self goToInsurancesList];
        return NO;
    }
    return YES;
}

@end
