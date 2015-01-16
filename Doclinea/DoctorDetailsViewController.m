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

@interface DoctorDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *patientGenderLAbel;
@property (strong, nonatomic) UIImageView *doctorImageView;
@property (strong, nonatomic) UILabel *doctorNameLabel;
@property (strong, nonatomic) UILabel *doctorProfesionLabel;
@property (strong, nonatomic) UILabel *doctorAddressLabel;
@property (strong, nonatomic) RatingView *ratingView;
@property (strong, nonatomic) UILabel *educationLabel;
@end

@implementation DoctorDetailsViewController {
    CGRect screenBounds;
}

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
    self.doctorAddressLabel.text = [NSString stringWithFormat:@"%@, %@", self.doctor.address, self.doctor.city];
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
    /*UIButton *pedirCitaButton = [[UIButton alloc] initWithFrame:CGRectMake(self.doctorNameLabel.frame.origin.x, self.doctorAddressLabel.frame.origin.y + self.doctorAddressLabel.frame.size.height + 10.0, 70.0, 35.0)];
    [pedirCitaButton setTitle:@"Pedir Cita" forState:UIControlStateNormal];
    pedirCitaButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    [pedirCitaButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    pedirCitaButton.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:79.0/255.0 blue:19.0/255.0 alpha:1.0];
    pedirCitaButton.layer.cornerRadius = 5.0;
    [self.scrollView addSubview:pedirCitaButton];*/
    
    //Images button
    if ([self.doctor.gallery count] > 0 && [self.doctor.gallery[0] isKindOfClass:[NSDictionary class]]) {
        UIButton *imagesButton = [[UIButton alloc] initWithFrame:CGRectMake(self.doctorNameLabel.frame.origin.x, self.doctorAddressLabel.frame.origin.y + self.doctorAddressLabel.frame.size.height + 10.0, 70.0, 35.0)];
        [imagesButton setTitle:@"Imágenes" forState:UIControlStateNormal];
        [imagesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        imagesButton.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:159.0/255.0 blue:225.0/255.0 alpha:1.0];
        imagesButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
        imagesButton.layer.cornerRadius = 5.0;
        [imagesButton addTarget:self action:@selector(imagesButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:imagesButton];
    }
    
    //Rating View
    self.ratingView = [[RatingView alloc] initWithFrame:CGRectMake(20.0, self.doctorImageView.frame.origin.y + self.doctorImageView.frame.size.height + 4.0, self.doctorImageView.frame.size.width, 20.0) selectedImageName:@"blueStar.png" unSelectedImage:@"grayStar.png" minValue:0 maxValue:5 intervalValue:0.5 stepByStep:NO];
    self.ratingView.userInteractionEnabled = NO;
    self.ratingView.value = [self.doctor.overallRating intValue];
    [self.scrollView addSubview:self.ratingView];
    
    //Gray line view
    UIView *grayLine = [[UIView alloc] initWithFrame:CGRectMake(20.0, self.ratingView.frame.origin.y + self.ratingView.frame.size.height + 20.0, screenBounds.size.width - 40.0, 1.0)];
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
    UILabel *educationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, patientsLabel.frame.origin.y + patientsLabel.frame.size.height, 70.0, 30.0)];
    educationLabel.text = @"Educación: ";
    educationLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    [self.scrollView addSubview:educationLabel];
    
    //education list label
    UILabel *practiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(educationLabel.frame.origin.x + educationLabel.frame.size.width, educationLabel.frame.origin.y, screenBounds.size.width - 20.0 - (educationLabel.frame.origin.x + educationLabel.frame.size.width), 30.0)];
    practiceLabel.text = self.doctor.parsedEducationList;
    practiceLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    practiceLabel.textColor = [UIColor darkGrayColor];
    //practiceLabel.numberOfLines = 0;
    if ([self.doctor.parsedEducationList length] > 0) {
        //[practiceLabel sizeToFit];
    }
    [self.scrollView addSubview:practiceLabel];
    
    //Clinicas label
    UILabel *clinicasLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, practiceLabel.frame.origin.y + practiceLabel.frame.size.height, 70.0, 30.0)];
    clinicasLabel.text = @"Clínicas: ";
    clinicasLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    [self.scrollView addSubview:clinicasLabel];
    
    //Hospital list label
    UILabel *clinicsListLabel = [[UILabel alloc] initWithFrame:CGRectMake(clinicasLabel.frame.origin.x + clinicasLabel.frame.size.width, clinicasLabel.frame.origin.y, screenBounds.size.width - 20.0 - (clinicasLabel.frame.origin.x + clinicasLabel.frame.size.width), 30.0)];
    clinicsListLabel.text = self.doctor.parsedHospitalList;
    clinicsListLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    clinicsListLabel.textColor = [UIColor darkGrayColor];
    clinicsListLabel.numberOfLines = 0;
    if ([self.doctor.parsedHospitalList length] > 0) {
        //[clinicsListLabel sizeToFit];
    }
    [self.scrollView addSubview:clinicsListLabel];
    
    //"Seguros" label
    UILabel *insuranceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, clinicsListLabel.frame.origin.y + clinicsListLabel.frame.size.height, 70.0, 30.0)];
    insuranceLabel.text = @"Seguros: ";
    insuranceLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    [self.scrollView addSubview:insuranceLabel];
    
    //Insurance list label
    UILabel *insuranceListLabel = [[UILabel alloc] initWithFrame:CGRectMake(insuranceLabel.frame.origin.x + insuranceLabel.frame.size.width, insuranceLabel.frame.origin.y, screenBounds.size.width - 20.0 - (insuranceLabel.frame.origin.x + insuranceLabel.frame.size.width), 30.0)];
    insuranceListLabel.text = self.doctor.parsedInsurancesList;
    insuranceListLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    insuranceListLabel.textColor = [UIColor darkGrayColor];
    if ([self.doctor.parsedInsurancesList length] > 0) {
        //[insuranceListLabel sizeToFit];
    }
    [self.scrollView addSubview:insuranceListLabel];
    
    //"Miembro de" label
    UILabel *membershipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, insuranceListLabel.frame.origin.y + insuranceListLabel.frame.size.height, 80.0, 30.0)];
    membershipLabel.text = @"Miembro de: ";
    membershipLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    [self.scrollView addSubview:membershipLabel];
    
    //Membership list label
    UILabel *membershipListLabel = [[UILabel alloc] initWithFrame:CGRectMake(membershipLabel.frame.origin.x + membershipLabel.frame.size.width, membershipLabel.frame.origin.y, screenBounds.size.width - 20.0 - (membershipLabel.frame.origin.x + membershipLabel.frame.size.width), 30.0)];
    membershipListLabel.text = self.doctor.parsedProfesionalMembershipList;
    membershipListLabel.tag = 1;
    membershipListLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    membershipListLabel.textColor = [UIColor darkGrayColor];
    if ([self.doctor.parsedProfesionalMembershipList length] > 0) {
        //[membershipListLabel sizeToFit];
    }
    [self.scrollView addSubview:membershipListLabel];
}

#pragma mark - Actions 

-(void)imagesButtonPressed {
    [self goToDoctorImagesVC];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation 

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

@end
