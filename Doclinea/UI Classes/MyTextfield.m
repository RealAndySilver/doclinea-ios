//
//  MyTextfield.m
//  Doclinea
//
//  Created by Developer on 9/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "MyTextfield.h"

@implementation MyTextfield

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    //Hidde the copy, delete, paste options
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    }];
    return [super canPerformAction:action withSender:sender];
}

@end
