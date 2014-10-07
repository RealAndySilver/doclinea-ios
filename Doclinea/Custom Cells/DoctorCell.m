//
//  DoctorCell.m
//  Doclinea
//
//  Created by Developer on 1/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "DoctorCell.h"

@interface DoctorCell()
@end

@implementation DoctorCell

-(void)awakeFromNib {
    //Doctor Image View
    self.doctorImageView = [[UIImageView alloc] init];
    self.doctorImageView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.doctorImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.doctorImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.doctorImageView];
    
    //Doctor name label
    self.doctorNameLabel = [[UILabel alloc] init];
    self.doctorNameLabel.textColor = [UIColor darkGrayColor];
    self.doctorNameLabel.font = [UIFont fontWithName:@"OpenSans" size:17.0];
    self.doctorNameLabel.numberOfLines = 2;
    self.doctorNameLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:self.doctorNameLabel];
    
    //Doctor Profession Label
    self.doctorProfesionLabel = [[UILabel alloc] init];
    self.doctorProfesionLabel.textColor = [UIColor darkGrayColor];
    self.doctorProfesionLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
    self.doctorProfesionLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:self.doctorProfesionLabel];
    
    //Doctor Adress label
    self.doctorAddressLabel = [[UILabel alloc] init];
    self.doctorAddressLabel.textColor = [UIColor lightGrayColor];
    self.doctorAddressLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
    self.doctorAddressLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:self.doctorAddressLabel];
    
    //Rate view
    /*self.ratingView = [[RatingView alloc] initWithFrame:CGRectMake(self.doctorNameLabel.frame.origin.x, self.doctorNameLabel.frame.origin.y + 90.0, 100.0, 20.0) selectedImageName:@"blueStar.png" unSelectedImage:@"grayStar.png" minValue:0 maxValue:5 intervalValue:0.5 stepByStep:NO];
    self.ratingView.delegate = self;
    self.ratingView.userInteractionEnabled = NO;
    [self.contentView addSubview:self.ratingView];*/
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    self.doctorImageView.frame = CGRectMake(10.0, 10.0, bounds.size.width/4.0, bounds.size.width/3.0);
    NSLog(@"FRAME DE LA IMAGEN: %@", NSStringFromCGRect(self.doctorImageView.frame));
    self.doctorNameLabel.frame = CGRectMake(self.doctorImageView.frame.origin.x + self.doctorImageView.frame.size.width + 10.0, self.doctorImageView.frame.origin.y, bounds.size.width - (self.doctorImageView.frame.origin.x + self.doctorImageView.frame.size.width + 10.0) - 10.0, 30.0);
    self.doctorProfesionLabel.frame = CGRectOffset(self.doctorNameLabel.frame, 0.0, 30.0);
    self.doctorAddressLabel.frame = CGRectOffset(self.doctorNameLabel.frame, 0.0, 60.0);
}

@end
