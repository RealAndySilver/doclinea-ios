//
//  AddStudieView.m
//  Doclinea
//
//  Created by Developer on 9/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "AddStudieView.h"
#import "Studie.h"

@interface AddStudieView() <UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) UITextView *highlightsTextview;
@property (strong, nonatomic) UITextField *yearEndTextfield;
@property (strong, nonatomic) UITextField *yearStartTextfield;
@property (strong, nonatomic) UITextField *degreeTextfield;
@property (strong, nonatomic) UITextField *instituteTextfield;
@property (strong, nonatomic) NSMutableArray *yearsArray;
@end

@implementation AddStudieView

typedef NS_ENUM(NSUInteger, pickerType) {
    startYearPicker,
    endYearPicker
};

#define ANIMATION_DURATION 0.3

#pragma mark - Lazy Instantiation

-(NSMutableArray *)yearsArray {
    if (!_yearsArray) {
        _yearsArray = [[NSMutableArray alloc] init];
        for (int i = 1950; i < 2020; i++) {
            [_yearsArray addObject:@(i)];
        }
    }
    return _yearsArray;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 5.0;
        self.backgroundColor = [UIColor whiteColor];
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        //Create pickers for the start year and end year textfields
        UIPickerView *startYearPickerView = [[UIPickerView alloc] init];
        startYearPickerView.tag = startYearPicker;
        startYearPickerView.delegate = self;
        startYearPickerView.dataSource = self;
        
        UIPickerView *endYearPickerView = [[UIPickerView alloc] init];
        endYearPickerView.delegate = self;
        endYearPickerView.dataSource = self;
        endYearPickerView.tag = endYearPicker;
        
        //Toolbar fot the done button
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 44.0)];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissPickers)];
        [toolbar setItems:@[doneButton] animated:NO];
        
        //Title
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0, frame.size.width - 40.0, 30.0)];
        title.text = @"Agregar Estudio";
        title.textColor = [UIColor colorWithRed:34.0/255.0 green:159.0/255.0 blue:225.0/255.0 alpha:1.0];
        title.font = [UIFont fontWithName:@"OpenSans" size:18.0];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];
        
        //Cancel button
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, frame.size.height - 60.0, frame.size.width/2.0 - 40.0, 40.0)];
        [cancelButton setTitle:@"Cancelar" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
        cancelButton.layer.cornerRadius = 5.0;
        cancelButton.backgroundColor = [UIColor lightGrayColor];
        [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        
        //Institune name textfield
        self.instituteTextfield = [[UITextField alloc] initWithFrame:CGRectMake(20.0, title.frame.origin.y + title.frame.size.height + 20.0, frame.size.width - 40.0, 30.0)];
        self.instituteTextfield.borderStyle = UITextBorderStyleRoundedRect;
        self.instituteTextfield.placeholder = @"Nombre Universidad";
        self.instituteTextfield.textAlignment = NSTextAlignmentCenter;
        self.instituteTextfield.textColor = [UIColor darkGrayColor];
        self.instituteTextfield.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        self.instituteTextfield.delegate = self;
        [self addSubview:self.instituteTextfield];
        
        //Degree textfield
        self.degreeTextfield = [[UITextField alloc] initWithFrame:CGRectOffset(self.instituteTextfield.frame, 0.0, self.instituteTextfield.frame.size.height + 20.0)];
        self.degreeTextfield.borderStyle = UITextBorderStyleRoundedRect;
        self.degreeTextfield.placeholder = @"Estudio Realizado";
        self.degreeTextfield.textAlignment = NSTextAlignmentCenter;
        self.degreeTextfield.textColor = [UIColor darkGrayColor];
        self.degreeTextfield.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        self.degreeTextfield.delegate = self;
        [self addSubview:self.degreeTextfield];
        
        //Start year textfield
        self.yearStartTextfield = [[UITextField alloc] initWithFrame:CGRectMake(20.0, self.degreeTextfield.frame.origin.y + self.degreeTextfield.frame.size.height + 20.0, frame.size.width/2.0 - 30.0, 30.0)];
        self.yearStartTextfield.borderStyle = UITextBorderStyleRoundedRect;
        self.yearStartTextfield.placeholder = @"Año Comienzo";
        self.yearStartTextfield.textAlignment = NSTextAlignmentCenter;
        self.yearStartTextfield.font = [UIFont fontWithName:@"OpenSans" size:14.0];
        self.yearStartTextfield.textColor = [UIColor darkGrayColor];
        self.yearStartTextfield.delegate = self;
        self.yearStartTextfield.inputView = startYearPickerView;
        self.yearStartTextfield.inputAccessoryView = toolbar;
        [self addSubview:self.yearStartTextfield];
        
        //end year textfield
        self.yearEndTextfield = [[UITextField alloc] initWithFrame:CGRectMake(frame.size.width/2.0 + 10.0, self.yearStartTextfield.frame.origin.y, frame.size.width/2.0 - 30.0, 30.0)];
        self.yearEndTextfield.borderStyle = UITextBorderStyleRoundedRect;
        self.yearEndTextfield.placeholder = @"Año Finalización";
        self.yearEndTextfield.textAlignment = NSTextAlignmentCenter;
        self.yearEndTextfield.font = [UIFont fontWithName:@"OpenSans" size:14.0];
        self.yearEndTextfield.textColor = [UIColor darkGrayColor];
        self.yearEndTextfield.delegate = self;
        self.yearEndTextfield.inputView = endYearPickerView;
        self.yearEndTextfield.inputAccessoryView = toolbar;
        [self addSubview:self.yearEndTextfield];
        
        //Highlights textview
        self.highlightsTextview = [[UITextView alloc] initWithFrame:CGRectMake(20.0, self.yearStartTextfield.frame.origin.y + self.yearStartTextfield.frame.size.height + 20.0, frame.size.width - 40.0, 100.0)];
        self.highlightsTextview.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        self.highlightsTextview.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        self.highlightsTextview.layer.cornerRadius = 5.0;
        self.highlightsTextview.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
        self.highlightsTextview.layer.borderWidth = 1.0;
        self.highlightsTextview.delegate = self;
        self.highlightsTextview.inputAccessoryView = toolbar;
        self.highlightsTextview.text = @"Comentario acerca del estudio realizado";
        [self addSubview:self.highlightsTextview];
        
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

-(void)dismissPickers {
    [self.highlightsTextview resignFirstResponder];
    [self.yearStartTextfield resignFirstResponder];
    [self.yearEndTextfield resignFirstResponder];
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

-(void)saveButtonPressed {
    if ([self.instituteTextfield.text length] > 0) {
        Studie *studie = [[Studie alloc] init];
        studie.instituteName = self.instituteTextfield.text;
        studie.degree = self.degreeTextfield.text;
        studie.startYear = self.yearStartTextfield.text;
        studie.endYear = self.yearEndTextfield.text;
        studie.highlights = self.highlightsTextview.text;
        
        [self.delegate addStudieViewDidSaveStudie:studie];
        
        [self closeView];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Debes agregar al menos el nombre de la universidad en donde realizaste los estudios." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

#pragma mark - UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.yearsArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.yearsArray[row] description];
}

#pragma mark - UIPickerViewDelegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == startYearPicker) {
        self.yearStartTextfield.text = [self.yearsArray[row] description];
    } else if (pickerView.tag == endYearPicker) {
        self.yearEndTextfield.text = [self.yearsArray[row] description];
    }
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Comentario acerca del estudio realizado"]) {
        textView.text = @"";
        textView.textColor = [UIColor darkGrayColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Comentario acerca del estudio realizado";
        textView.textColor = [UIColor colorWithWhite:0.8 alpha:1.0]; //optional
    }
    [textView resignFirstResponder];
}

@end
