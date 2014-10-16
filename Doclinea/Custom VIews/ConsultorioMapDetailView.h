//
//  ConsultorioMapDetailView.h
//  Doclinea
//
//  Created by Developer on 8/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConsultorioMapDetailView : UIView
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UILabel *addressLabel;
-(void)showInView:(UIView *)view;
@end
