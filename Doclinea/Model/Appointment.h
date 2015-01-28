//
//  Appointment.h
//  Doclinea
//
//  Created by Developer on 28/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface Appointment : NSObject

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *appointmentLength;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSString *doctorID;
@property (strong, nonatomic) NSArray *locations;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) NSString *startHour;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
