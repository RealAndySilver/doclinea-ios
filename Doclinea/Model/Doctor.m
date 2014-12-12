//
//  Doctor.m
//  Doclinea
//
//  Created by Developer on 1/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "Doctor.h"
#import "Localidad.h"
#import "Studie.h"

@interface Doctor()
@end

@implementation Doctor

-(instancetype)initWithDoctorInfo:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _identifier = dictionary[@"_id"];
        _address = dictionary[@"address"];
        _city = dictionary[@"city"];
        
        //Parse Education info
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [dictionary[@"education_list"] count]; i++) {
            NSDictionary *educationDic = dictionary[@"education_list"][i];
            Studie *studie = [[Studie alloc] initWithStudieInfo:educationDic];
            [tempArray addObject:studie];
        }
        _educationList = tempArray;
        
        
        _email = dictionary[@"email"];
        _emailConfirmed = [dictionary[@"email_confirmation"] boolValue];
        _gallery = dictionary[@"gallery"];
        _gender = dictionary[@"gender"];
        _hospitalList = dictionary[@"hospital_list"];
        _insuranceList = dictionary[@"insurance_list"];
        _languageList = dictionary[@"language_list"];
        _lastName = dictionary[@"lastname"];
        _locationList = dictionary[@"location_list"];
        _name = dictionary[@"name"];
        _patientGender = dictionary[@"patient_gender"];
        _paymentList = dictionary[@"payment_list"];
        _phone = [dictionary[@"phone"] description];
        _practiceList = dictionary[@"practice_list"];
        _profesionalMembership = dictionary[@"profesional_membership"];
        _reviewList = dictionary[@"review_list"];
        _status = [dictionary[@"status"] boolValue];
        _completeName = [NSString stringWithFormat:@"%@ %@", _name, _lastName];
        _overallRating = dictionary[@"overall_rating"];
        _localidad = [[Localidad alloc] initWithDictionary:dictionary[@"localidad"]];
        _profilePic = [NSURL URLWithString:dictionary[@"profile_pic"][@"image_url"]];
        
        NSMutableString *tempPracticeList = [[NSMutableString alloc] init];
        if (_practiceList.count == 1) {
            tempPracticeList = _practiceList.firstObject;
        } else if (_practiceList.count == 2) {
            for (int i = 0; i < [_practiceList count]; i++) {
                NSString *practice = _practiceList[i];
                [tempPracticeList appendString:[NSString stringWithFormat:@"%@ / ", practice]];
            }
        }
        
        _parsedPracticeList = tempPracticeList;
        
        /*NSMutableString *tempInsurancesList = [[NSMutableString alloc] init];
        if ([_insuranceList count] == 1) {
            _parsedInsurancesList = [_insuranceList firstObject];
        } else if ([_insuranceList count] > 1) {
            for (int i = 0; i < [_insuranceList count]; i++) {
                NSString *insurance = _insuranceList[i];
                [tempInsurancesList appendString:[NSString stringWithFormat:@"%@, ", insurance]];
            }
            _parsedInsurancesList = tempInsurancesList;
        }*/
        
        NSMutableString *tempEducationList = [[NSMutableString alloc] init];
        if ([_educationList count] == 1) {
            Studie *studie = _educationList.firstObject;
            _parsedEducationList = studie.degree;
        } else if ([_educationList count] > 1) {
            for (int i = 0; i < [_educationList count]; i++) {
                Studie *studie = _educationList[i];
                [tempEducationList appendString:[NSString stringWithFormat:@"%@ / ", studie.degree]];
            }
            _parsedEducationList = tempEducationList;
        }
        
        /*NSMutableString *tempHospitalList = [[NSMutableString alloc] init];
        if ([_hospitalList count] == 1) {
            _parsedHospitalList = [_hospitalList firstObject];
        } else if ([_hospitalList count] > 1) {
            for (int i = 0; i < [_hospitalList count]; i++) {
                NSString *hospital = _hospitalList[i];
                [tempHospitalList appendString:[NSString stringWithFormat:@"%@, ", hospital]];
            }
            _parsedHospitalList = tempHospitalList;
        }
        
        NSMutableString *tempMemebershipList = [[NSMutableString alloc] init];
        if ([_profesionalMembership count] == 1) {
            _parsedProfesionalMembershipList = [_profesionalMembership firstObject];
        } else if ([_profesionalMembership count] > 1) {
            for (int i = 0; i < [_profesionalMembership count]; i++) {
                NSString *profesionalMembership = _profesionalMembership[i];
                [tempMemebershipList appendString:[NSString stringWithFormat:@"%@, ", profesionalMembership]];
            }
            _parsedProfesionalMembershipList = tempMemebershipList;
        }*/
    }
    return self;
}

