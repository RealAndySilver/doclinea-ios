//
//  DoctorLocationInfoView.h
//  Doclinea
//
//  Created by Developer on 8/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DoctorLocationViewDelegate <NSObject>
@optional
-(void)saveButtonPressedWithLocationName:(NSString *)locationName address:(NSString *)locationAddress;
@end

@interface DoctorLocationInfoView : UIView
@property (strong, nonatomic) UITextField *nameTextfield;
@property (strong, nonatomic) UITextField *addressTextfield;
@property (strong, nonatomic) id <DoctorLocationViewDelegate> delegate;
-(void)showInView:(UIView *)view;
@end
