//
//  EducationDetailsViewController.m
//  Doclinea
//
//  Created by Developer on 10/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "EducationDetailsViewController.h"
#import "Doctor.h"
#import "SharedDoctor.h"
#import "Studie.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"

@interface EducationDetailsViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UITextField *instituteTextfield;
@property (weak, nonatomic) IBOutlet UITextField *degreeTextfield;
@property (weak, nonatomic) IBOutlet UITextField *startYearTextfield;
@property (weak, nonatomic) IBOutlet UITextField *endYearTextfield;
@property (weak, nonatomic) IBOutlet UITextView *hilightsTextview;
@property (strong, nonatomic) NSMutableArray *yearsArray;
@property (strong, nonatomic) Doctor *doctor;
@end

@implementation EducationDetailsViewController

typedef NS_ENUM(NSUInteger, pickerType) {
    startYearPicker,
    endYearPicker
};

#pragma mark - Lazy Instantiation

-(NSMutableArray *)yearsArray {
    if (!_yearsArray) {
        _yearsArray = [[NSMutableArray alloc] init];
        for (int i = 1950; i < 2020; i++) {
            [_yearsArray addObject:@(i)];
        }
    }
    return _yearsArray;
}

-(Doctor *)doctor {
    if (!_doctor) {
        _doctor = [[SharedDoctor sharedDoctor] getSavedDoctor];
    }
    return _doctor;
}

#pragma markr - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

#pragma mark - Custom Initialization Stuff

-(void)setupUI {
    self.hilightsTextview.layer.cornerRadius = 10.0;
    self.hilightsTextview.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
    self.hilightsTextview.layer.borderWidth = 1.0;
    
    //Fill the textfields with the studie info
    Studie *studie = self.doctor.educationList[self.indexForSelectedStudie];
    self.instituteTextfield.text = studie.instituteName;
    self.degreeTextfield.text = studie.degree;
    self.startYearTextfield.text = studie.startYear;
    self.endYearTextfield.text = studie.endYear;
    self.hilightsTextview.text = studie.highlights;
    
    //Create pickers for the start year and end year textfields
    UIPickerView *startYearPickerView = [[UIPickerView alloc] init];
    startYearPickerView.tag = startYearPicker;
    startYearPickerView.delegate = self;
    startYearPickerView.dataSource = self;
    self.startYearTextfield.inputView = startYearPickerView;
    
    UIPickerView *endYearPickerView = [[UIPickerView alloc] init];
    endYearPickerView.delegate = self;
    endYearPickerView.dataSource = self;
    endYearPickerView.tag = endYearPicker;
    self.endYearTextfield.inputView = endYearPickerView;
    
    //Toolbar fot the donde button
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 44.0)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissPickers)];
    [toolbar setItems:@[doneButton] animated:NO];
    self.startYearTextfield.inputAccessoryView = toolbar;
    self.endYearTextfield.inputAccessoryView = toolbar;
    self.hilightsTextview.inputAccessoryView = toolbar;
}

#pragma mark - Actions

- (IBAction)saveButtonPressed:(id)sender {
    if ([self.instituteTextfield.text length] > 0) {
        Studie *studie = [[Studie alloc] init];
        studie.instituteName = self.instituteTextfield.text;
        studie.degree = self.degreeTextfield.text;
        studie.startYear = self.startYearTextfield.text;
        studie.endYear = self.endYearTextfield.text;
        studie.highlights = self.hilightsTextview.text;
        [self saveStudieInServer:studie];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Debes agregar al menos el nombre de la universidad en donde realizaste los estudios." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)dismissPickers {
    [self.startYearTextfield resignFirstResponder];
    [self.endYearTextfield resignFirstResponder];
    [self.hilightsTextview resignFirstResponder];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Server Stuff

-(void)saveStudieInServer:(Studie *)studie {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    NSMutableArray *studiesArray = [NSMutableArray arrayWithArray:self.doctor.educationList];
    [studiesArray replaceObjectAtIndex:self.indexForSelectedStudie withObject:studie];
    
    NSMutableArray *educationArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [studiesArray count]; i++) {
        Studie *studie = studiesArray[i];
        NSLog(@"legare al dic %@ %@ %@ %@ %@", studie.instituteName, studie.degree, studie.startYear, studie.endYear, studie.highlights);
        NSDictionary *studieDic = [NSDictionary dictionaryWithDictionary:[studie studieAsDictionary]];
        [educationArray addObject:studieDic];
        NSLog(@"guarde uno");
    }
    
    NSData *educationData = [NSJSONSerialization dataWithJSONObject:educationArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *educationString = [[NSString alloc] initWithData:educationData encoding:NSUTF8StringEncoding];
    
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"Doctor/Update/%@", self.doctor.identifier] andParameter:[NSString stringWithFormat:@"education_list=%@", educationString] httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:[NSString stringWithFormat:@"Doctor/Update/%@", self.doctor.identifier]]) {
        if (dictionary) {
            NSLog(@"Rspuesta correcta del update: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                //Success saving studies
                [[[UIAlertView alloc] initWithTitle:@"Éxito!" message:@"Información actualizada con éxito" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                Doctor *doctor = [[Doctor alloc] initWithDoctorInfo:dictionary[@"response"]];
                [self saveDoctorInUserDefaults:doctor];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EducationUpdated" object:nil];
            }
        } else {
            NSLog(@"Respueta incorrecta del update: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error intentanto enviar la información al servidor. Por favor revisa que estés conectado a internet e intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - User Defaults

-(void)saveDoctorInUserDefaults:(Doctor *)doctor {
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:doctor];
    [[NSUserDefaults standardUserDefaults] setObject:encodedData forKey:@"doctor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.yearsArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.yearsArray[row] description];
}

#pragma mark - UIPickerViewDelegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == startYearPicker) {
        self.startYearTextfield.text = [self.yearsArray[row] description];
    } else if (pickerView.tag == endYearPicker) {
        self.endYearTextfield.text = [self.yearsArray[row] description];
    }
}


#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end
