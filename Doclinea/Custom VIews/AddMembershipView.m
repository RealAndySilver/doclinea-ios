//
//  AddMembershipView.m
//  Doclinea
//
//  Created by Developer on 9/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "AddMembershipView.h"

@interface AddMembershipView() <UITextFieldDelegate>
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) UITextField *membershipTextfield;
@end

@implementation AddMembershipView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 10.0;
        self.backgroundColor = [UIColor whiteColor];
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        //Title Label
        UILabel *mainTitle = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0, frame.size.width - 40.0, 30.0)];
        mainTitle.text = @"Nueva Membresía";
        mainTitle.textAlignment = NSTextAlignmentCenter;
        mainTitle.textColor = [UIColor lightGrayColor];
        mainTitle.font = [UIFont fontWithName:@"OpenSans" size:18.0];
        [self addSubview:mainTitle];
        
        self.membershipTextfield = [[UITextField alloc] initWithFrame:CGRectMake(20.0, mainTitle.frame.origin.y + mainTitle.frame.size.height + 20.0, frame.size.width - 40.0, 30.0)];
        self.membershipTextfield.borderStyle = UITextBorderStyleRoundedRect;
        self.membershipTextfield.placeholder = @"Nombre Membresía";
        self.membershipTextfield.textColor = [UIColor lightGrayColor];
        self.membershipTextfield.autocorrectionType = UITextAutocorrectionTypeNo;
        self.membershipTextfield.delegate = self;
        self.membershipTextfield.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        [self addSubview:self.membershipTextfield];
        
        //Cancel button
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, frame.size.height - 60.0, frame.size.width/2.0 - 40.0, 40.0)];
        [cancelButton setTitle:@"Cancelar" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
        cancelButton.layer.cornerRadius = 5.0;
        cancelButton.backgroundColor = [UIColor lightGrayColor];
        [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        
        //Save button
        UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/2.0 + 20.0, frame.size.height - 60.0, frame.size.width/2.0 - 40.0, 40.0)];
        [saveButton setTitle:@"Guardar" forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        saveButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
        saveButton.layer.cornerRadius = 5.0;
        saveButton.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:159.0/255.0 blue:225.0/255.0 alpha:1.0];
        [saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:saveButton];
    }
    return self;
}

-(void)cancelButtonPressed {
    [self closeView];
}

-(void)saveButtonPressed {
    if ([self.membershipTextfield.text length] > 0) {
        [self.delegate membershipAdded:self.membershipTextfield.text];
        [self closeView];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"No has agregado el nombre de la nueva membresía" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)closeView {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                         self.opacityView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self.opacityView removeFromSuperview];
                         [self removeFromSuperview];
                     }];
}

-(void)showInView:(UIView *)view {
    self.opacityView = [[UIView alloc] initWithFrame:view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.0;
    [view addSubview:self.opacityView];
    [view addSubview:self];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.alpha = 1.0;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         self.opacityView.alpha = 0.7;
                     } completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
