//
//  InsuranceTypeView.h
//  Doclinea
//
//  Created by Developer on 12/12/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Insurance;

@protocol InsuranceTypeViewDelegate <NSObject>
@optional
-(void)insuranceTypeViewDidDisappearFromCloseButton:(BOOL)closeButtonPressed;
@end

@interface InsuranceTypeView : UIView
@property (weak, nonatomic) Insurance *insurance;
@property (strong, nonatomic) id <InsuranceTypeViewDelegate> delegate;
-(void)showInView:(UIView *)view;
@end
