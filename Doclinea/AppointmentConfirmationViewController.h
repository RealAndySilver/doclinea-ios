//
//  AppointmentConfirmationViewController.h
//  Doclinea
//
//  Created by Developer on 29/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Appointment.h"
#import "Doctor.h"

@interface AppointmentConfirmationViewController : UIViewController
@property (weak, nonatomic) Appointment *appointment;
@property (weak, nonatomic) Doctor *doctor;
@end
