//
//  DoctorLocationInfoView.m
//  Doclinea
//
//  Created by Developer on 8/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "DoctorLocationInfoView.h"

@interface DoctorLocationInfoView() <UITextFieldDelegate>
@property (strong, nonatomic) UIView *opacityView;
@end

@implementation DoctorLocationInfoView

#define ANIMATION_DURATION 0.3

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 5.0;
        self.backgroundColor = [UIColor whiteColor];
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        //Informacion label
        UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 15.0, frame.size.width - 40.0, 50.0)];
        mainLabel.text = @"Información de Consultorio";
        mainLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        mainLabel.textAlignment = NSTextAlignmentCenter;
        mainLabel.textColor = [UIColor colorWithRed:231.0/255.0 green:79.0/255.0 blue:19.0/255.0 alpha:1.0];
        mainLabel.numberOfLines = 0;
        [self addSubview:mainLabel];
        
        //Nombre de consultorio textfield
        self.nameTextfield = [[UITextField alloc] initWithFrame:CGRectMake(20.0, mainLabel.frame.origin.y + mainLabel.frame.size.height + 10.0, frame.size.width - 40.0, 30.0)];
        self.nameTextfield.textColor = [UIColor darkGrayColor];
        self.nameTextfield.borderStyle = UITextBorderStyleRoundedRect;
        self.nameTextfield.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        self.nameTextfield.placeholder = @"Nombre Consultorio";
        self.nameTextfield.tag = 1;
        self.nameTextfield.delegate = self;
        [self addSubview:self.nameTextfield];
        
        //Direccion
        self.addressTextfield = [[UITextField alloc] initWithFrame:CGRectOffset(self.nameTextfield.frame, 0.0, self.nameTextfield.frame.size.height + 10.0)];
        self.addressTextfield.textColor = [UIColor darkGrayColor];
        self.addressTextfield.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        self.addressTextfield.borderStyle = UITextBorderStyleRoundedRect;
        self.addressTextfield.placeholder = @"Dirección Consultorio";
        self.addressTextfield.tag = 2;
        self.addressTextfield.delegate = self;
        [self addSubview:self.addressTextfield];
        
        //Parqueadero label
        UILabel *parkingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, self.addressTextfield.frame.origin.y + self.addressTextfield.frame.size.height + 15.0, 150.0, 20.0)];
        parkingLabel.text = @"Tiene Parqueadero";
        parkingLabel.textColor = [UIColor lightGrayColor];
        parkingLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        [self addSubview:parkingLabel];
        
        //Parqueadero switch
        self.parkingSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(frame.size.width - 100.0, parkingLabel.frame.origin.y - 7.0, 40.0, 30.0)];
        [self addSubview:self.parkingSwitch];
        
        //Cancel button
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, frame.size.height - 50.0, frame.size.width/2.0 - 40.0, 30.0)];
        [cancelButton setTitle:@"Cancelar" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
        cancelButton.layer.cornerRadius = 5.0;
        cancelButton.backgroundColor = [UIColor lightGrayColor];
        [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        
        //Save button
        UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/2.0 + 20.0, frame.size.height - 50.0, frame.size.width/2.0 - 40.0, 30.0)];
        [saveButton setTitle:@"Guardar" forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        saveButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
        saveButton.layer.cornerRadius = 5.0;
        saveButton.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:79.0/255.0 blue:19.0/255.0 alpha:1.0];
        [saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:saveButton];
    }
    return self;
}

-(void)showInView:(UIView *)view {
    self.opacityView = [[UIView alloc] initWithFrame:view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.0;
    [view addSubview:self.opacityView];
    [view addSubview:self];
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 1.0;
                         self.opacityView.alpha = 0.7;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:nil];
}

#pragma mark -Actions 

-(void)saveButtonPressed {
    if ([self.nameTextfield.text length] > 0 && [self.addressTextfield.text length] > 0) {
        [self.delegate saveButtonPressedWithLocationName:self.nameTextfield.text address:self.addressTextfield.text parking:self.parkingSwitch.isOn];
        [self closeView];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Debes agregar el nombre y la dirección del consultorio" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)closeView {
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                         self.opacityView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self.opacityView removeFromSuperview];
                         [self removeFromSuperview];
                     }];
}

-(void)cancelButtonPressed {
    [self closeView];
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
