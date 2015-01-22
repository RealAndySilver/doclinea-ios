//
//  User.m
//  Doclinea
//
//  Created by Developer on 30/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "User.h"

@implementation User

-(instancetype)initWithUserDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _settings = [[UserSettings alloc] initWithDictionary:dictionary[@"settings"]];
        
        _identifier = dictionary[@"_id"];
        _activeAppointments = dictionary[@"active_appointments"];
        _address = dictionary[@"address"];
        _canceledAppointments = dictionary[@"canceled_appintments"];
        _city = dictionary[@"city"];
        _completedAppointmenst = dictionary[@"completed_appointments"];
        _email = dictionary[@"email"];
        _emailVerifified = [dictionary[@"email_confirmation"] boolValue];
        _gender = [dictionary[@"gender"] description];
        _insurance = dictionary[@"insurance"];
        _lastName = dictionary[@"lastname"];
        _name = dictionary[@"name"];
        _phone = dictionary[@"phone"];
        _verified = dictionary[@"verified"];
        
        //Format the date string
        NSString *dateString = dictionary[@"birthday"];
        NSArray *tempStrings = [dateString componentsSeparatedByString:@"T"];
        if (tempStrings.count > 0) {
            NSLog(@"FIRST STRINGGG: %@", tempStrings[0]);
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
            _birthday = [dateFormatter dateFromString:tempStrings[0]];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:_birthday forKey:@"birthday"];
    [encoder encodeObject:_settings forKey:@"settings"];
    [encoder encodeObject:@(_emailVerifified) forKey:@"emailVerified"];
    [encoder encodeObject:_identifier forKey:@"identifier"];
    [encoder encodeObject:_activeAppointments forKey:@"activeAppointments"];
    [encoder encodeObject:_address forKey:@"address"];
    [encoder encodeObject:_canceledAppointments forKey:@"canceledAppointments"];
    [encoder encodeObject:_city forKey:@"city"];
    [encoder encodeObject:_completedAppointmenst forKey:@"completedAppointments"];
    [encoder encodeObject:_email forKey:@"email"];
    [encoder encodeObject:_gender forKey:@"gender"];
    [encoder encodeObject:_insurance forKey:@"insurance"];
    [encoder encodeObject:_lastName forKey:@"lastName"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_phone forKey:@"phone"];
    [encoder encodeObject:_verified forKey:@"verified"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        _birthday = [decoder decodeObjectForKey:@"birthday"];
        _settings = [decoder decodeObjectForKey:@"settings"];
        _emailVerifified = [[decoder decodeObjectForKey:@"emailVerified"] boolValue];
        _identifier = [decoder decodeObjectForKey:@"identifier"];
        _activeAppointments = [decoder decodeObjectForKey:@"activeAppointments"];
        _address = [decoder decodeObjectForKey:@"address"];
        _canceledAppointments = [decoder decodeObjectForKey:@"canceledAppointments"];
        _city = [decoder decodeObjectForKey:@"city"];
        _completedAppointmenst = [decoder decodeObjectForKey:@"completedAppointments"];
        _email = [decoder decodeObjectForKey:@"email"];
        _gender = [decoder decodeObjectForKey:@"gender"];
        _insurance = [decoder decodeObjectForKey:@"insurance"];
        _lastName = [decoder decodeObjectForKey:@"lastName"];
        _name = [decoder decodeObjectForKey:@"name"];
        _phone = [decoder decodeObjectForKey:@"phone"];
        _verified = [decoder decodeObjectForKey:@"verified"];
    }
    return self;
}

@end
