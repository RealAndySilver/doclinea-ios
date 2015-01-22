//
//  UserSettings.m
//  Doclinea
//
//  Created by Developer on 20/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "UserSettings.h"

@implementation UserSettings

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _emailAppointmentNotifications = [dictionary[@"email_appointment_notifications"] boolValue];
        _emailMarketingNotifications = [dictionary[@"email_marketing_notifications"] boolValue];
        _mobileAppointmentNotifications = [dictionary[@"mobile_appointment_notifications"] boolValue];
        _mobileMarketingNotifications = [dictionary[@"mobile_marketing_notifications"] boolValue];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _emailMarketingNotifications = [[aDecoder decodeObjectForKey:@"emailMarketingNotifications"] boolValue];
        _emailAppointmentNotifications = [[aDecoder decodeObjectForKey:@"emailAppointmentNotifications"] boolValue];
        _mobileMarketingNotifications = [[aDecoder decodeObjectForKey:@"mobileMarketingNotifications"] boolValue];
        _mobileAppointmentNotifications = [[aDecoder decodeObjectForKey:@"mobileAppointmentNotifications"] boolValue];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_emailAppointmentNotifications) forKey:@"emailAppointmentNotifications"];
    [aCoder encodeObject:@(_emailMarketingNotifications) forKey:@"emailMarketingNotifications"];
    [aCoder encodeObject:@(_mobileAppointmentNotifications) forKey:@"mobileAppointmentNotifications"];
    [aCoder encodeObject:@(_mobileMarketingNotifications) forKey:@"mobileMarketingNotifications"];
}


@end
