//
//  Doctor.h
//  Doclinea
//
//  Created by Developer on 1/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Localidad;

@interface Doctor : NSObject
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSArray *educationList;
@property (strong, nonatomic) NSString *email;
@property (assign, nonatomic) BOOL emailConfirmed;
@property (strong, nonatomic) NSArray *gallery;
@property (strong, nonatomic) NSNumber *gender;
@property (strong, nonatomic) NSArray *hospitalList;
@property (strong, nonatomic) NSArray *insuranceList;
@property (strong, nonatomic) NSArray *languageList;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSArray *locationList;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *patientGender;
@property (strong, nonatomic) NSArray *paymentList;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSArray *practiceList;
@property (strong, nonatomic) NSArray *profesionalMembership;
@property (strong, nonatomic) NSArray *reviewList;
@property (assign, nonatomic) BOOL hasParking;
@property (strong, nonatomic) Localidad *localidad;
@property (assign, nonatomic) BOOL status;
@property (strong, nonatomic) NSString *parsedPracticeList;
@property (strong, nonatomic) NSString *parsedInsurancesList;
@property (strong, nonatomic) NSString *parsedEducationList;
@property (strong, nonatomic) NSString *parsedHospitalList;
@property (strong, nonatomic) NSString *parsedProfesionalMembershipList;
@property (strong, nonatomic) NSString *completeName;
@property (strong, nonatomic) NSNumber *overallRating;
@property (strong, nonatomic) NSURL *profilePic;
-(instancetype)initWithDoctorInfo:(NSDictionary *)dictionary;
@end
