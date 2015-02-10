//
//  CreateAccountViewController.m
//  Doclinea
//
//  Created by Developer on 30/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "HomeScreenViewController.h"
#import "DeviceInfo.h"

@interface CreateAccountViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextfield;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastnameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *genderTextfield;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextfield;
@property (weak, nonatomic) IBOutlet UITextField *adressTextfield;
@property (weak, nonatomic) IBOutlet UITextField *cityTextfield;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textfields;
@property (assign, nonatomic) NSTimeInterval birthdayTimeStamp;

//Arrays
@property (strong, nonatomic) NSArray *genderNamesarray;
@property (strong, nonatomic) NSArray *citiesNames;
@end

@implementation CreateAccountViewController

enum {
    genrePicker = 1,
    cityPicker = 2,
    datePicker = 3
};

#pragma mark - Lazy Instantiation 

-(NSArray *)citiesNames {
    if (!_citiesNames) {
        _citiesNames = @[@"Bogotá", @"Medellín", @"Cali", @"Barranquilla", @"Pereira", @"Bucaramanga"];
    }
    return _citiesNames;
}

-(NSArray *)genderNamesarray {
    if (!_genderNamesarray) {
        _genderNamesarray = @[@"Masculino", @"Femenino"];
    }
    return _genderNamesarray;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + 160.0);
}

#pragma mark - Custom Initialization Stuff

-(void)setupUI {
    for (UITextField *textfield in self.textfields) {
        textfield.delegate = self;
    }
    
    //Set a UIPickerView as the input view for the gender textfield
    UIPickerView *genderPicker = [[UIPickerView alloc] init];
    genderPicker.delegate = self;
    genderPicker.dataSource = self;
    genderPicker.tag = genrePicker;
    self.genderTextfield.inputView = genderPicker;
    
    //Set up the picker view for the city textfield
    UIPickerView *cityPickerView = [[UIPickerView alloc] init];
    cityPickerView.delegate = self;
    cityPickerView.dataSource = self;
    cityPickerView.tag = cityPicker;
    self.cityTextfield.inputView = cityPickerView;
    
    //Setup the date picker view for the birthday textfield
    UIDatePicker *datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 50.0, 100.0, 50.0)];
    datePickerView.tag = datePicker;
    datePickerView.datePickerMode = UIDatePickerModeDate;
    [datePickerView addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    self.birthdayTextfield.inputView = datePickerView;
    
    //Create a toolbar to dismiss the pickers
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(inputAccessoryViewDidFinish)];
    [toolBar setItems:@[doneButton] animated:NO];
    self.genderTextfield.inputAccessoryView = toolBar;
    self.cityTextfield.inputAccessoryView = toolBar;
    self.birthdayTextfield.inputAccessoryView = toolBar;
}

#pragma mark - Actions 

-(void)dateChanged:(UIDatePicker *)datePicker {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSDate *date = datePicker.date;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: date];
    [components setHour: 12];
    NSDate *newDate = [gregorian dateFromComponents: components];
    
    self.birthdayTimeStamp = [newDate timeIntervalSince1970] * 1000;
    NSString *formattedDateString = [dateFormatter stringFromDate:newDate];
    NSLog(@"fecha: %@", formattedDateString);
    NSLog(@"Birthday timestamp: %f", self.birthdayTimeStamp);
    self.birthdayTextfield.text = formattedDateString;
}

