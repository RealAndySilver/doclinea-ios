//
//  InsuranceConfirmationViewController.h
//  Doclinea
//
//  Created by Developer on 10/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Doctor.h"

@protocol InsuranceConfirmationDelegate <NSObject>
-(void)insuranceSelectedAtIndex:(NSUInteger)index;
@end

@interface InsuranceConfirmationViewController : UIViewController
@property (strong, nonatomic) id <InsuranceConfirmationDelegate> delegate;
@property (weak, nonatomic) Doctor *doctor;
@end
