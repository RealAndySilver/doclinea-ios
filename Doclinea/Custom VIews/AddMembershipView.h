//
//  AddMembershipView.h
//  Doclinea
//
//  Created by Developer on 9/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddMembershipViewDelegate <NSObject>
-(void)membershipAdded:(NSString *)membershipName;
@end

@interface AddMembershipView : UIView
@property (strong, nonatomic) id <AddMembershipViewDelegate> delegate;
-(void)showInView:(UIView *)view;
@end
