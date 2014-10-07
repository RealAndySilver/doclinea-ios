//
//  SharedDoctor.m
//  Doclinea
//
//  Created by Developer on 6/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "SharedDoctor.h"

@implementation SharedDoctor
+(SharedDoctor *)sharedDoctor {
    static SharedDoctor *shared = nil;
    if (!shared) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [[SharedDoctor alloc] init];
        });
    }
    return shared;
}

-(Doctor *)getSavedDoctor {
    NSData *encodedData = [[NSUserDefaults standardUserDefaults] objectForKey:@"doctor"];
    Doctor *doctor = [NSKeyedUnarchiver unarchiveObjectWithData:encodedData];
    NSLog(@"NOMBRE DEL DOCTOR QUE UNARCHIVEÉ: %@", doctor.name);
    return doctor;
}

@end
