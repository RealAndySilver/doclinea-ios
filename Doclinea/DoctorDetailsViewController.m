//
//  DoctorDetailsViewController.m
//  Doclinea
//
//  Created by Developer on 1/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "DoctorDetailsViewController.h"
#import "MapViewController.h"
#import "Doctor.h"
#import "UIImageView+WebCache.h"
#import "RatingView.h"
#import "PicturesViewController.h"
#import "AvailableAppointmentsViewController.h"
#import "ServerCommunicator.h"
#import "User.h"
#import "MBProgressHUD.h"

@interface DoctorDetailsViewController () <UIAlertViewDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *patientGenderLAbel;
@property (strong, nonatomic) UIImageView *doctorImageView;
@property (strong, nonatomic) UILabel *doctorNameLabel;
@property (strong, nonatomic) UILabel *doctorProfesionLabel;
@property (strong, nonatomic) UILabel *doctorAddressLabel;
@property (strong, nonatomic) RatingView *ratingView;
@property (strong, nonatomic) UILabel *educationLabel;
@property (strong, nonatomic) User *user;
@end

@implementation DoctorDetailsViewController {
    CGRect screenBounds;
}

#pragma mark - Lazy Instantiation 

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
    screenBounds = [UIScreen mainScreen].bounds;
    [self setupUI];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UILabel *bottomLabel = (UILabel *)[self.scrollView viewWithTag:1];
    self.scrollView.contentSize = CGSizeMake(screenBounds.size.width, bottomLabel.frame.origin.y + bottomLabel.frame.size.height + 20.0);
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"TAMANO DEL SCROLLVIEW: %@", NSStringFromCGRect(self.scrollView.frame));
    NSLog(@"CONTENT SIZE: %@", NSStringFromCGSize(self.scrollView.contentSize));
}

#pragma mark - Custom Initialization Stuff

