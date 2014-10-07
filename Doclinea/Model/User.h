//
//  User.h
//  Doclinea
//
//  Created by Developer on 30/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSArray *activeAppointments;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSArray *canceledAppointments;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSArray *completedAppointmenst;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *insurance;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSNumber *verified;
-(instancetype)initWithUserDictionary:(NSDictionary *)dictionary;
@end
