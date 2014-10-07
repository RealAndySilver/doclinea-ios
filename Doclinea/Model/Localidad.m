//
//  Localidad.m
//  Doclinea
//
//  Created by Developer on 3/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "Localidad.h"

@implementation Localidad

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _latitude = [dictionary[@"lat"] floatValue];
        _longitude = [dictionary[@"lon"] floatValue];
        _name = dictionary[@"name"];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _latitude = [[aDecoder decodeObjectForKey:@"lat"] floatValue];
        _longitude = [[aDecoder decodeObjectForKey:@"lon"] floatValue];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:@(_latitude) forKey:@"lat"];
    [aCoder encodeObject:@(_longitude) forKey:@"lon"];
}

@end