-(void)setupUI {
    //Setup Doctor image
    self.doctorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 10.0, screenBounds.size.width/4.0, screenBounds.size.height/4.5)];
    if ([self.doctor.gender intValue] == 1) {
        [self.doctorImageView sd_setImageWithURL:self.doctor.profilePic placeholderImage:[UIImage imageNamed:@"DoctorMale"]];
    } else {
        [self.doctorImageView sd_setImageWithURL:self.doctor.profilePic placeholderImage:[UIImage imageNamed:@"DoctorFemale"]];
    }
    self.doctorImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.doctorImageView.clipsToBounds = YES;
    [self.scrollView addSubview:self.doctorImageView];
    
    //Doctor Name Label
    self.doctorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.doctorImageView.frame.origin.x + self.doctorImageView.frame.size.width + 10.0, self.doctorImageView.frame.origin.y, screenBounds.size.width - (self.doctorImageView.frame.origin.x + self.doctorImageView.frame.size.width + 10.0) - 20.0, 30.0)];
    if ([self.doctor.gender intValue] == 1) {
        self.doctorNameLabel.text = [NSString stringWithFormat:@"Dr. %@", self.doctor.completeName];
    } else {
        self.doctorNameLabel.text = [NSString stringWithFormat:@"Dra. %@", self.doctor.completeName];
    }
    self.doctorNameLabel.textColor = [UIColor blackColor];
    self.doctorNameLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
    self.doctorNameLabel.numberOfLines = 0;
    [self.doctorNameLabel sizeToFit];
    //self.doctorNameLabel.adjustsFontSizeToFitWidth = YES;
    [self.scrollView addSubview:self.doctorNameLabel];
    
    //Doctor main profesion label
    self.doctorProfesionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.doctorNameLabel.frame.origin.x, self.doctorNameLabel.frame.origin.y + self.doctorNameLabel.frame.size.height, self.doctorNameLabel.frame.size.width, 30.0)];
    if (self.doctor.practiceList.count > 0) {
        self.doctorProfesionLabel.text = self.doctor.practiceList[0];
    }
    self.doctorProfesionLabel.textColor = [UIColor darkGrayColor];
    self.doctorProfesionLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    self.doctorProfesionLabel.adjustsFontSizeToFitWidth = YES;
    [self.scrollView addSubview:self.doctorProfesionLabel];
    
    //Doctor address label
    self.doctorAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.doctorNameLabel.frame.origin.x, self.doctorNameLabel.frame.origin.y + self.doctorNameLabel.frame.size.height + 30.0, self.doctorNameLabel.frame.size.width, 30.0)];
    if (self.doctor.locationList.count > 0) {
        self.doctorAddressLabel.text = [NSString stringWithFormat:@"%@, %@", self.doctor.locationList[0][@"location_address"], self.doctor.city];
    }
    self.doctorAddressLabel.textColor = [UIColor darkGrayColor];
    self.doctorAddressLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    self.doctorAddressLabel.numberOfLines = 0;
    [self.doctorAddressLabel sizeToFit];
    [self.scrollView addSubview:self.doctorAddressLabel];
    
    //Parking image view
    if (self.doctor.hasParking) {
        UIImageView *parkingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.doctorAddressLabel.frame.origin.x + self.doctorAddressLabel.frame.size.width + 10.0, self.doctorAddressLabel.frame.origin.y, 20.0, 20.0)];
        parkingImageView.image = [UIImage imageNamed:@"Parking"];
        [self.scrollView addSubview:parkingImageView];
    }
    
    //"Pedir Cita" button
    UIButton *pedirCitaButton = [[UIButton alloc] initWithFrame:CGRectMake(self.doctorNameLabel.frame.origin.x, self.doctorAddressLabel.frame.origin.y + self.doctorAddressLabel.frame.size.height + 10.0, 70.0, 35.0)];
    [pedirCitaButton setTitle:@"Pedir Cita" forState:UIControlStateNormal];
    pedirCitaButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    [pedirCitaButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    pedirCitaButton.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:79.0/255.0 blue:19.0/255.0 alpha:1.0];
    pedirCitaButton.layer.cornerRadius = 5.0;
    [pedirCitaButton addTarget:self action:@selector(goToCitasVC) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:pedirCitaButton];
    
    //Images button
    if ([self.doctor.gallery count] > 0 && [self.doctor.gallery[0] isKindOfClass:[NSDictionary class]]) {
        UIButton *imagesButton = [[UIButton alloc] initWithFrame:CGRectOffset(pedirCitaButton.frame, pedirCitaButton.frame.size.width + 10.0, 0.0)];
        [imagesButton setTitle:@"Imágenes" forState:UIControlStateNormal];
        [imagesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        imagesButton.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:159.0/255.0 blue:225.0/255.0 alpha:1.0];
        imagesButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
        imagesButton.layer.cornerRadius = 5.0;
        [imagesButton addTarget:self action:@selector(imagesButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:imagesButton];
    }
    
    UIButton *favoriteButton = [[UIButton alloc] initWithFrame:CGRectMake(self.doctorNameLabel.frame.origin.x, pedirCitaButton.frame.origin.y + pedirCitaButton.frame.size.height + 10.0, 150.0, 35.0)];
    [favoriteButton setTitle:@"Añadir a Favoritos" forState:UIControlStateNormal];
    [favoriteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    favoriteButton.layer.cornerRadius = 5.0;
    favoriteButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    favoriteButton.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:159.0/255.0 blue:225.0/255.0 alpha:1.0];
    [favoriteButton addTarget:self action:@selector(favDoctorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:favoriteButton];
    
    //Rating View
    self.ratingView = [[RatingView alloc] initWithFrame:CGRectMake(20.0, self.doctorImageView.frame.origin.y + self.doctorImageView.frame.size.height + 4.0, self.doctorImageView.frame.size.width, 20.0) selectedImageName:@"blueStar.png" unSelectedImage:@"grayStar.png" minValue:0 maxValue:5 intervalValue:0.5 stepByStep:NO];
    self.ratingView.userInteractionEnabled = NO;
    self.ratingView.value = [self.doctor.overallRating intValue];
    [self.scrollView addSubview:self.ratingView];
    
    //Gray line view
    UIView *grayLine = [[UIView alloc] initWithFrame:CGRectMake(20.0, self.ratingView.frame.origin.y + self.ratingView.frame.size.height + 50.0, screenBounds.size.width - 40.0, 1.0)];
    grayLine.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.scrollView addSubview:grayLine];
    
    //"Atiende a" label
    UILabel *atiendeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, grayLine.frame.origin.y + grayLine.frame.size.height + 20.0, 70.0, 30.0)];
    atiendeLabel.text = @"Atiende a:";
    atiendeLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    [self.scrollView addSubview:atiendeLabel];
    
    //patients label
    UILabel *patientsLabel = [[UILabel alloc] initWithFrame:CGRectMake(atiendeLabel.frame.origin.x + atiendeLabel.frame.size.width, atiendeLabel.frame.origin.y, screenBounds.size.width - 20.0 - (atiendeLabel.frame.origin.x + atiendeLabel.frame.size.width), 30.0)];
    if ([self.doctor.patientGender intValue] == 1) {
        patientsLabel.text = @"Hombres";
    } else if ([self.doctor.patientGender intValue] == 2) {
        patientsLabel.text = @"Mujeres";
    } else {
        patientsLabel.text = @"Hombres y Mujeres";
    }
    patientsLabel.textColor = [UIColor darkGrayColor];
    patientsLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    [self.scrollView addSubview:patientsLabel];
    
    //"Educacion: "label
    UILabel *educationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, patientsLabel.frame.origin.y + patientsLabel.frame.size.height + 10.0, 70.0, 30.0)];
    educationLabel.text = @"Educación: ";
    educationLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    [self.scrollView addSubview:educationLabel];
    
    //education list label
    UILabel *practiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(educationLabel.frame.origin.x + educationLabel.frame.size.width, educationLabel.frame.origin.y - 10.0, screenBounds.size.width - 20.0 - (educationLabel.frame.origin.x + educationLabel.frame.size.width), 50.0)];
    practiceLabel.text = self.doctor.parsedEducationList;
    practiceLabel.minimumScaleFactor = 0.8;
    practiceLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    practiceLabel.textColor = [UIColor darkGrayColor];
    practiceLabel.numberOfLines = 0;
    if ([self.doctor.parsedEducationList length] > 0) {
        //[practiceLabel sizeToFit];
    }
    [self.scrollView addSubview:practiceLabel];
    
    //Clinicas label
    UILabel *clinicasLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, practiceLabel.frame.origin.y + practiceLabel.frame.size.height + 10.0, 70.0, 30.0)];
    clinicasLabel.text = @"Clínicas: ";
    clinicasLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    [self.scrollView addSubview:clinicasLabel];
    
    //Hospital list label
    UILabel *clinicsListLabel = [[UILabel alloc] initWithFrame:CGRectMake(clinicasLabel.frame.origin.x + clinicasLabel.frame.size.width, clinicasLabel.frame.origin.y - 10.0, screenBounds.size.width - 20.0 - (clinicasLabel.frame.origin.x + clinicasLabel.frame.size.width), 50.0)];
    clinicsListLabel.text = self.doctor.parsedHospitalList;
    clinicsListLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    clinicsListLabel.textColor = [UIColor darkGrayColor];
    clinicsListLabel.minimumScaleFactor = 0.8;
    clinicsListLabel.numberOfLines = 0;
    if ([self.doctor.parsedHospitalList length] > 0) {
        //[clinicsListLabel sizeToFit];
    }
    [self.scrollView addSubview:clinicsListLabel];
    
    //"Seguros" label
    UILabel *insuranceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, clinicsListLabel.frame.origin.y + clinicsListLabel.frame.size.height + 10.0, 70.0, 30.0)];
    insuranceLabel.text = @"Seguros: ";
    insuranceLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    [self.scrollView addSubview:insuranceLabel];
    
    //Insurance list label
    UILabel *insuranceListLabel = [[UILabel alloc] initWithFrame:CGRectMake(insuranceLabel.frame.origin.x + insuranceLabel.frame.size.width, insuranceLabel.frame.origin.y - 10.0, screenBounds.size.width - 20.0 - (insuranceLabel.frame.origin.x + insuranceLabel.frame.size.width), 50.0)];
    insuranceListLabel.text = self.doctor.parsedInsurancesList;
    insuranceListLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    insuranceListLabel.textColor = [UIColor darkGrayColor];
    insuranceListLabel.minimumScaleFactor = 0.8;
    insuranceListLabel.numberOfLines = 0;
    if ([self.doctor.parsedInsurancesList length] > 0) {
        //[insuranceListLabel sizeToFit];
    }
    [self.scrollView addSubview:insuranceListLabel];
    
    //"Miembro de" label
    UILabel *membershipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, insuranceListLabel.frame.origin.y + insuranceListLabel.frame.size.height + 10.0, 80.0, 30.0)];
    membershipLabel.text = @"Miembro de: ";
    membershipLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    [self.scrollView addSubview:membershipLabel];
    
    //Membership list label
    UILabel *membershipListLabel = [[UILabel alloc] initWithFrame:CGRectMake(membershipLabel.frame.origin.x + membershipLabel.frame.size.width, membershipLabel.frame.origin.y - 10.0, screenBounds.size.width - 20.0 - (membershipLabel.frame.origin.x + membershipLabel.frame.size.width), 50.0)];
    membershipListLabel.text = self.doctor.parsedProfesionalMembershipList;
    membershipListLabel.tag = 1;
    membershipListLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    membershipListLabel.textColor = [UIColor darkGrayColor];
    membershipListLabel.numberOfLines = 0;
    if ([self.doctor.parsedProfesionalMembershipList length] > 0) {
        //[membershipListLabel sizeToFit];
    }
    [self.scrollView addSubview:membershipListLabel];
}

