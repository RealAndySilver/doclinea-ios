//
//  InsuranceTypeView.m
//  Doclinea
//
//  Created by Developer on 12/12/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "InsuranceTypeView.h"
#import "Insurance.h"
#import "InsuranceType.h"

@interface InsuranceTypeView() <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) BOOL closeButtonWasPressed;
@end

@implementation InsuranceTypeView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
        
        UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 15.0, frame.size.width - 40.0, 60.0)];
        mainLabel.text = @"Selecciona el tipo de seguro";
        mainLabel.textColor = [UIColor colorWithRed:34.0/255.0 green:159.0/255.0 blue:225.0/255.0 alpha:1.0];
        mainLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        mainLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:mainLabel];
        
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 10.0, 30.0, 30.0)];
        [closeButton setTitle:@"X" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        closeButton.layer.cornerRadius = 4.0;
        closeButton.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        [closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, mainLabel.frame.origin.y + mainLabel.frame.size.height, frame.size.width, 1.0)];
        lineView.backgroundColor = [UIColor orangeColor];
        [self addSubview:lineView];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, lineView.frame.origin.y + lineView.frame.size.height, frame.size.width, frame.size.height - (lineView.frame.origin.y + lineView.frame.size.height)) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TypeCell"];
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.rowHeight = 50.0;
        self.tableView.layer.cornerRadius = 10.0;
        [self addSubview:self.tableView];
        
        
    }
    return self;
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.insurance.typeList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TypeCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TypeCell"];
    }
    InsuranceType *insuranceType = self.insurance.typeList[indexPath.row];
    cell.textLabel.text = insuranceType.name;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *insuranceName = self.insurance.name;
    
    InsuranceType *insuranceType = self.insurance.typeList[indexPath.row];
    NSString *insuranceTypeName = insuranceType.name;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InsuranceSelected" object:nil userInfo:@{@"name" : insuranceName, @"type" : insuranceTypeName}];
    [self closeView];
}

-(void)closeButtonPressed {
    self.closeButtonWasPressed = YES;
    [self closeView];
}

-(void)closeView {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                         self.opacityView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self.opacityView removeFromSuperview];
                         [self removeFromSuperview];
                         if (self.closeButtonWasPressed) {
                             [self.delegate insuranceTypeViewDidDisappearFromCloseButton:YES];
                         } else {
                             [self.delegate insuranceTypeViewDidDisappearFromCloseButton:NO];
                         }
                     }];
}

-(void)showInView:(UIView *)view {
    self.opacityView = [[UIView alloc] initWithFrame:view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.0;
    [view addSubview:self.opacityView];
    [view addSubview:self];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.alpha = 1.0;
                         self.opacityView.alpha = 0.7;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:^(BOOL finished) {
                         
                     }];
}

@end
