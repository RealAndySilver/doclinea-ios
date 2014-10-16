//
//  ConsultorioMapDetailView.m
//  Doclinea
//
//  Created by Developer on 8/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "ConsultorioMapDetailView.h"

#define ANIMATION_DURATION 0.3

@interface ConsultorioMapDetailView()
@property (strong, nonatomic) UIView *opacityView;
@end

@implementation ConsultorioMapDetailView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 5.0;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.backgroundColor = [UIColor whiteColor];
        
        self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0, frame.size.width - 40.0, 20.0)];
        self.locationLabel.textColor = [UIColor colorWithRed:34.0/255.0 green:159.0/255.0 blue:225.0/255.0 alpha:1.0];
        self.locationLabel.font = [UIFont fontWithName:@"OpenSans" size:17.0];
        self.locationLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.locationLabel];
        
        self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, self.locationLabel.frame.origin.y + self.locationLabel.frame.size.height + 10.0, frame.size.width - 40.0, 20.0)];
        self.addressLabel.textColor = [UIColor darkGrayColor];
        self.addressLabel.font = [UIFont fontWithName:@"OpenSans" size:17.0];
        self.addressLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.addressLabel];
        
        //Close button
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(40.0, frame.size.height - 50.0, frame.size.width - 80.0, 30.0)];
        [closeButton setTitle:@"Cerrar" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        closeButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        closeButton.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:159.0/255.0 blue:225.0/255.0 alpha:1.0];
        closeButton.layer.cornerRadius = 5.0;
        [closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
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

-(void)closeButtonPressed {
    [self closeView];
}

@end
