//
//  DoctorLocationViewController.m
//  Doclinea
//
//  Created by Developer on 7/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "DoctorLocationViewController.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"
#import "Doctor.h"
#import "SharedDoctor.h"
#import "DoctorLocationInfoView.h"
@import CoreLocation;
@import MapKit;

@interface DoctorLocationViewController () <ServerCommunicatorDelegate, DoctorLocationViewDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) CLLocationCoordinate2D consultorioCoordintate;
@property (strong, nonatomic) Doctor *doctor;
@end

@implementation DoctorLocationViewController

#pragma mark - Lazy Instantiation 

-(Doctor *)doctor {
    if (!_doctor) {
        _doctor = [[SharedDoctor sharedDoctor] getSavedDoctor];
    }
    return _doctor;
}

#pragma mark - View Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    [self setupDoctorWorkPlacesInMap];
}

#pragma mark - Custom Initialization Stuff

-(void)setupDoctorWorkPlacesInMap {
    //Get the locations and place a pin
    NSMutableArray *pointAnnotationsArray = [[NSMutableArray alloc] initWithCapacity:[self.doctor.locationList count]];
    for (int i = 0; i < [self.doctor.locationList count]; i++) {
        NSDictionary *placeDic = self.doctor.locationList[i];
        if ([placeDic isKindOfClass:[NSDictionary class]]) {
            NSLog(@"SI EXISTE EL DIC");
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = CLLocationCoordinate2DMake([placeDic[@"lat"] floatValue], [placeDic[@"lon"] floatValue]);
            [pointAnnotationsArray addObject:point];
        }
    }
    [self.mapView showAnnotations:pointAnnotationsArray animated:YES];
}

#pragma mark - Actions

- (IBAction)mapViewPressed:(UILongPressGestureRecognizer *)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Empezé a tocar");
        //Remove previous annotations
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        //Get map coordinate from touch
        CGPoint touchPoint = [longPressGesture locationInView:self.mapView];
        self.consultorioCoordintate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        
        //Add anotation using the touch coordinate
        MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
        pointAnnotation.coordinate = self.consultorioCoordintate;
        [self.mapView addAnnotation:pointAnnotation];
        
    } else if (longPressGesture.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Terminé de tocar");
        [self showLocationInfoViewWithLocName:nil address:nil hasParking:NO];
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Custom Methods 

-(void)showLocationInfoViewWithLocName:(NSString *)locationName address:(NSString *)locationAddress hasParking:(BOOL)hasParking {
    DoctorLocationInfoView *locationInfoView = [[DoctorLocationInfoView alloc] initWithFrame:CGRectMake(20.0, self.view.bounds.size.height/2.0 - 125.0, self.view.bounds.size.width - 40.0, 250.0)];
    locationInfoView.delegate = self;
    locationInfoView.nameTextfield.text = locationName;
    locationInfoView.addressTextfield.text = locationAddress;
    locationInfoView.parkingSwitch.on = hasParking;
    [locationInfoView showInView:self.tabBarController.view];
}

#pragma mark - Server Communicator 

-(void)saveDoctorLocationInServerWithLocName:(NSString *)locationName address:(NSString *)locationAddress parking:(BOOL)hasParking{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    //Generate JSON for the location object
    NSError *error;
    NSDictionary *locationDic = @{@"lat": @(self.consultorioCoordintate.latitude), @"lon" : @(self.consultorioCoordintate.longitude), @"location_name" : locationName, @"location_address" : locationAddress, @"parking" : @(hasParking)};
    NSData *locationData = [NSJSONSerialization dataWithJSONObject:locationDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *locationJSONString = [[NSString alloc] initWithData:locationData encoding:NSUTF8StringEncoding];
    
    NSString *parameters = [NSString stringWithFormat:@"location_list=%@", locationJSONString];
    
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"Doctor/Update/%@", self.doctor.identifier] andParameter:parameters httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:[NSString stringWithFormat:@"Doctor/Update/%@", self.doctor.identifier]]) {
        if (dictionary) {
            NSLog(@"Rspueta válida del update location: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                //Success
                [[[UIAlertView alloc] initWithTitle:@"Información Actualizada!" message:@"La localización del consultorio se ha actualizado correctamente" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                Doctor *doctor = [[Doctor alloc] initWithDoctorInfo:dictionary[@"response"]];
                [self saveDoctorInUserDefaults:doctor];
                self.doctor = nil;
            }
        } else {
            NSLog(@"Respueta invalida del update location: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    NSLog(@"Error en el server: %@ %@", error, [error localizedDescription]);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Ha ocurrido un error al intentar actualizar la información. Por favor revisa que estés conectado a internet e intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - NSUserDefaults 

-(void)saveDoctorInUserDefaults:(Doctor *)doctor {
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:doctor];
    [[NSUserDefaults standardUserDefaults] setObject:encodedData forKey:@"doctor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - DoctorLocationViewDelegate

-(void)saveButtonPressedWithLocationName:(NSString *)locationName address:(NSString *)locationAddress parking:(BOOL)hasParking{
    [self saveDoctorLocationInServerWithLocName:locationName address:locationAddress parking:hasParking];
}

#pragma mark - MKMapViewDelegate

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"Seleccioneeeee");
    if ([self.doctor.locationList[0] isKindOfClass:[NSDictionary class]]) {
        NSString *locationName = self.doctor.locationList[0][@"location_name"];
        NSString *locationAddress = self.doctor.locationList[0][@"location_address"];
        [self showLocationInfoViewWithLocName:locationName address:locationAddress hasParking:self.doctor.hasParking];
    }
}

@end
