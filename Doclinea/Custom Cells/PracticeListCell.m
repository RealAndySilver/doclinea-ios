//
//  PracticeListCell.m
//  Doclinea
//
//  Created by Developer on 11/12/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "PracticeListCell.h"

@implementation PracticeListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.practiceNameLabel = [[UILabel alloc] init];
        self.practiceNameLabel.textColor = [UIColor darkGrayColor];
        self.practiceNameLabel.textAlignment = NSTextAlignmentLeft;
        self.practiceNameLabel.font = [UIFont fontWithName:@"OpenSans" size:14.0];
        [self.contentView addSubview:self.practiceNameLabel];
        
        self.checkView = [[UIImageView alloc] init];
        self.checkView.clipsToBounds = YES;
        self.checkView.image = [UIImage imageNamed:@"Checkmark.png"];
        self.checkView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.checkView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    self.practiceNameLabel.frame = CGRectMake(20.0, 0.0, bounds.size.width - 60.0, bounds.size.height);
    self.checkView.frame = CGRectMake(bounds.size.width - 50.0, 10.0, 40.0, bounds.size.height - 20.0);
}

@end
