//
//  AppointmentsParser.m
//  Doclinea
//
//  Created by Developer on 28/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "AppointmentsParser.h"
#import "Appointment.h"

@implementation AppointmentsParser

+(NSArray *)getOrderedAppointmentsFromArray:(NSArray *)appointments {
    NSMutableArray *orderedAppointments = [[NSMutableArray alloc] init];
    NSArray *monthsNames = @[@"Enero", @"Febrero", @"Marzo", @"Abril", @"Mayo", @"Junio", @"Julio", @"Agosto", @"Septiembre", @"Octubre", @"Noviembre", @"Diciembre"];
    
    if (appointments != nil && appointments.count > 0) {
        for (int i = 0; i < appointments.count; i++) {
            NSLog(@"Entre a parsear una cita ************************************");
            Appointment *appointment = appointments[i];
            //NSLog(@"Infoooo del appointmentttttt: %@", appointment.info);
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:appointment.startDate];
            NSInteger day = [components day];
            NSInteger month = [components month];
            NSInteger year = [components year];
            //NSLog(@"year: %i, month: %i, day: %i", year, month, day);
            
            NSString *currentMonthName = monthsNames[month - 1];
            if (orderedAppointments.count > 0) {
                NSInteger existentMonthIndexForAppointment = 0;
                BOOL foundExistentMonthForAppointment = NO;
                for (int i = 0; i < orderedAppointments.count; i++) {
                    if ([orderedAppointments[i] isKindOfClass:[NSDictionary class]] && orderedAppointments[i] != nil) {
                        //Ya existen diccionarios para las citas médicas
                        NSDictionary *monthDic = orderedAppointments[i];
                        if ([monthDic[@"month"] isEqualToString:currentMonthName] && [monthDic[@"year"] intValue] == year) {
                            //Ya existe un objeto "mes" para esta cita, así que debemos agregarla a este objeto
                            existentMonthIndexForAppointment = i;
                            foundExistentMonthForAppointment = YES;
                            break;
                        }
                    }
                }
                
                if (foundExistentMonthForAppointment) {
                    //Agregar la cita al objeto "Mes" ya existente
                    NSArray *daysWithAppointments = orderedAppointments[existentMonthIndexForAppointment][@"daysWithAppointments"];
                    BOOL existentDayForAppointment = NO;
                    NSInteger dayIndexForAppointment = 0;
                    
                    for (int i = 0; i < daysWithAppointments.count; i++) {
                        if ([daysWithAppointments[i] isKindOfClass:[NSDictionary class]] && daysWithAppointments[i] != nil) {
                            NSDictionary *dayDic = daysWithAppointments[i];
                            if ([dayDic[@"day"] intValue] == day) {
                                //Ya existe un objeto dia para esta cita
                                existentDayForAppointment = YES;
                                dayIndexForAppointment = i;
                                break;
                            }
                        }
                    }
                    
                    if (existentDayForAppointment) {
                        NSDictionary *dayDic = daysWithAppointments[dayIndexForAppointment];
                        NSMutableArray *appointmentsForDay = [NSMutableArray arrayWithArray:dayDic[@"appointments"]];
                        [appointmentsForDay addObject:appointment];
                        NSDictionary *updatedDayDic = @{@"day" : dayDic[@"day"], @"appointments" : appointmentsForDay};
                        NSMutableArray *updatedDaysWithAppointments = [NSMutableArray arrayWithArray:daysWithAppointments];
                        
                        [updatedDaysWithAppointments replaceObjectAtIndex:dayIndexForAppointment withObject:updatedDayDic];
                        NSSortDescriptor *dayDescriptor = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:YES];
                        NSArray *sortedDaysWithAppointments = [updatedDaysWithAppointments sortedArrayUsingDescriptors:@[dayDescriptor]];
                        
                        NSMutableDictionary *monthDic = [NSMutableDictionary dictionaryWithDictionary:orderedAppointments[existentMonthIndexForAppointment]];
                        NSDictionary *updatedMonthDic = @{@"monthNumber" : monthDic[@"monthNumber"], @"month" : monthDic[@"month"], @"year" : monthDic[@"year"], @"daysWithAppointments" : sortedDaysWithAppointments};
                        
                        NSLog(@"MOnth dic: %@", updatedMonthDic);
                        [orderedAppointments replaceObjectAtIndex:existentMonthIndexForAppointment withObject:updatedMonthDic];
                        
                    } else {
                        NSDictionary *newDayDic = @{@"day" : @(day), @"appointments" : @[appointment]};
                        NSMutableArray *updatedDaysWithAppointments = [NSMutableArray arrayWithArray:daysWithAppointments];
                        [updatedDaysWithAppointments addObject:newDayDic];
                        NSSortDescriptor *dayDescriptor = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:YES];
                        NSArray *sortedDaysWithAppointments = [updatedDaysWithAppointments sortedArrayUsingDescriptors:@[dayDescriptor]];
                        
                        NSMutableDictionary *monthDic = [NSMutableDictionary dictionaryWithDictionary:orderedAppointments[existentMonthIndexForAppointment]];
                        NSDictionary *updatedMonthDic = @{@"monthNumber" : monthDic[@"monthNumber"], @"month" : monthDic[@"month"], @"year" : monthDic[@"year"], @"daysWithAppointments" : sortedDaysWithAppointments};
                        NSLog(@"MOnth dic: %@", updatedMonthDic);
                        [orderedAppointments replaceObjectAtIndex:existentMonthIndexForAppointment withObject:updatedMonthDic];
                    }
                    
                } else {
                    //No existe objeto "mes" para esta cita, así que creemos uno nuevo
                    //Create appointment dictionary
                    NSDictionary *appointmentDic = @{@"day" : @(day), @"appointments" : @[appointment]};
                    
                    NSMutableDictionary *monthDic = [[NSMutableDictionary alloc] initWithObjects:@[@(month), currentMonthName, @(year), @[appointmentDic]] forKeys:@[@"monthNumber", @"month", @"year", @"daysWithAppointments"]];
                    NSLog(@"MOnth dic: %@", monthDic);
                    [orderedAppointments addObject:monthDic];
                }
                
                
            } else {
                //Create appointment dictionary
                NSDictionary *appointmentDic = @{@"day" : @(day), @"appointments" : @[appointment]};
                
                NSMutableDictionary *monthDic = [[NSMutableDictionary alloc] initWithObjects:@[@(month - 1), currentMonthName, @(year), @[appointmentDic]] forKeys:@[@"monthNumber", @"month", @"year", @"daysWithAppointments"]];
                NSLog(@"MOnth dic: %@", monthDic);
                [orderedAppointments addObject:monthDic];
            }
        }
    }
    
    //Sort the appointments by earliest year and month
    NSSortDescriptor *yearDescriptor = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:YES];
    NSSortDescriptor *monthDescriptor = [[NSSortDescriptor alloc] initWithKey:@"monthNumber" ascending:YES];
    NSArray *sortedAppointmenst = [orderedAppointments sortedArrayUsingDescriptors:@[yearDescriptor, monthDescriptor]];
    
    return sortedAppointmenst;
}

@end
