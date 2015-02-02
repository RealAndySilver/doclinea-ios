//
//  MyProfileViewController.m
//  Doclinea
//
//  Created by Developer on 2/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "MyProfileViewController.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "ChangePasswordViewController.h"
//#import "ConfigurationViewController.h"
#import "MoreOptionsViewController.h"

@interface MyProfileViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextfield;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *genderTextfield;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextfield;
@property (weak, nonatomic) IBOutlet UITextField *addressTextfield;
@property (weak, nonatomic) IBOutlet UITextField *cityTextfield;
@property (assign, nonatomic) NSTimeInterval birthdayTimeStamp;
//@property (weak, nonatomic) IBOutlet UITextField *insuranceTextfield;
@property (strong, nonatomic) User *user;

//Arrays
@property (strong, nonatomic) NSArray *genderNamesarray;
@property (strong, nonatomic) NSArray *citiesNames;
@property (strong, nonatomic) NSArray *insurancesNames;
@end

@implementation MyProfileViewController

enum {
    genderPicker = 1,
    cityPicker,
    datePicker
};

#pragma mark - Lazy Instantiation

-(NSArray *)insurancesNames {
    if (!_insurancesNames) {
        _insurancesNames = @[@"Sura", @"Colpatria", @"Compensar"];
    }
    return _insurancesNames;
}

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

-(User *)user {
    if (!_user) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
            NSData *userEncodedData = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
            _user = [NSKeyedUnarchiver unarchiveObjectWithData:userEncodedData];
        }
    }
    return _user;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUserInfo];
    [self setupUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userUpdatedReceived) name:@"UserUpdatedInConfig" object:nil];
}

#pragma mark - Custom Initialization Stuff

-(void)setupUserInfo {
    NSLog(@"user name: %@", self.user.name);
    self.nameTextfield.text = self.user.name;
    self.lastNameTextfield.text = self.user.lastName;
    self.emailTextfield.text = self.user.email;
    self.phoneTextfield.text = self.user.phone;
    self.addressTextfield.text = self.user.address;
    self.cityTextfield.text = self.user.city;
    //self.insuranceTextfield.text = self.user.insurance;
    if ([self.user.gender intValue] == 1) {
        self.genderTextfield.text = @"Masculino";
    } else {
        self.genderTextfield.text = @"Femenino";
    }
    self.birthdayTextfield.text = [self getStringFromDate:self.user.birthday];
}

-(void)setupUI {
    //Setup the picker view for the gender textfield
    UIPickerView *genderPickerView = [[UIPickerView alloc] init];
    genderPickerView.dataSource = self;
    genderPickerView.delegate = self;
    genderPickerView.tag = genderPicker;
    self.genderTextfield.inputView = genderPickerView;
    
    //Setup the picker view for the city picker
    UIPickerView *cityPickerView = [[UIPickerView alloc] init];
    cityPickerView.delegate = self;
    cityPickerView.dataSource = self;
    cityPickerView.tag = cityPicker;
    self.cityTextfield.inputView = cityPickerView;
    
    //Setup the picker view for the insurance picker
    /*UIPickerView *insurancePickerView = [[UIPickerView alloc] init];
    insurancePickerView.delegate = self;
    insurancePickerView.dataSource = self;
    insurancePickerView.tag = insurancePicker;*/
    //self.insuranceTextfield.inputView = insurancePickerView;
    //Setup the date picker view for the birthday textfield
    
    UIDatePicker *datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 50.0, 100.0, 50.0)];
    datePickerView.tag = datePicker;
    datePickerView.datePickerMode = UIDatePickerModeDate;
    [datePickerView addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    self.birthdayTextfield.inputView = datePickerView;

    //Setup the toolbar for the picker view
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissPickerView)];
    [toolbar setItems:@[doneButton] animated:NO];
    self.genderTextfield.inputAccessoryView = toolbar;
    self.birthdayTextfield.inputAccessoryView = toolbar;
    self.cityTextfield.inputAccessoryView = toolbar;
}

#pragma mark - Actions 

-(void)dismissPickerView {
    [self.cityTextfield resignFirstResponder];
    [self.birthdayTextfield resignFirstResponder];
    //[self.insuranceTextfield resignFirstResponder];
    [self.genderTextfield resignFirstResponder];
}