#pragma mark - NSCoding Protocol 
//Methods use to store this class in NSUserDefaults
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_emailConfirmed) forKey:@"emailConfirmed"];
    [aCoder encodeObject:_identifier forKey:@"identifier"];
    [aCoder encodeObject:_address forKey:@"address"];
    [aCoder encodeObject:_city forKey:@"city"];
    [aCoder encodeObject:_educationList forKey:@"educationList"];
    [aCoder encodeObject:_email forKey:@"email"];
    [aCoder encodeObject:_gallery forKey:@"gallery"];
    [aCoder encodeObject:_gender forKey:@"gender"];
    [aCoder encodeObject:_hospitalList forKey:@"hospitalList"];
    [aCoder encodeObject:_insuranceList forKey:@"insuranceList"];
    [aCoder encodeObject:_languageList forKey:@"languageList"];
    [aCoder encodeObject:_lastName forKey:@"lastName"];
    [aCoder encodeObject:_locationList forKey:@"locationList"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_patientGender forKey:@"patientGender"];
    [aCoder encodeObject:_paymentList forKey:@"paymentList"];
    [aCoder encodeObject:_phone forKey:@"phone"];
    [aCoder encodeObject:_practiceList forKey:@"profesionalMembership"];
    [aCoder encodeObject:_reviewList forKey:@"reviewList"];
    [aCoder encodeObject:@(_status) forKey:@"status"];
    [aCoder encodeObject:_parsedEducationList forKey:@"parsedEducationList"];
    [aCoder encodeObject:_parsedHospitalList forKey:@"parsedHospitalList"];
    [aCoder encodeObject:_parsedInsurancesList forKey:@"parsedInsuranceList"];
    [aCoder encodeObject:_parsedPracticeList forKey:@"parsedPracticeList"];
    [aCoder encodeObject:_parsedProfesionalMembershipList forKey:@"parsedProfesionalMembership"];
    [aCoder encodeObject:_completeName forKey:@"completeName"];
    [aCoder encodeObject:_overallRating forKey:@"overallRating"];
    [aCoder encodeObject:_profilePic forKey:@"profilePic"];
    [aCoder encodeObject:_localidad forKey:@"localidad"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _emailConfirmed = [[aDecoder decodeObjectForKey:@"emailConfirmed"] boolValue];
        _identifier = [aDecoder decodeObjectForKey:@"identifier"];
        _address = [aDecoder decodeObjectForKey:@"address"];
        _city = [aDecoder decodeObjectForKey:@"city"];
        _educationList = [aDecoder decodeObjectForKey:@"educationList"];
        _email = [aDecoder decodeObjectForKey:@"email"];
        _gallery = [aDecoder decodeObjectForKey:@"gallery"];
        _gender = [aDecoder decodeObjectForKey:@"gender"];
        _hospitalList = [aDecoder decodeObjectForKey:@"hospitalList"];
        _insuranceList = [aDecoder decodeObjectForKey:@"insuranceList"];
        _languageList = [aDecoder decodeObjectForKey:@"languageList"];
        _lastName = [aDecoder decodeObjectForKey:@"lastName"];
        _locationList = [aDecoder decodeObjectForKey:@"locationList"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _patientGender = [aDecoder decodeObjectForKey:@"patientGender"];
        _paymentList = [aDecoder decodeObjectForKey:@"paymentList"];
        _phone = [aDecoder decodeObjectForKey:@"phone"];
        _practiceList = [aDecoder decodeObjectForKey:@"profesionalMembership"];
        _reviewList = [aDecoder decodeObjectForKey:@"reviewList"];
        _status = [[aDecoder decodeObjectForKey:@"status"] boolValue];
        _parsedEducationList = [aDecoder decodeObjectForKey:@"parsedEducationList"];
        _parsedHospitalList = [aDecoder decodeObjectForKey:@"parsedHospitalList"];
        _parsedInsurancesList = [aDecoder decodeObjectForKey:@"parsedInsuranceList"];
        _parsedPracticeList = [aDecoder decodeObjectForKey:@"parsedPracticeList"];
        _parsedProfesionalMembershipList = [aDecoder decodeObjectForKey:@"parsedProfesionalMembership"];
        _completeName = [aDecoder decodeObjectForKey:@"completeName"];
        _overallRating = [aDecoder decodeObjectForKey:@"overallRating"];
        _profilePic = [aDecoder decodeObjectForKey:@"profilePic"];
        _localidad = [aDecoder decodeObjectForKey:@"localidad"];
    }
    return self;
}

@end
