//
//  AppointmentsParser.h
//  Doclinea
//
//  Created by Developer on 28/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppointmentsParser : NSObject
+(NSArray *)getOrderedAppointmentsFromArray:(NSArray *)appointments;
@end
