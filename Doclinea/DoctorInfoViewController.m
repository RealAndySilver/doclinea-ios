//
//  DoctorInfoViewController.m
//  Doclinea
//
//  Created by Developer on 6/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "DoctorInfoViewController.h"
#import "Doctor.h"
#import "Localidad+Shared.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"
#import "SharedDoctor.h"
#import "UIImageView+WebCache.h"
@import MobileCoreServices;

@interface DoctorInfoViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ServerCommunicatorDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *doctorImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *genderTextfield;
@property (weak, nonatomic) IBOutlet UITextField *pacientsGenderTextfield;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextfield;
@property (weak, nonatomic) IBOutlet UITextField *addressTextfield;
@property (weak, nonatomic) IBOutlet UITextField *especialidadTextfield;
@property (weak, nonatomic) IBOutlet UITextField *cityTextfield;
@property (weak, nonatomic) IBOutlet UILabel *localidadLabel;
@property (weak, nonatomic) IBOutlet UITextField *localidadTextfield;
@property (strong, nonatomic) Doctor *doctor;
@property (strong, nonatomic) UIImage *profilePic;

//Arrays
@property (strong, nonatomic) NSArray *localidadesArray;
@property (strong, nonatomic) NSArray *genderNamesarray;
@property (strong, nonatomic) NSArray *pacientGendersArray;
@property (strong, nonatomic) NSArray *specialtiesArray;
@property (strong, nonatomic) NSArray *citiesNames;
@end

@implementation DoctorInfoViewController

enum {
    genderPicker = 1,
    pacientGenderPicker,
    especialidadPicker,
    cityPicker,
    localidadPicker
};

#pragma mark - Lazy Instantiation

-(Doctor *)doctor {
    if (!_doctor) {
        _doctor = [[SharedDoctor sharedDoctor] getSavedDoctor];
    }
    return _doctor;
}

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

#pragma mark - Custom Initiliazation Stuff

-(void)setupUI {
    self.nameTextfield.text = self.doctor.name;
    self.lastNameTextfield.text = self.doctor.lastName;
    self.emailTextfield.text = self.doctor.email;
    if ([self.doctor.gender intValue] == 1) {
        self.genderTextfield.text = @"Masculino";
    } else {
        self.genderTextfield.text = @"Femenino";
    }
    
    if ([self.doctor.patientGender intValue] == 1) {
        self.pacientsGenderTextfield.text = @"Hombres";
    } else if ([self.doctor.patientGender intValue] == 2) {
        self.pacientsGenderTextfield.text = @"Mujeres";
    } else {
        self.pacientsGenderTextfield.text = @"Hombres y Mujeres";
    }
    
    self.phoneTextfield.text = [self.doctor.phone description];
    self.addressTextfield.text = self.doctor.address;
    self.especialidadTextfield.text = self.doctor.practiceList[0];
    self.cityTextfield.text = self.doctor.city;
    if (![self.cityTextfield.text isEqualToString:@"Bogotá"]) {
        self.localidadTextfield.hidden = YES;
        self.localidadLabel.hidden = YES;
    } else {
        self.localidadTextfield.text = ((Localidad *)self.doctor.localidad).name;
    }
    
    if ([self.doctor.gender intValue] == 1) {
        //Male
        [self.doctorImageView sd_setImageWithURL:self.doctor.profilePic placeholderImage:[UIImage imageNamed:@"DoctorMale"]];
    } else {
        //Female
        [self.doctorImageView sd_setImageWithURL:self.doctor.profilePic placeholderImage:[UIImage imageNamed:@"DoctorFemale"]];
    }
    
    ///////////////////////////////////////////////////////////////////////////
    //Pickers Setup
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
    [self.localidadTextfield resignFirstResponder];
    [self.cityTextfield resignFirstResponder];
    [self.genderTextfield resignFirstResponder];
    [self.pacientsGenderTextfield resignFirstResponder];
    [self.especialidadTextfield resignFirstResponder];
}

- (IBAction)profileImageTapped:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Foto de Perfil" message:@"¿De donde deseas elegir tu foto de perfil?" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Cámara", @"Librería de Fotos", nil] show];
}

