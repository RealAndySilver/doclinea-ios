//
//  PracticeListViewController.h
//  Doclinea
//
//  Created by Developer on 11/12/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PracticeListDelegate <NSObject>
@optional
-(void)doctorSelectedPractices:(NSArray *)practicesArray;
@end

@interface PracticeListViewController : UIViewController
@property (weak, nonatomic) NSArray *currentPractices;
@property (strong, nonatomic) id <PracticeListDelegate> delegate;
@end
