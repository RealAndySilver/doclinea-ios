//
//  MapViewController.m
//  Doclinea
//
//  Created by Developer on 2/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "MapViewController.h"
#import "ConsultorioMapDetailView.h"
@import MapKit;

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *map;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Numero de lugares: %lu", (unsigned long)[self.placesArray count]);
    [self setupDoctorWorkPlacesInMap];
}

-(void)setupDoctorWorkPlacesInMap {
    //Get the locations and place a pin
    NSMutableArray *pointAnnotationsArray = [[NSMutableArray alloc] initWithCapacity:[self.placesArray count]];
    for (int i = 0; i < [self.placesArray count]; i++) {
        NSDictionary *placeDic = self.placesArray[i];
        if ([placeDic isKindOfClass:[NSDictionary class]]) {
            NSLog(@"SI EXISTE EL DIC");
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = CLLocationCoordinate2DMake([placeDic[@"lat"] floatValue], [placeDic[@"lon"] floatValue]);
            [pointAnnotationsArray addObject:point];
        }
    }
    [self.map showAnnotations:pointAnnotationsArray animated:YES];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MKMpaViewDelegate

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSString *locationName = self.placesArray[0][@"location_name"];
    NSString *locationAddress = self.placesArray[0][@"location_address"];
    
    ConsultorioMapDetailView *consultorioView = [[ConsultorioMapDetailView alloc] initWithFrame:CGRectMake(20.0, self.view.bounds.size.height/2.0 - 75.0, self.view.bounds.size.width - 40.0, 150.0)];
    consultorioView.locationLabel.text = locationName;
    consultorioView.addressLabel.text = locationAddress;
    [consultorioView showInView:self.view];
}

@end
