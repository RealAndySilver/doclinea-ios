//
//  ConfigurationViewController.h
//  Doclinea
//
//  Created by Developer on 20/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@protocol ConfigurationViewControllerDelegate <NSObject>
@optional
-(void)userUpdatedInConfigVC;
@end

@interface ConfigurationViewController : UIViewController
@property (weak, nonatomic) User *user;
@property (strong, nonatomic) id <ConfigurationViewControllerDelegate> delegate;
@end
