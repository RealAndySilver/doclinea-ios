//
//  InviteView.h
//  Doclinea
//
//  Created by Developer on 22/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InviteViewDelegate <NSObject>
-(void)inviteButtonPressedWithEmail:(NSString *)email;
@end

@interface InviteView : UIView
@property (strong, nonatomic) id <InviteViewDelegate> delegate;
-(void)showInView:(UIView *)view;
@end
