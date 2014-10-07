//
//  MapViewController.m
//  Doclinea
//
//  Created by Developer on 2/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "MapViewController.h"
@import MapKit;

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *map;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Numero de lugares: %lu", [self.placesArray count]);
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
@end
