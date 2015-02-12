//
//  Appointment.m
//  Doclinea
//
//  Created by Developer on 28/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "Appointment.h"

@implementation Appointment

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _identifier = dictionary[@"_id"];
        _appointmentLength = dictionary[@"appointment_length"];
        _doctorID = dictionary[@"doctor_id"];
        _doctorName = dictionary[@"doctor_name"];
        _reason = dictionary[@"reason"];
        _imageURL = dictionary[@"doctor_image"];
        //Parse locations
        if ([dictionary[@"location"] isKindOfClass:[NSArray class]] && [dictionary[@"location"] count] > 0) {
            NSMutableArray *tempLocationsArray = [[NSMutableArray alloc] init];
            NSArray *locationsArray = dictionary[@"location"];
            for (int i = 0; i < locationsArray.count; i++) {
                if ([locationsArray[i] isKindOfClass:[NSDictionary class]] && locationsArray[i] != nil) {
                    NSDictionary *locationDic = locationsArray[i];
                    Location *location = [[Location alloc] initWithDictionary:locationDic];
                    [tempLocationsArray addObject:location];
                }
            }
            _locations = tempLocationsArray;
        }
        
        //Parse Dates
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000Z"];
        dateFormatter.locale = [NSLocale currentLocale];
        
        NSString *startDateString = dictionary[@"date_start"];
        NSString *endDateString = dictionary[@"date_end"];
        
        _startDate = [dateFormatter dateFromString:startDateString];
        _endDate = [dateFormatter dateFromString:endDateString];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:_startDate];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];
        NSLog(@"start hour: %i", hour);
        NSLog(@"start minutes: %i", minute);
        _startHour = [NSString stringWithFormat:@"%i:%02i", hour, minute];
        //NSLog(@"Start date: %@", _startDate);
        //NSLog(@"End date: %@", _endDate);
        
        _status = dictionary[@"status"];
        
        _info = [NSString stringWithFormat:@"start date: %@, end date: %@, status: %@", _startDate, _endDate, _status];
    }
    return self;
}

@end