- (IBAction)saveChangesButtonPressed:(id)sender {
    [self saveDoctorInfoInServer];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Server Stuff

-(void)sendPhotoToServer:(UIImage *)photo {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    // post body
    NSMutableData *body = [NSMutableData data];
    NSString *boundary = @"------VohpleBoundary4QuqLuM1cE5lMwCy";

    // add params (all params are strings)
    /*for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }*/
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation(photo, 0.5);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"profilepic.jpg\"\r\n", @"image"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@",[NSString stringWithFormat:@"Doctor/UpdateProfilePic/%@", self.doctor.identifier]);
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"Doctor/UpdateProfilePic/%@", self.doctor.identifier] andData:body];
}

-(void)saveDoctorInfoInServer {
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
    NSString *localidadJSONString = [[NSString alloc] initWithData:localidadData encoding:NSUTF8StringEncoding];
  
    NSString *parameters = [NSString stringWithFormat:@"name=%@&lastname=%@&email=%@&gender=%lu&patient_gender=%lu&phone=%@&address=%@&city=%@&localidad=%@", self.nameTextfield.text, self.lastNameTextfield.text, self.emailTextfield.text, (unsigned long)gender, (unsigned long)pacientGender, self.phoneTextfield.text, self.addressTextfield.text, self.cityTextfield.text, localidadJSONString];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"Doctor/Update/%@", self.doctor.identifier] andParameter:parameters httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:[NSString stringWithFormat:@"Doctor/Update/%@", self.doctor.identifier]]) {
        if (dictionary) {
            NSLog(@"Resputa valida del udpate doctor: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                Doctor *doctor = [[Doctor alloc] initWithDoctorInfo:dictionary[@"response"]];
                [self saveUpdatedDoctorInUserDefaults:doctor];
                [[[UIAlertView alloc] initWithTitle:@"Doctor Actualizado!" message:@"Los datos se han podido actualizar correctamente" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            } else {
                NSLog(@"El doctor no se actualizó con éxito");
            }
        } else {
            NSLog(@"Respuesta invalida del update doctor: %@", dictionary);
        }
    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"Doctor/UpdateProfilePic/%@", self.doctor.identifier]]) {
        if (dictionary) {
            NSLog(@"Respuesta exitosa del update profile pic: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                //Success
                [[[UIAlertView alloc] initWithTitle:@"Éxito!" message:@"La foto de perfil se ha modificado de forma exitosa. Puede tardarse un momento en actualizar" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                self.doctorImageView.image = self.profilePic;
            }
        } else {
            NSLog(@"Respuesta inválida del update profile pic: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Error en el server: %@ %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error intentando actualizar los datos. Por favor revisa que estés conectado a internet e intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - User Defaults

-(void)saveUpdatedDoctorInUserDefaults:(Doctor *)doctor {
    NSLog(@"NOMBRE DEL DOCTOR A GUARDA: %@", doctor.name);
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:doctor];
    [[NSUserDefaults standardUserDefaults] setObject:encodedData forKey:@"doctor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Camera Stuff

-(void)presentImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = sourceType;
            picker.mediaTypes = @[(NSString *)kUTTypeImage];
            picker.allowsEditing = YES;
            picker.delegate = self;
            
            //Present the picker
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
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
            self.localidadLabel.hidden = NO;
        } else {
            self.localidadTextfield.text = @"";
            self.localidadTextfield.hidden = YES;
            self.localidadLabel.hidden = YES;
        }
    } else if (pickerView.tag == localidadPicker) {
        self.localidadTextfield.text = ((Localidad *)self.localidadesArray[row]).name;
    }
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //Camara
        [self presentImagePicker:UIImagePickerControllerSourceTypeCamera];
    } else if (buttonIndex == 2) {
        //Libreria
        [self presentImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *photo = info[UIImagePickerControllerEditedImage];
    if (!photo) photo = info[UIImagePickerControllerOriginalImage];
    if (photo) {
        [self sendPhotoToServer:photo];
        self.profilePic = photo;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
