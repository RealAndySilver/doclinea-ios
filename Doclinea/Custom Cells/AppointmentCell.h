//
//  AppointmentCell.h
//  Doclinea
//
//  Created by Developer on 20/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppointmentCell;

@protocol AppointmentCellDelegate <NSObject>
@optional
-(void)cancelAppointmentPressedInCell:(AppointmentCell *)appointmentCell;
@end

@interface AppointmentCell : UITableViewCell
@property (strong, nonatomic) id <AppointmentCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *locationAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *doctorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *reasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@end
