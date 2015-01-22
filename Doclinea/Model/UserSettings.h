//
//  UserSettings.h
//  Doclinea
//
//  Created by Developer on 20/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettings : NSObject
@property (assign, nonatomic) BOOL emailAppointmentNotifications;
@property (assign, nonatomic) BOOL emailMarketingNotifications;
@property (assign, nonatomic) BOOL mobileAppointmentNotifications;
@property (assign, nonatomic) BOOL mobileMarketingNotifications;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
