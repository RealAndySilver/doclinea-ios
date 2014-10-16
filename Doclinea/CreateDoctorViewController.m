//
//  CreateDoctorViewController.m
//  Doclinea
//
//  Created by Developer on 3/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "CreateDoctorViewController.h"
#import "Localidad+Shared.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"
#import "Doctor.h"

@interface CreateDoctorViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastnameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *genderTextfield;
@property (weak, nonatomic) IBOutlet UITextField *pacientsGenderTextfield;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextfield;
@property (weak, nonatomic) IBOutlet UITextField *addressTextfield;
@property (weak, nonatomic) IBOutlet UITextField *especialidadTextfield;
@property (weak, nonatomic) IBOutlet UITextField *cityTextfield;
@property (weak, nonatomic) IBOutlet UITextField *localidadTextfield;

//Arrays
@property (strong, nonatomic) NSArray *citiesNames;
@property (strong, nonatomic) NSArray *localidadesArray;
@property (strong, nonatomic) NSArray *specialtiesArray;
@property (strong, nonatomic) NSArray *genderNamesarray;
@property (strong, nonatomic) NSArray *pacientGendersArray;
@end

@implementation CreateDoctorViewController

enum {
    genderPicker = 1,
    pacientGenderPicker,
    especialidadPicker,
    cityPicker,
    localidadPicker
};

#pragma mark - Lazy Instantiation

-(NSArray *)pacientGendersArray {
    if (!_pacientGendersArray) {
        _pacientGendersArray = @[@"Hombres", @"Mujeres", @"Ambos"];
    }
    return _pacientGendersArray;
}

-(NSArray *)genderNamesarray {
    if (!_genderNamesarray) {
        _genderNamesarray = @[@"Masculino", @"Femenino"];
    }
    return _genderNamesarray;
}

-(NSArray *)localidadesArray {
    if (!_localidadesArray) {
        _localidadesArray = [[Localidad sharedLocalidad] getLocalidadesArray];
    }
    return _localidadesArray;
}

-(NSArray *)specialtiesArray {
    if (!_specialtiesArray) {
        // _specialtiesArray = @[@{@"name" : @"Pediatra", @"id" : @1}, @{@"name" : @"Fonoaudiólogo", @"id" : @2}, @{@"name" : @"Ginecólogo", @"id" : @3}, @{@"name" : @"Ortopedista", @"id" : @4}, @{@"name" : @"Odontólogo", @"id" : @5}];
        _specialtiesArray = @[@"Pediatra", @"Fonoaudiólogo", @"Ginecólogo", @"Ortopedista", @"Odontólogo"];
    }
    return _specialtiesArray;
}

-(NSArray *)citiesNames {
    if (!_citiesNames) {
        _citiesNames = @[@"Bogotá", @"Medellín", @"Cali", @"Baranquilla", @"Pereira", @"Bucaramanga"];
    }
    return _citiesNames;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

#pragma mark - Custom Initialization Stuff

-(void)setupUI {
    self.localidadTextfield.hidden = YES;
    
    //Setup picker view for the gender textfield
    UIPickerView *genderPickerView = [[UIPickerView alloc] init];
    genderPickerView.dataSource = self;
    genderPickerView.delegate = self;
    genderPickerView.tag = genderPicker;
    self.genderTextfield.inputView = genderPickerView;
    
    //Setup picker view for the pacients gender textfield
    UIPickerView *pacientsGenderPickerView = [[UIPickerView alloc] init];
    pacientsGenderPickerView.delegate = self;
    pacientsGenderPickerView.dataSource = self;
    pacientsGenderPickerView.tag = pacientGenderPicker;
    self.pacientsGenderTextfield.inputView = pacientsGenderPickerView;
    
    //Setup picker view for the especialidad textfield
    UIPickerView *especialidadPickerView = [[UIPickerView alloc] init];
    especialidadPickerView.delegate = self;
    especialidadPickerView.dataSource = self;
    especialidadPickerView.tag = especialidadPicker;
    self.especialidadTextfield.inputView = especialidadPickerView;
    
    
    //Setup the picker view for the city textfield
    UIPickerView *cityPickerView = [[UIPickerView alloc] init];
    cityPickerView.delegate = self;
    cityPickerView.dataSource = self;
    cityPickerView.tag = cityPicker;
    self.cityTextfield.inputView = cityPickerView;
    
    //Setup the picker for the localidad textfield
    UIPickerView *localidadPickerView = [[UIPickerView alloc] init];
    localidadPickerView.dataSource = self;
    localidadPickerView.delegate = self;
    localidadPickerView.tag = localidadPicker;
    self.localidadTextfield.inputView = localidadPickerView;
    
    //Create a toolbar to dismiss the pickers
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 44.0)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissPickers)];
    toolbar.items = @[doneButton];
    self.cityTextfield.inputAccessoryView = toolbar;
    self.especialidadTextfield.inputAccessoryView = toolbar;
    self.genderTextfield.inputAccessoryView = toolbar;
    self.pacientsGenderTextfield.inputAccessoryView = toolbar;
    self.localidadTextfield.inputAccessoryView = toolbar;
}

#pragma mark - Actions 

-(void)dismissPickers {
    [self.cityTextfield resignFirstResponder];
    [self.especialidadTextfield resignFirstResponder];
    [self.genderTextfield resignFirstResponder];
    [self.pacientsGenderTextfield resignFirstResponder];
    [self.localidadTextfield resignFirstResponder];
}

