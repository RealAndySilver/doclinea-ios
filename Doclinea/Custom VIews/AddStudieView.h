//
//  AddStudieView.h
//  Doclinea
//
//  Created by Developer on 9/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Studie;

@protocol AddStudieViewDelegate <NSObject>
@optional
-(void)addStudieViewDidSaveStudie:(Studie *)studie;
@end

@interface AddStudieView : UIView
@property (strong, nonatomic) id <AddStudieViewDelegate> delegate;
-(void)showInView:(UIView *)view;
@end