-(void)goToHomeScreen {
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void)inputAccessoryViewDidFinish {
    [self.genderTextfield resignFirstResponder];
    [self.cityTextfield resignFirstResponder];
    [self.birthdayTextfield resignFirstResponder];
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)registerButtonPressed:(id)sender {
    if ([self passwordsAreCorrect]) {
        if ([self formIsCorrect]) {
            [self sendUserInfoToServer];
            
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Hay campos incorrectos en el formulario. Por favor revisa" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Las contraseñas no coinciden" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

#pragma mark - Server Stuff

-(void)sendUserInfoToServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSUInteger gender;
    
    if ([self.genderTextfield.text isEqualToString:@"Masculino"]) {
        gender = 1;
    } else if ([self.genderTextfield.text isEqualToString:@"Femenino"]){
        gender = 2;
    }
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    //Get device info
    /*NSDictionary *deviceInfoDic = @{@"type" : [UIDevice currentDevice].model, @"token" : [DeviceInfo sharedInstance].deviceToken, @"name" : [UIDevice currentDevice].name, @"os" : @"iOS"};
    NSData *deviceInfoData = [NSJSONSerialization dataWithJSONObject:deviceInfoDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *deviceInfoString = [[NSString alloc] initWithData:deviceInfoData encoding:NSUTF8StringEncoding];*/
    NSString *deviceInfoString = @"";
    
    //Encode user password
    NSString *encodedPassword = [[self.passwordTextfield.text dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    
    NSString *userParameters = [NSString stringWithFormat:@"name=%@&password=%@&lastname=%@&email=%@&gender=%lu&phone=%@&address=%@&city=%@&device_info=%@&birthday=%@", self.nameTextfield.text, encodedPassword, self.lastnameTextfield.text, self.emailTextfield.text, (unsigned long)gender, self.phoneTextfield.text, self.adressTextfield.text, self.cityTextfield.text, deviceInfoString, @(self.birthdayTimeStamp)];
    [serverCommunicator callServerWithPOSTMethod:@"User/Create" andParameter:userParameters httpMethod:@"POST"];
    NSLog(@"Timestamp enviadoooo: %f", self.birthdayTimeStamp);
}

#pragma mark - ServerCommunicatorDelegate

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:@"User/Create"]) {
        if (dictionary) {
            NSLog(@"Respuesta correcta del sign up: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                //Success creating the user
                /*User *user = [[User alloc] initWithUserDictionary:dictionary[@"response"]];
                [self saveUserInUserDefaults:user];
                [self goToHomeScreen];*/
                [[[UIAlertView alloc] initWithTitle:@"Éxito!" message:@"La cuenta se ha creado exitosamente. Se ha enviado un correo de confirmación al email asignado" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                [self dismissViewControllerAnimated:YES completion:nil];
                
            } else {
                NSLog(@"Llego la respuesta pero no se creó el usuario: %@", dictionary);
                if ([dictionary[@"code"] intValue] == 11000) {
                    //User already existed error
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"El correo ya está en uso" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                }
            }
        } else {
            NSLog(@"Respuesta incorrecta del sign up: %@", dictionary);
        }
    } else {
        
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Error en el server: %@ %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Hubo un error intentanto crear el usuario. Por favor intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
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
    if ([self.emailTextfield.text length] > 0 && [self.nameTextfield.text length] > 0 && [self.lastnameTextfield.text length] > 0 && [self.genderTextfield.text length] > 0 && [self.phoneTextfield.text length] > 0 && [self.adressTextfield.text length] > 0 && [self.cityTextfield.text length] > 0 && [self.birthdayTextfield.text length] > 0) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - User Defaults 

-(void)saveUserInUserDefaults:(User *)user {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:user];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UIPickerViewDataSource 

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == genrePicker) {
        return [self.genderNamesarray count];
    } else if (pickerView.tag == cityPicker) {
        return [self.citiesNames count];
    } else if (pickerView.tag == datePicker) {
        return 0;
    } else return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == genrePicker) {
        return self.genderNamesarray[row];
    } else if (pickerView.tag == cityPicker) {
        return self.citiesNames[row];
    } else if (pickerView.tag == datePicker) {
        return nil;
    } else return nil;
}

#pragma mark - UIPickerViewDelegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == genrePicker) {
        self.genderTextfield.text = self.genderNamesarray[row];
        
    } else if (pickerView.tag == cityPicker) {
        self.cityTextfield.text = self.citiesNames[row];
    
    } else if (pickerView.tag == datePicker) {
        
    }
}

#pragma mark - UItextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
