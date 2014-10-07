//
//  Localidad+Shared.m
//  Doclinea
//
//  Created by Developer on 3/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "Localidad+Shared.h"

@implementation Localidad (Shared)

+(Localidad *)sharedLocalidad {
    static Localidad *shared = nil;
    if (!shared) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [[Localidad alloc] init];
        });
    }
    return shared;
}

-(NSArray *)getLocalidadesArray {
    //Get JSON Array from file
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"localidades" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSLog(@"ITEMS EN EL JSOOOOONNN ********* : %lu", (unsigned long)[jsonArray count]);
    
    NSMutableArray *localidadesArray = [[NSMutableArray alloc] initWithCapacity:[jsonArray count]];
    for (int i = 0; i < [jsonArray count]; i++) {
        Localidad *localidad = [[Localidad alloc] initWithDictionary:jsonArray[i]];
        [localidadesArray addObject:localidad];
    }
    return localidadesArray;
}

@end
