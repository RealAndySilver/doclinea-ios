//
//  EducationCell.m
//  Doclinea
//
//  Created by Developer on 10/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "EducationCell.h"

@implementation EducationCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.instituteLabel = [[UILabel alloc] init];
        self.instituteLabel.textColor = [UIColor blackColor];
        self.instituteLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        //self.instituteLabel.backgroundColor = [UIColor redColor];
        self.instituteLabel.adjustsFontSizeToFitWidth = YES;
        self.instituteLabel.minimumScaleFactor = 0.6;
        [self.contentView addSubview:self.instituteLabel];
        
        self.degreeLabel = [[UILabel alloc] init];
        self.degreeLabel.textColor = [UIColor darkGrayColor];
        self.degreeLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
        //self.degreeLabel.backgroundColor = [UIColor cyanColor];
        self.degreeLabel.adjustsFontSizeToFitWidth = YES;
        self.degreeLabel.minimumScaleFactor = 0.6;
        [self.contentView addSubview:self.degreeLabel];
        
        self.studieYearsLabel = [[UILabel alloc] init];
        self.studieYearsLabel.textColor = [UIColor darkGrayColor];
        self.studieYearsLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
        //self.studieYearsLabel.backgroundColor = [UIColor orangeColor];
        self.studieYearsLabel.adjustsFontSizeToFitWidth = YES;
        self.studieYearsLabel.minimumScaleFactor = 0.6;
        [self.contentView addSubview:self.studieYearsLabel];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    self.instituteLabel.frame = CGRectMake(20.0, 20.0, bounds.size.width - 40.0, 20.0);
    self.degreeLabel.frame = CGRectOffset(self.instituteLabel.frame, 0.0, self.instituteLabel.frame.size.height);
    self.studieYearsLabel.frame = CGRectOffset(self.instituteLabel.frame, 0.0, self.instituteLabel.frame.size.height*2);
}

@end