- (IBAction)createButtonPressed:(id)sender {
    if ([self passwordsAreCorrect]) {
        if ([self formIsCorrect]) {
            [self createDoctorInServer];
            
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Hay campos incorrectos. Por favor revisa" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Las contraseñas no coinciden" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

#pragma mark - Form Validation

-(BOOL)passwordsAreCorrect {
    if ([self.passwordTextfield.text length] > 0 && [self.confirmPasswordTextfield.text length] > 0 && [self.passwordTextfield.text isEqualToString:self.confirmPasswordTextfield.text]) {
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)formIsCorrect {
    if ([self.nameTextfield.text length] > 0 && [self.lastnameTextfield.text length] > 0 && [self.emailTextfield.text length] > 0 && [self.genderTextfield.text length] > 0 && [self.pacientsGenderTextfield.text length] > 0 && [self.addressTextfield.text length] > 0 && [self.especialidadTextfield.text length] > 0 && [self.cityTextfield.text length] > 0 && [self.phoneTextfield.text length] > 0) {
        return YES;
    } else {
        return NO;
    }
}


- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Server Stuff 

-(void)createDoctorInServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    NSUInteger gender;
    NSUInteger pacientGender;
    if ([self.genderTextfield.text isEqualToString:@"Masculino"]) {
        gender = 1;
    } else if ([self.genderTextfield.text isEqualToString:@"Femenino"]){
        gender = 2;
    }
    
    if ([self.pacientsGenderTextfield.text isEqualToString:@"Hombres"]) {
        pacientGender = 1;
    } else if ([self.pacientsGenderTextfield.text isEqualToString:@"Mujeres"]) {
        pacientGender = 2;
    } else {
        pacientGender = 3;
    }
    
    NSError *error;
    NSDictionary *localidadDic = @{@"name" : self.localidadTextfield.text, @"lat": @40.0, @"lon" : @50.0};
    NSData *localidadData = [NSJSONSerialization dataWithJSONObject:localidadDic options:0 error:&error];
    if (error) {
        NSLog(@"ERROR CON EL VIEJO YEISON: %@", error);
    }
    NSString *localidadJSONString = [[NSString alloc] initWithData:localidadData encoding:NSUTF8StringEncoding];
    
    //Encode user password
    NSString *encodedPassword = [[self.passwordTextfield.text dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    
    NSString *doctorParameters = [NSString stringWithFormat:@"name=%@&lastname=%@&email=%@&password=%@&gender=%lu&patient_gender=%lu&address=%@&city=%@&practice_list=%@&phone=%@&localidad=%@", self.nameTextfield.text, self.lastnameTextfield.text, self.emailTextfield.text, encodedPassword, (unsigned long)gender, (unsigned long)pacientGender, self.addressTextfield.text, self.cityTextfield.text, self.especialidadTextfield.text, self.phoneTextfield.text, localidadJSONString];
    
    [serverCommunicator callServerWithPOSTMethod:@"Doctor/Create" andParameter:doctorParameters httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:@"Doctor/Create"]) {
        if (dictionary) {
            NSLog(@"Rspuesta correcta del doctor sign up: %@", dictionary);
            Doctor *doctor = [[Doctor alloc] initWithDoctorInfo:dictionary[@"response"]];
            [self saveDoctorInUserDefaults:doctor];
            [self goToDoctorHomePage];
        } else {
            NSLog(@"Respuesta incorrecta del doctor sign up: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Error en el serverrr: %@ %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Hubo un error creando el doctor. Por favor revisa que estés conectadoa internet e intenta de nuevo." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - Navigation

-(void)goToDoctorHomePage {
    UITabBarController *tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"DoctorTabBarController"];
    [self presentViewController:tabBarController animated:YES completion:nil];
}

#pragma mark - User Defaults

-(void)saveDoctorInUserDefaults:(Doctor *)doctor {
    NSLog(@"NOMBRE DEL DOCTOR A GUARDA: %@", doctor.name);
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:doctor];
    [[NSUserDefaults standardUserDefaults] setObject:encodedData forKey:@"doctor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UIPickerViewDataSource 

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == genderPicker) {
        return [self.genderNamesarray count];
    } else if (pickerView.tag == pacientGenderPicker) {
        return [self.pacientGendersArray count];
    } else if (pickerView.tag == especialidadPicker) {
        return [self.specialtiesArray count];
    } else if (pickerView.tag == cityPicker) {
        return [self.citiesNames count];
    } else if (pickerView.tag == localidadPicker) {
        return [self.localidadesArray count];
    } else return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == genderPicker) {
        return self.genderNamesarray[row];
    } else if (pickerView.tag == pacientGenderPicker) {
        return self.pacientGendersArray[row];
    } else if (pickerView.tag == especialidadPicker) {
        return self.specialtiesArray[row];
    } else if (pickerView.tag == cityPicker) {
        return self.citiesNames[row];
    } else if (pickerView.tag == localidadPicker) {
        return ((Localidad *)self.localidadesArray[row]).name;
    } else return nil;
}

#pragma mark - UIPickerViewDelegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == genderPicker) {
        self.genderTextfield.text = self.genderNamesarray[row];
    } else if (pickerView.tag == pacientGenderPicker) {
        self.pacientsGenderTextfield.text = self.pacientGendersArray[row];
    } else if (pickerView.tag == especialidadPicker) {
        self.especialidadTextfield.text = self.specialtiesArray[row];
    } else if (pickerView.tag == cityPicker) {
        self.cityTextfield.text = self.citiesNames[row];
        if ([self.cityTextfield.text isEqualToString:@"Bogotá"]) {
            self.localidadTextfield.hidden = NO;
        } else {
            self.localidadTextfield.text = @"";
            self.localidadTextfield.hidden = YES;
        }
    } else if (pickerView.tag == localidadPicker) {
        self.localidadTextfield.text = ((Localidad *)self.localidadesArray[row]).name;
    }
}

#pragma mark - UITextfieldDelgate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
