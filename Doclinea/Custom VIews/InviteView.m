//
//  InviteView.m
//  Doclinea
//
//  Created by Developer on 22/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import "InviteView.h"

@interface InviteView()
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) UITextField *emailTextfield;
@end

@implementation InviteView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.layer.cornerRadius = 10.0;
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0, frame.size.width - 40.0, 60.0)];
        titleLabel.numberOfLines = 0;
        titleLabel.text = @"Invita a un amigo a usar Doclínea";
        titleLabel.textColor = [UIColor darkGrayColor];
        titleLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        self.emailTextfield = [[UITextField alloc] initWithFrame:CGRectMake(20.0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10.0, frame.size.width - 40.0, 30.0)];
        self.emailTextfield.font = [UIFont systemFontOfSize:14.0];
        self.emailTextfield.borderStyle = UITextBorderStyleRoundedRect;
        self.emailTextfield.placeholder = @"Email de amigo";
        self.emailTextfield.textColor = [UIColor lightGrayColor];
        [self addSubview:self.emailTextfield];
        
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, frame.size.height - 60.0, frame.size.width/2.0 - 30.0, 40.0)];
        [closeButton setTitle:@"Cerrar" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        closeButton.layer.cornerRadius = 4.0;
        closeButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        closeButton.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        [closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        UIButton *inviteButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/2.0 + 10.0, frame.size.height - 60.0, frame.size.width/2.0 - 30.0, 40.0)];
        [inviteButton setTitle:@"Enviar" forState:UIControlStateNormal];
        inviteButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        inviteButton.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:159.0/255.0 blue:225.0/255.0 alpha:1.0];
        inviteButton.layer.cornerRadius = 4.0;
        [inviteButton addTarget:self action:@selector(inviteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:inviteButton];
    }
    return self;
}
//User/Invite
//email, message, destination_email
-(void)showInView:(UIView *)view {
    self.opacityView = [[UIView alloc] initWithFrame:view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.0;
    [view addSubview:self.opacityView];
    
    [view addSubview:self];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.alpha = 1.0;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         self.opacityView.alpha = 0.7;
                     } completion:^(BOOL finished) {
                         
                     }];
}

-(void)closeView {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
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

-(void)inviteButtonPressed {
    if ([self.emailTextfield.text length] > 0) {
        [self.delegate inviteButtonPressedWithEmail:self.emailTextfield.text];
        [self closeView];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Debes agregar un email" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

@end