- (IBAction)saveChangesButtonPressed:(id)sender {
    [self updateUserInServer];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Server Stuff 

-(void)updateUserInServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSUInteger gender;
    
    if ([self.genderTextfield.text isEqualToString:@"Masculino"]) {
        gender = 1;
    } else if ([self.genderTextfield.text isEqualToString:@"Femenino"]){
        gender = 2;
    }
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *userParameters = [NSString stringWithFormat:@"name=%@&lastname=%@&email=%@&gender=%lu&phone=%@&address=%@&city=%@&birthday=%@", self.nameTextfield.text, self.lastNameTextfield.text, self.emailTextfield.text, (unsigned long)gender, self.phoneTextfield.text, self.addressTextfield.text, self.cityTextfield.text, @(self.birthdayTimeStamp)];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"User/Update/%@", self.user.identifier] andParameter:userParameters httpMethod:@"POST"];
    NSLog(@"Time stamp enviadoo: %f", self.birthdayTimeStamp);
}

#pragma mark - ServerCommunicatorDelegate

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:[NSString stringWithFormat:@"User/Update/%@", self.user.identifier]]) {
        if (dictionary) {
            NSLog(@"Rspuesta correcta del update user: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                //User updated successfully
                [self saveUpdatedUserWithDic:dictionary[@"response"]];
                [[[UIAlertView alloc] initWithTitle:@"Usuario Actualizado" message:@"La información se ha actualizado correctamente." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            NSLog(@"Respuesta incorrecta del update user: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Errorrrrr: %@ %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Hubo un error actualizando los datos. Revisa que estés conectado a internet e intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Custom Methods

-(NSString *)getStringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    return formattedDateString;
    //NSLog(@"fecha: %@", formattedDateString);
    //NSLog(@"Birthday timestamp: %f", self.birthdayTimeStamp);
    //self.birthdayTextfield.text = formattedDateString;
}

-(void)dateChanged:(UIDatePicker *)datePicker {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSDate *date = datePicker.date;
    
    /*NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: date];
    [components setHour: 12];
    NSDate *newDate = [gregorian dateFromComponents: components];*/
    
    self.birthdayTimeStamp = [date timeIntervalSince1970] * 1000;
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    //NSLog(@"fecha: %@", formattedDateString);
    //NSLog(@"Birthday timestamp: %f", self.birthdayTimeStamp);
    self.birthdayTextfield.text = formattedDateString;
}

#pragma mark - User Defaults 

-(void)saveUpdatedUserWithDic:(NSDictionary *)userDic {
    User *user = [[User alloc] initWithUserDictionary:userDic];
    NSData *encodedUser = [NSKeyedArchiver archivedDataWithRootObject:user];
    [[NSUserDefaults standardUserDefaults] setObject:encodedUser forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UIPickerViewDataSource 

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == genderPicker) {
        return [self.genderNamesarray count];
    } else if (pickerView.tag == cityPicker) {
        return [self.citiesNames count];
    } else return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == genderPicker) {
        return self.genderNamesarray[row];
    } else if (pickerView.tag == cityPicker) {
        return self.citiesNames[row];
    } else return nil;
}

#pragma mark - UIPickerViewDelegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == genderPicker) {
        self.genderTextfield.text = self.genderNamesarray[row];
    } else if (pickerView.tag == cityPicker) {
        self.cityTextfield.text = self.citiesNames[row];
    } else if (pickerView.tag == datePicker) {
        //self.insuranceTextfield.text = self.insurancesNames[row];
    }
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Navigation 

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    /*if ([segue.identifier isEqualToString:@"ChangePasswordSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[ChangePasswordViewController class]]) {
            ChangePasswordViewController *changePassVC = (ChangePasswordViewController *)segue.destinationViewController;
            changePassVC.userType = @"user";
        }
    } else if ([segue.identifier isEqualToString:@"ConfigurationSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[ConfigurationViewController class]]) {
            ConfigurationViewController *configVC = (ConfigurationViewController *)segue.destinationViewController;
            configVC.delegate = self;
            configVC.user = self.user;
        }
    }*/
    if ([segue.identifier isEqualToString:@"MoreOptionsSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[MoreOptionsViewController class]]) {
            MoreOptionsViewController *optionsVC = (MoreOptionsViewController *)segue.destinationViewController;
            optionsVC.user = self.user;
        }
    }
}

#pragma mark - Notifications 

-(void)userUpdatedReceived {
    NSLog(@"Me llegooooooooooo");
    self.user = nil;
    [self setupUserInfo];
}

/*#pragma mark - ConfigurationViewControllerDelegate

-(void)userUpdatedInConfigVC {
    NSLog(@"Recibí el delegateeeee");
    self.user = nil;
    [self setupUserInfo];
}*/

@end
