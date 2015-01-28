//
//  Location.m
//  Doclinea
//
//  Created by Developer on 28/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "Location.h"

@implementation Location

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _latitude = dictionary[@"lat"];
        _longitude = dictionary[@"lon"];
        _locationAddress = dictionary[@"location_address"];
        _locationName = dictionary[@"location_name"];
        _parking = [dictionary[@"parking"] boolValue];
    }
    return self;
}

@end