#pragma mark - Actions 
- (void)favDoctorButtonPressed:(id)sender {
    [[[UIAlertView alloc] initWithTitle:nil message:@"¿Deseas agregar este doctor a tus favoritos?" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Agregar", nil] show];
}

-(void)imagesButtonPressed {
    [self goToDoctorImagesVC];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation 

-(void)goToCitasVC {
    AvailableAppointmentsViewController *availableAppointmentsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AvailableAppointments"];
    availableAppointmentsVC.doctor = self.doctor;
    [self.navigationController pushViewController:availableAppointmentsVC animated:YES];
}

-(void)goToDoctorImagesVC {
    PicturesViewController *picturesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Pictures"];
    picturesVC.picturesArray = self.doctor.gallery;
    [self.navigationController pushViewController:picturesVC animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MapSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[MapViewController class]]) {
            MapViewController *mapVC = (MapViewController *)segue.destinationViewController;
            mapVC.placesArray = self.doctor.locationList;
        }
    }
}

#pragma mark - Server Stuff 

-(void)addDocToFavInServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"User/Fav/%@", self.user.identifier] andParameter:[NSString stringWithFormat:@"doctor_id=%@", self.doctor.identifier] httpMethod:@"POST"];
}

#pragma mark - ServerCommunicatorDelegate

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:[NSString stringWithFormat:@"User/Fav/%@", self.user.identifier]]) {
        if (dictionary) {
            if ([dictionary[@"status"] boolValue]) {
                NSLog(@"Resputa correcta del doctor fav: %@", dictionary);
                [[[UIAlertView alloc] initWithTitle:@"Éxito!" message:@"Se ha agregado el doctor a tus favoritos." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            } else {
                NSLog(@"Respuesta incorrecta del doctor fav: %@", dictionary);
                [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"No fue posible agregar el doctor a tus favoritos" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            
        } else {
            NSLog(@"Respuesta null del doctor fav: %@", dictionary);
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Ocurrió un error en el servidor al intentar agregar el doctor a tus favoritos. Por favor intenta de nuevo en un momento" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Hay un error en el servidor, por favor intenta de nuevo en un momento." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Add to fav alert
    if (buttonIndex == 1) {
        //Add doctor
        [self addDocToFavInServer];
    }
}

@end
