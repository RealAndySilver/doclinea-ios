//
//  FormLists.m
//  Doclinea
//
//  Created by Developer on 11/12/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "FormLists.h"

@implementation FormLists

+(FormLists *)sharedInstance {
    static FormLists *shared = nil;
    if (!shared) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [[FormLists alloc] init];
        });
    }
    return shared;
}

@end
